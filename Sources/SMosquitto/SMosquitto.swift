import Foundation
import cmosquitto

/**
 - Important:
 The following functions that deal with network operations might succeed,
 but this does not mean that the operation has taken place.
 An attempt will be made to write the network data, but if the socket is not available for writing at that time
 then the packet will not be sent.
 To ensure the packet is sent, call `loop` (which must also be called to process incoming network data).
 This is especially important when disconnecting a client that has a will.
 If the broker does not receive the DISCONNECT command,
 it will assume that the client has disconnected unexpectedly and send the will.

 - `connect`
 - `disconnect`
 - `subscribe`
 - `mosquitto_unsubscribe`
 - `mosquitto_publish`
 */
public class SMosquitto {
  private let handle: OpaquePointer
  
  public var onConnect: ((ConnectionResponseCode) -> Void)?
  public var onMessage: ((Message) -> Void)?
  public var onDisconnect: ((DisconnectReason) -> Void)?
  public var onPublish: ((Identifier<Message>) -> Void)?
  public var onSubscribe: ((Array<QOS>) -> Void)?
  public var onUnsubscribe: ((Identifier<Message>) -> Void)?
  public var onLog: ((LogLevel, String) -> Void)?

  /**
   Must be called before any other SMosquitto functions.

   - important: This function is *not* thread safe.
   */
  public static func initialize() {
    mosquitto_lib_init();
  }

  /**
   This function allows an existing SMosquitto instance to be reused.
   Closes any open network connections, frees memory and reinitialise the client with the new parameters.

   - Parameters:
     - id: string to use as the client id. If nil, a random client id will be generated.
   If id is nil, cleanSession must be true.
     - cleanSession: set to true to instruct the broker to clean all messages and subscriptions on disconnect,
   false to instruct it to keep them. See the man page mqtt(7) for more details.
   Must be set to true if the id parameter is nil.
   */
  public func reinitialise(id: String? = nil, cleanSession: Bool = true) throws {
    try mosquitto_reinitialise(handle, id, cleanSession, nil).failable()
    setupCallbacks()
  }

  /// Returns version information for the mosquitto library.
  public static func version() -> Version {
    return Version()
  }

  /// Returns version information for mosquitto library which SMosquitto was compiled with.
  public static func compiledWithVersion() -> Version {
    return Version.compiledWithVersion()
  }

  /// Call to free resources associated with the library.
  public static func cleanup() {
    mosquitto_lib_cleanup();
  }

  /**
   Create a new mosquitto client instance.

   - Parameters:
     - id: String to use as the client id. If nil, a random client id will be generated.
   If id is nil, cleanSession must be true.
     - cleanSession: set to true to instruct the broker to clean all messages and subscriptions on disconnect,
   false to instruct it to keep them. See the man page mqtt(7) for more details.
   Note that a client will never discard its own outgoing messages on disconnect.
   Calling `disconnect` or  `connect` will cause the messages to be resent.
   Use `reinitialise` to reset a client to its original state.  Must be set to true if the id parameter is nil.
   */
  public init(id: String? = nil, cleanSession: Bool = true) {
    self.handle = mosquitto_new(id, cleanSession, nil)

    Instances.set(handle, self)
    setupCallbacks()
  }

  /// Free memory associated with a mosquitto client instance.
  deinit {
    Instances.clear(handle)
    mosquitto_destroy(handle)
  }

  // MARK: - Connection

  /**
   Connect to an MQTT broker. This extends the functionality of `connect` by adding the `bindAddress` parameter.
   Use this function if you need to restrict network communication over a particular interface.

   - Parameters:
     - host: the hostname or ip address of the broker to connect to.
     - port: the network port to connect to.
     - keepalive: the number of seconds after which the broker should send a PING message to the client
   if no other messages have been exchanged in that time.
     - bindAddress: the hostname or ip address of the local network interface to bind to.
   */
  public func connect(host: String, port: Int32 = 1883, keepalive: Int32, bindAddress: String? = nil) throws {
    try mosquitto_connect_bind(handle, host, port, keepalive, bindAddress).failable()
  }

  /// Disconnect from the broker.
  public func disconnect() throws {
    try mosquitto_disconnect(handle).failable()
  }

  /**
   Reconnect to a broker.

   This function provides an easy way of reconnecting to a broker after a connection has been lost.
   It uses the values that were provided in the `connect` call. It must not be called before `connect`.
   */
  public func reconnect() throws {
    try mosquitto_reconnect(handle).failable()
  }

  /**
   Configure username and password for a mosquitton instance.
   This is only supported by brokers that implement the MQTT spec v3.1.
   By default, no username or password will be sent.
   If username is nil, the password argument is ignored.
   This must be called before calling `connect`.
   - Parameters:
     - username: the username to send as a string, or nil to disable authentication.
     - password: the password to send as a string. Set to nil when username is valid in order to send just a username.
   */
  public func setLoginInformation(username: String?, password: String?) throws {
    try mosquitto_username_pw_set(handle, username, password).failable()
  }

  public func setReconnectDelay(reconnectDelay: Delay,
                                reconnectDelayMax: Delay,
                                useReconnectExponentialBackoff: Bool) throws {
    try mosquitto_reconnect_delay_set(handle,
                                      reconnectDelay.seconds,
                                      reconnectDelayMax.seconds,
                                      useReconnectExponentialBackoff).failable()
  }

  public func setSocks5(host: String, port: Int32, username: String? = nil, password: String? = nil) throws {
    try mosquitto_socks5_set(handle, host, port, username, password).failable()
  }

  // MARK: - Loop

  public enum Timeout {
    case instant
    case interval(TimeInterval)

    fileprivate var rawFormat: Int32 {
      switch self {
      case .instant:
        return 0
      case .interval(let timeInterval):
        return Int32(timeInterval * pow(10, 3))
      }
    }
  }

  public struct Delay {
    public let seconds: UInt32

    public init(seconds: UInt32) {
      self.seconds = seconds
    }
  }

  public func loopStart() throws {
    try mosquitto_loop_start(handle).failable()
  }

  public func loopStop(force: Bool = false) throws {
    try mosquitto_loop_stop(handle, force).failable();
  }

  public func loop(timeout: Timeout, maxPackets: Int32 = 1) throws {
    try mosquitto_loop(handle, timeout.rawFormat, maxPackets).failable()
  }

  public func loopForever(timeout: Timeout, maxPackets: Int32 = 1) throws {
    try mosquitto_loop_forever(handle, timeout.rawFormat, maxPackets).failable()
  }

  public func loopRead(maxPackets: Int32 = 1) throws {
    try mosquitto_loop_read(handle, maxPackets).failable()
  }

  public func loopWrite(maxPackets: Int32 = 1) throws {
    try mosquitto_loop_write(handle, maxPackets).failable()
  }

  public func loopMisc() throws {
    try mosquitto_loop_misc(handle).failable()
  }

  public func wantWrite() -> Bool {
    return mosquitto_want_write(handle)
  }

  public func setIsThreaded(_ isThreaded: Bool) throws {
    try mosquitto_threaded_set(handle, isThreaded).failable()
  }

  // MARK: - Publish

  public func setWill(topic: String, payload: Payload, qos: QOS, retain: Bool) throws {
    try payload.data.withUnsafeBytes { (ptr) -> Int32 in
      mosquitto_will_set(handle, topic, payload.count, ptr, qos.rawValue, retain)
      }.failable()
  }

  public func clearWill() throws {
    try mosquitto_will_clear(handle).failable()
  }

  @discardableResult
  public func publish(topic: String, payload: Payload, qos: QOS, retain: Bool) throws -> Identifier<Message> {
    var messageId: Int32 = 0
    try payload.data.withUnsafeBytes { (ptr) -> Int32 in
      mosquitto_publish(handle, &messageId, topic, Int32(payload.count), ptr, qos.rawValue, retain)
      }.failable()
    return Identifier<Message>(rawValue: messageId)
  }

  // MARK: - Subscribe

  @discardableResult
  public func subscribe(subscriptionPattern: String, qos: QOS) throws -> Identifier<Message> {
    var messageId: Int32 = 0
    try mosquitto_subscribe(handle, &messageId, subscriptionPattern, qos.rawValue).failable()
    return Identifier<Message>(rawValue: messageId)
  }

  // MARK: - Other

  public func setMaxInflightMessages(_ maxInflightMessage: UInt32) throws {
    try mosquitto_max_inflight_messages_set(handle, maxInflightMessage).failable()
  }
}

// MARK: - Callbacks

private extension SMosquitto {
  private func setupCallbacks() {
    setupOnConnectCallback()
    setupOnMessageCallback()
    setupOnDisconnectCallback()
    setupOnPublishCallback()
    setupOnSubscribeCallback()
    setupOnUnsubscribeCallback()
    setupOnLogCallback()
  }

  private func setupOnConnectCallback() {
    mosquitto_connect_callback_set(handle) { (callbackHandle, _, mosConnectionResponseCode) in
      let code = SMosquitto.ConnectionResponseCode(mosquittoCode: mosConnectionResponseCode)
      Instances.unwrapGet(callbackHandle)?.onConnect?(code)
    }
  }

  private func setupOnMessageCallback() {
    mosquitto_message_callback_set(handle) { (callbackHandle, _, mosMessagePtr) in
      guard let mosMessage = mosMessagePtr?.pointee else {
        assertionFailure("Unexpected empty message")
        return
      }
      Instances.unwrapGet(callbackHandle)?.onMessage?(Message(mosMessage))
    }
  }

  private func setupOnDisconnectCallback() {
    mosquitto_disconnect_callback_set(handle) { (callbackHandle, _, rawDisconnectReason) in
      Instances.unwrapGet(callbackHandle)?.onDisconnect?(DisconnectReason(rawDisconnectReason))
    }
  }

  private func setupOnPublishCallback() {
    mosquitto_publish_callback_set(handle) { (callbackHandle, _, rawMessageId) in
      Instances.unwrapGet(callbackHandle)?.onPublish?(Identifier<Message>(rawValue: rawMessageId))
    }
  }

  private func setupOnSubscribeCallback() {
    mosquitto_subscribe_callback_set(handle) { (callbackHandle, _, rawMessageId, qosCount, grantedQos) in
      guard let grantedQos = grantedQos else {
        assertionFailure("Unexpected nil qos array")
        return
      }
      let qosPtr = UnsafeBufferPointer(start: grantedQos, count: Int(qosCount))
      let qos = Array(qosPtr).compactMap { QOS(rawValue: $0) }
      Instances.unwrapGet(callbackHandle)?.onSubscribe?(qos)
    }
  }

  private func setupOnUnsubscribeCallback() {
    mosquitto_unsubscribe_callback_set(handle) { (callbackHandle, _, rawMessageId) in
      Instances.unwrapGet(callbackHandle)?.onUnsubscribe?(Identifier<Message>(rawValue: rawMessageId))
    }
  }

  private func setupOnLogCallback() {
    mosquitto_log_callback_set(handle) { (callbackHandle, _, rawLogLevel, rawLogMessage) in
      guard let rawLogMessage = rawLogMessage else {
        assertionFailure("Unexpected nil log message")
        return
      }
      let logLevel = LogLevel(rawValue: rawLogLevel) ?? .all
      Instances.unwrapGet(callbackHandle)?.onLog?(logLevel, String(cString: rawLogMessage))
    }
  }
}

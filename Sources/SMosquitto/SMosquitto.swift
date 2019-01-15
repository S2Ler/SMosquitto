import Foundation
import cmosquitto

public class SMosquitto {
  private let handle: OpaquePointer
  
  public var onConnect: ((ConnectionResponseCode) -> Void)?
  public var onMessage: ((Message) -> Void)?
  public var onDisconnect: ((DisconnectReason) -> Void)?
  public var onPublish: ((Identifier<Message>) -> Void)?
  public var onSubscribe: ((Array<QOS>) -> Void)?
  public var onUnsubscribe: ((Identifier<Message>) -> Void)?
  public var onLog: ((LogLevel, String) -> Void)?

  public static func initialize() {
    mosquitto_lib_init();
  }

  public func reinitialise(id: String? = nil, cleanSession: Bool = true) throws {
    try mosquitto_reinitialise(handle, id, cleanSession, nil).failable()
    setupCallbacks()
  }

  public static func version() -> Version {
    return Version()
  }

  public static func cleanup() {
    mosquitto_lib_cleanup();
  }

  public init(id: String? = nil, cleanSession: Bool = true) {
    self.handle = mosquitto_new(id, cleanSession, nil)

    Instances.set(handle, self)
    setupCallbacks()
  }

  deinit {
    Instances.clear(handle)
    mosquitto_destroy(handle)
  }

  // MARK: - Connection
  public func connect(host: String, port: Int32, keepalive: Int32, bindAddress: String? = nil) throws {
    try mosquitto_connect_bind(handle, host, port, keepalive, bindAddress).failable()
  }

  public func disconnect() throws {
    try mosquitto_disconnect(handle).failable()
  }

  public func reconnect() throws {
    try mosquitto_reconnect(handle).failable()
  }

  public func setLoginInformation(username: String, password: String) throws {
    try mosquitto_username_pw_set(handle, username, password).failable()
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

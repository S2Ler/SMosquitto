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
  private var tlsPassword: String?
  
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
  public func connect(host: String, port: Int32 = 1883, keepalive: TimeInterval, bindAddress: String? = nil) throws {
    try mosquitto_connect_bind(handle, host, port, Int32(keepalive), bindAddress).failable()
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

  /**
   Control the behaviour of the client when it has unexpectedly disconnected in `loopForever` or after `loopStart`.
   The default behaviour if this function is not used
   is to repeatedly attempt to reconnect with a delay of 1 second until the connection succeeds.

   Use `reconnectDelay` parameter to change the delay between successive reconnection attempts.
   You may also enable exponential backoff of the time between reconnections
   by setting `useReconnectExponentialBackoff` to true and set an upper bound on the delay with `reconnectDelayMax`.

   # Example 1:
     delay=2, delay_max=10, exponential_backoff=False
     Delays would be: 2, 4, 6, 8, 10, 10, ...

   # Example 2:
     delay=3, delay_max=30, exponential_backoff=True
     Delays would be: 3, 6, 12, 24, 30, 30, ...

   - Parameters:
     - reconnectDelay: the number of seconds to wait between reconnects.
     - reconnectDelayMax: the maximum number of seconds to wait between reconnects.
     - useReconnectExponentialBackoff: use exponential backoff between reconnect attempts.
   */
  public func setReconnectDelay(reconnectDelay: Delay,
                                reconnectDelayMax: Delay,
                                useReconnectExponentialBackoff: Bool) throws {
    try mosquitto_reconnect_delay_set(handle,
                                      reconnectDelay.seconds,
                                      reconnectDelayMax.seconds,
                                      useReconnectExponentialBackoff).failable()
  }

  /**
   Configure the client to use a SOCKS5 proxy when connecting. Must be called
   before connecting. "None" and "username/password" authentication is
   supported.

   - Parameters:
     - host: the SOCKS5 proxy host to connect to.
     - port: the SOCKS5 proxy port to use.
     - username: if not nil, use this username when authenticating with the proxy.
     - password: if not nil and username is not nil, use this password when authenticating with the proxy.
   */
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

  /**
   This is part of the threaded client interface. Call this once to start a new thread to process network traffic.
   This provides an alternative to repeatedly calling `loop` yourself.
   */
  public func loopStart() throws {
    try mosquitto_loop_start(handle).failable()
  }

  /**
   This is part of the threaded client interface.
   Call this once to stop the network thread previously created with `loopStart`.
   This call will block until the network thread finishes.
   For the network thread to end, you must have previously called `disconnect or have set the force parameter to true.

   - Parameters:
     - force: set to true to force thread cancellation. If false, `disconnect` must have already been called.
   */
  public func loopStop(force: Bool = false) throws {
    try mosquitto_loop_stop(handle, force).failable();
  }

  /**
   The main network loop for the client. You must call this frequently in order to keep communications between
   the client and broker working. If incoming data is present it will then be processed. Outgoing commands, from e.g.
   `publish`, are normally sent immediately that their function is called, but this is not always possible.
   `loop` will also attempt to send any remaining outgoing messages, which also includes commands that are part of the
   flow for messages with QoS > 0.
      An alternative approach is to use `loopStart` to run the client loop in its own thread.
      This calls `select()` to monitor the client network socket. If you want to integrate mosquitto client operation
   with your own `select()` call, use `socket`, `loopRead`, `loopWrite` and `loopMisc`.

   - Parameters:
     - timeout: Maximum time interval to wait for network activity in the `select()` call before timing out.
     - maxPackets: this parameter is currently unused and should be set to 1 for future compatibility.
   */
  public func loop(timeout: Timeout = .interval(1), maxPackets: Int32 = 1) throws {
    try mosquitto_loop(handle, timeout.rawFormat, maxPackets).failable()
  }

  /**
   * This function call loop() for you in an infinite blocking loop. It is useful
   * for the case where you only want to run the MQTT client loop in your
   * program.
   *
   * It handles reconnecting in case server connection is lost. If you call
   * mosquitto_disconnect() in a callback it will return.
   *
   - Parameters:
     - timeout: Maximum time interval to wait for network activity in the `select()` call before timing out.
     - maxPackets: this parameter is currently unused and should be set to 1 for future compatibility.
   */
  public func loopForever(timeout: Timeout = .interval(1), maxPackets: Int32 = 1) throws {
    try mosquitto_loop_forever(handle, timeout.rawFormat, maxPackets).failable()
  }

  /**
   Carry out network read operations.
   This should only be used if you are not using `loop` and
   are monitoring the client network socket for activity yourself.

   - Parameters:
     - maxPackets: this parameter is currently unused and should be set to 1 for future compatibility.
   */
  public func loopRead(maxPackets: Int32 = 1) throws {
    try mosquitto_loop_read(handle, maxPackets).failable()
  }

  /**
   Carry out network write operations.
   This should only be used if you are not using `loop` and
   are monitoring the client network socket for activity yourself.

   - Parameters:
     - maxPackets: this parameter is currently unused and should be set to 1 for future compatibility.
   */
  public func loopWrite(maxPackets: Int32 = 1) throws {
    try mosquitto_loop_write(handle, maxPackets).failable()
  }

  /**
   Carry out miscellaneous operations required as part of the network loop.
   This should only be used if you are not using `loop` and are
   monitoring the client network socket for activity yourself.

   This function deals with handling PINGs and checking whether messages need
   to be retried, so should be called fairly frequently.
   */
  public func loopMisc() throws {
    try mosquitto_loop_misc(handle).failable()
  }

  /// Returns true if there is data ready to be written on the socket.
  public func wantWrite() -> Bool {
    return mosquitto_want_write(handle)
  }

  /**
   Used to tell the library that your application is using threads, but not using `loopStart`.
   The library operates slightly differently when not in threaded mode in order to simplify its operation.
   If you are managing your own threads and do not use this function you will experience crashes due to race conditions.

   When using `loopStart`, this is set automatically.

   - Parameters:
     - isThreaded: true if your application is using threads, false otherwise.
   */
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

  // MARK: - TLS


  /**
   - filePath: path to a file containing the PEM encoded trusted CA certificate files.
   - dirPath: path to a directory containing the PEM encoded trusted CA certificate files.
   See mosquitto.conf for more details on  configuring this directory.
   - both: specify filePath and dirPath (SMosquitto note: not sure if it is valid option, but source code uses both.
   */
  public enum CAConfig {
    case filePath(String)
    case dirPath(String)
    case both(filePath: String, dirPath: String)

    func extractPaths() -> (filePath: String?, dirPath: String?) {
      switch self {
      case .filePath(let filePath):
        return (filePath, nil)
      case .dirPath(let dirPath):
        return (nil, dirPath)
      case .both(filePath: let filePath, dirPath: let dirPath):
        return (filePath, dirPath)
      }
    }
  }

  public struct ClientSertificateConfig {
    /// Path to a file containing the PEM encoded certificate file.
    public let certificateFilePath: String

    /// path to a file containing the PEM encoded private key for this client.
    public let keyFilePath: String

    public init(certificateFilePath: String, keyFilePath: String) {
      self.certificateFilePath = certificateFilePath
      self.keyFilePath = keyFilePath
    }
  }

  /**
   Configure the client for certificate based SSL/TLS support. Must be called before `connect.
   Cannot be used in conjunction with `setTlsPsk`.
   Define the Certificate Authority certificates to be trusted (ie. the server certificate must be signed
   with one of these certificates) using cafile.
   If the server you are connecting to requires clients to provide a  certificate, define certfile and keyfile
   with your client certificate and private key. If your private key is encrypted, provide a password.

   - Parameters:
     - caConfig: CA certificates configuration.
     - clientCertificateConfig: client certificate config.
     - keyPassword: password for private ket.
   */
  public func setTLS(caConfig: CAConfig,
                     clientCertificateConfig: ClientSertificateConfig?,
                     keyPassword: String? = nil) throws {
    let (caFilePath, caDirPath) = caConfig.extractPaths()
    let (certFilePath, keyFile) = (clientCertificateConfig?.certificateFilePath, clientCertificateConfig?.keyFilePath)

    if let keyPassword = keyPassword {
      self.tlsPassword = keyPassword
      return try mosquitto_tls_set(handle, caFilePath, caDirPath, certFilePath, keyFile,
                                   { (buf: UnsafeMutablePointer<Int8>?, bufSize: Int32, _, callbackHandler) -> Int32 in
                                    let callbackHandlerPointer = unsafeBitCast(callbackHandler, to: OpaquePointer.self)
                                    guard let mosquitto = Instances.unwrapGet(callbackHandlerPointer),
                                      mosquitto.tlsPassword?.isEmpty == .some(false) else {
                                      return 0
                                    }

                                    return mosquitto.tlsPassword?.withCString({ (cTlsPassword) -> Int32 in
                                      let cTlsPasswordLength = Int32(strlen(cTlsPassword))
                                      let copiedSize = cTlsPasswordLength < bufSize ? cTlsPasswordLength : bufSize - 1;
                                      #if os(Linux)
                                      memcpy(buf!, cTlsPassword, Int(copiedSize))
                                      #else
                                      memcpy(buf, cTlsPassword, Int(copiedSize))
                                      #endif
                                      return copiedSize
                                    }) ?? 0
      }).failable()
    }
    else {
      return try mosquitto_tls_set(handle, caFilePath, caDirPath, certFilePath, keyFile, nil).failable()
    }
  }

  /**
   Configure verification of the server hostname in the server certificate. If value is set to true,
   it is impossible to guarantee that the host you are connecting to is not impersonating your server.
   This can be useful in initial server testing, but makes it possible for a malicious third party to impersonate
   your server through DNS spoofing, for example. Do not use this function in a real system. Setting value to true
   makes the connection encryption pointless. Must be called before `connect`.

   - parameter insecure: if set to false, the default, certificate hostname checking is performed.
   If set to true, no hostname checking is performed and the connection is insecure.
   */
  public func setTlsInsecure(_ insecure: Bool) throws {
    try mosquitto_tls_insecure_set(handle, insecure).failable()
  }

  public func setTlsOptions(_ options: TlsOptions) throws {
    try mosquitto_tls_opts_set(handle,
                               options.certificateRequirements.rawValue,
                               options.tlsVersion.rawVersion,
                               options.ciphers?.rawString).failable()
  }

  /**
   Configure the client for pre-shared-key based TLS support. Must be called before `connect`.

   Cannot be used in conjunction with `setTLS`.

   - Parameters:
     - preSharedKey: the pre-shared-key in hex format with no leading "0x".
     - identity: the identity of this client. May be used as the username depending on the server settings.
     - ciphers: a string describing the PSK ciphers available for use.
     See the "openssl ciphers" tool for more information. If nil, the default ciphers will be used.
   */
  public func setTlsPreSharedKey(_ preSharedKey: String,
                                 identity: String,
                                 ciphers: String? = nil) throws {
    try mosquitto_tls_psk_set(handle, preSharedKey, identity, ciphers).failable()
  }

  // MARK: - Other

  /*
   Set the number of QoS atleastOnce and exatlyOnce messages that can be "in flight" at one time.
   An in flight message is part way through its delivery flow. Attempts to send further messages with `publish`
   will result in the messages being queued until the number of in flight messages reduces.

   A higher number here results in greater message throughput, but if set  higher than the maximum in flight messages
   on the broker may lead to delays in the messages being acknowledged.

   Set to 0 for no maximum.

   - Parameters:
     - max_inflight_messages: the maximum number of inflight messages. Defaults to 20.
   */
  public func setMaxInflightMessages(_ maxInflightMessage: UInt32) throws {
    try mosquitto_max_inflight_messages_set(handle, maxInflightMessage).failable()
  }

  public enum ClientOptions {
    /// Must be set before the client connects
    case protocolVersion(ProtocolVersion)
    /**
     Pass an openssl SSL_CTX to be used when creating TLS connections rather than libmosquitto creating its own.
     This must be called  before connecting to have any effect. If you use this option, the onus is on you to ensure
     that you are using secure settings. Setting to NULL means that libmosquitto will use its own SSL_CTX
     if TLS is to be used. This option is only available for openssl 1.1.0 and higher.
     */
    case sslCtx(UnsafeMutableRawPointer?)
    /**
     If true, then the user specified SSL_CTX passed in using `sslCtx` will have the default options applied to it.
     This means that you only need to change the values that are relevant to you. If you use this option then you must
     configure the TLS options as normal, i.e. you should use `setTls` to configure the cafile/capath  as a minimum.
     This option is only available for openssl 1.1.0 and higher.
     */
    case sslCtxWithDefaults(Bool)
  }

  /// Used to set options for the client.
  public func setClientOptions(_ clientOptions: [ClientOptions]) throws {
    for clientOption in clientOptions {
      switch clientOption {
      case .protocolVersion(let protocolVersion):
        var rawProtocolVersion = protocolVersion.rawValue
        try mosquitto_opts_set(handle, MOSQ_OPT_PROTOCOL_VERSION, &rawProtocolVersion).failable()
      case .sslCtx(let sslCtx):
        try mosquitto_opts_set(handle, MOSQ_OPT_SSL_CTX, sslCtx).failable()
      case .sslCtxWithDefaults(let sslCtxWithDefaults):
        var rawSslCtxWithDefaults: Int32 = sslCtxWithDefaults ? 1 : 0;
        try mosquitto_opts_set(handle, MOSQ_OPT_SSL_CTX_WITH_DEFAULTS, &rawSslCtxWithDefaults).failable()
      }
    }
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

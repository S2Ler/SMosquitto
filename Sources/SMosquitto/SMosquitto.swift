import cmosquitto

public class SMosquitto {
  private let handle: OpaquePointer
  public weak var delegate: SMosquittoDelegate?

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

  public func connect(host: String, port: Int32, keepalive: Int32) throws {
    try mosquitto_connect(handle, host, port, keepalive).failable()
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
}

// MARK: - Callbacks
private extension SMosquitto {
  private func setupCallbacks() {
    setupOnConnectCallback()
  }

  private func setupOnConnectCallback() {
    mosquitto_connect_callback_set(handle) { (callbackHandle, _, mosConnectionResponseCode) in
      guard let handle = callbackHandle else { return }
      guard let smosquitto = Instances.get(handle) else { return }
      let code = SMosquitto.ConnectionResponseCode(mosquittoCode: mosConnectionResponseCode)
      smosquitto.delegate?.onConnect(smosquitto, connectionResponseCode: code)
    }
  }
}

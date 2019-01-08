import cmosquitto

public class SMosquitto {
  private let handle: OpaquePointer
  public static func initialize() {
    mosquitto_lib_init();
  }

  public static func cleanup() {
    mosquitto_lib_cleanup();
  }

  public static func version() -> SMosquittoVersion {
    return SMosquittoVersion()
  }

  public init(id: String? = nil, cleanSession: Bool = true) {
    if let id = id {
      self.handle = mosquitto_new(id, cleanSession, nil)
    }
    else {
      self.handle = mosquitto_new(nil, cleanSession, nil)
    }
  }
}

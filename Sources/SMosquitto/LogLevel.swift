import cmosquitto

public extension SMosquitto {
  enum LogLevel: Int32 {
    case none  = 0x00
    case info = 0x01
    case notice = 0x02
    case warning = 0x04
    case error = 0x08
    case debug = 0x10
    case subscribe = 0x20
    case unsubscribe = 0x40
    case websockets = 0x80
    case all = 0xFFFF

    public init?(rawValue: Int32) {
      switch rawValue {
      case MOSQ_LOG_NONE:
        self = .none
      case MOSQ_LOG_INFO:
        self = .info
      case MOSQ_LOG_NOTICE:
        self = .notice
      case MOSQ_LOG_WARNING:
        self = .warning
      case MOSQ_LOG_ERR:
        self = .error
      case MOSQ_LOG_DEBUG:
        self = .debug
      case MOSQ_LOG_SUBSCRIBE:
        self = .subscribe
      case MOSQ_LOG_UNSUBSCRIBE:
        self = .unsubscribe
      case MOSQ_LOG_WEBSOCKETS:
        self = .websockets
      case MOSQ_LOG_ALL:
        self = .all
      default:
        return nil
      }
    }
  }
}

extension SMosquitto.LogLevel: CustomStringConvertible {
  public var description: String {
    switch self {
    case .none:
      return "NONE";
    case .info:
      return "INFO"
    case .notice:
      return "NOTICE"
    case .warning:
      return "WARNING"
    case .error:
      return "ERROR"
    case .debug:
      return "DEBUG"
    case .subscribe:
      return "SUBSCRIBE"
    case .unsubscribe:
      return "UNSUBSCRIBE"
    case .websockets:
      return "WEBSOCKETS"
    case .all:
      return "ALL"
    }
  }
}

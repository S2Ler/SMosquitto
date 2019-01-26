import cmosquitto

public extension SMosquitto {
  enum ConnectionResponseCode: Int32 {
    case success = 0
    case unacceptableProtocolVersion = 1
    case identifierRejected = 2
    case brokerUnavailable = 3
    case unknown = 9999
  }
}

public extension SMosquitto.ConnectionResponseCode {
  init(mosquittoCode: Int32) {
    switch mosquittoCode {
    case 0:
      self = .success
    case 1:
      self = .unacceptableProtocolVersion
    case 2:
      self = .identifierRejected
    case 3:
      self = .brokerUnavailable
    default:
      self = .unknown
    }
  }
}

extension SMosquitto.ConnectionResponseCode: CustomStringConvertible {
  public var description: String {
    if (self == SMosquitto.ConnectionResponseCode.unknown) {
      return "Unknown";
    }
    else {
      return String(cString: mosquitto_connack_string(rawValue))
    }
  }
}

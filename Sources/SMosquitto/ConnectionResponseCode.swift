
public extension SMosquitto {
  public enum ConnectionResponseCode {
    case success
    case unacceptableProtocolVersion
    case identifierRejected
    case brokerUnavailable
    case unknown
  }
}

public extension SMosquitto.ConnectionResponseCode {
  public init(mosquittoCode: Int32) {
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

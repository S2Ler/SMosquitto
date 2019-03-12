import Foundation
import cmosquitto

public extension SMosquitto {
  enum ProtocolVersion {
    case v3_1
    case v3_1_1

    public var rawValue: Int32 {
      switch self {
      case .v3_1:
        return MQTT_PROTOCOL_V31;
      case .v3_1_1:
        return MQTT_PROTOCOL_V311;
      }
    }
  }
}

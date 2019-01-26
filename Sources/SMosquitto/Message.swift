import Foundation
import cmosquitto

public extension SMosquitto {
  struct Message {
    public let id: Identifier<Message>
    public let topic: String
    public let payload: Payload
    public let qos: QOS
    public let retain: Bool

    internal init(_ mosMessage: mosquitto_message) {
      self.id = Identifier<Message>(rawValue: mosMessage.mid)
      self.topic = String(cString: mosMessage.topic)

      payload = SMosquitto.convertRawPayloadToPayload(rawPayload: mosMessage.payload,
                                                      count: Int(mosMessage.payloadlen))
      if let qos = QOS(rawValue: mosMessage.qos) {
        self.qos = qos
      }
      else {
        assertionFailure("Wrong qos: \(mosMessage.qos)")
        qos = .almostOnce
      }

      retain = mosMessage.retain
    }
  }

  private static func convertRawPayloadToPayload(rawPayload: UnsafeMutableRawPointer?,
                                                 count: Int) -> Payload {
    return Payload(rawPayload: rawPayload, count: count)
  }
}

public extension SMosquitto.Message {
  var payloadString: String? {
    get {
      return payload.string
    }
  }
}

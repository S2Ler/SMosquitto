import Foundation
import cmosquitto

public extension SMosquitto {
  public struct Message {
    public let id: Identifier<Message>
    public let qos: QOS
    public let retain: Bool

    internal init(_ mosMessage: mosquitto_message) {
      self.id = Identifier<Message>(rawValue: mosMessage.mid)
      if let qos = QOS(rawValue: mosMessage.qos) {
        self.qos = qos
      }
      else {
        assertionFailure("Wrong qos: \(mosMessage.qos)")
        qos = .almostOnce
      }

      retain = mosMessage.retain
    }
    /*
     struct mosquitto_message{
     int mid;
     char *topic;
     void *payload;
     int payloadlen;
     int qos;
     bool retain;
     };
     */
  }
}

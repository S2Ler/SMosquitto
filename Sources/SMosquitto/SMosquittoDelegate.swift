import Foundation

public protocol SMosquittoDelegate: class {
  func onConnect(_ mosquitto: SMosquitto, connectionResponseCode: SMosquitto.ConnectionResponseCode)
}

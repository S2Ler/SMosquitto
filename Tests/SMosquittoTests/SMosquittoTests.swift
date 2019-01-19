import XCTest
import SMosquitto

internal let mosId = "SMosquittoTests"
internal func obtainConnectedMosquitto() throws -> SMosquitto {
  SMosquitto.initialize()
  let mosquitto = SMosquitto(id: mosId, cleanSession: true)
  try mosquitto.setLoginInformation(username: Env.get(.username),
                                    password: Env.get(.password))
  try mosquitto.connect(host: Env.get(.server), port: Env.get(.port), keepalive:45)
  return mosquitto
}

class SMosquittoTests: XCTestCase {
  func testConnect() throws {
      let mosquitto = try obtainConnectedMosquitto()
      try mosquitto.disconnect()
  }

  func testPublishSubscribe() throws {
    let mosquitto = try obtainConnectedMosquitto()
    try mosquitto.loopStart()

    let messageReceived = expectation(description: "Message Received")
    let messagePayload = "test_message"
    let topic = "SMosquittoTests"

    mosquitto.onMessage = { message in
      if (message.payloadString == messagePayload && message.topic == topic) {
        messageReceived.fulfill()
      }
    }

    mosquitto.onSubscribe = { _ in
      do {
        try mosquitto.publish(topic: topic, payload: SMosquitto.Payload(messagePayload), qos: .exatlyOnce, retain: false)
      }
      catch {
        XCTFail("Failed to publish with error: \(error)")
      }
    }

    try mosquitto.subscribe(subscriptionPattern: topic, qos: .exatlyOnce)

    waitForExpectations(timeout: 5, handler: nil)

    try mosquitto.loopStop(force: true)
  }
}

import XCTest
import SMosquitto

class SMosquittoTests: XCTestCase {
  func testConnect() {
    do {
      SMosquitto.initialize()
      let mosquitto = SMosquitto(id: "SMosquittoTests", cleanSession: true)
      try mosquitto.setLoginInformation(username: Env.get(.username),
                                        password: Env.get(.password))
      try mosquitto.connect(host: Env.get(.server), port: Env.get(.port), keepalive:45)
    }
    catch {
      XCTFail("Error: \(error)")
    }
  }
}

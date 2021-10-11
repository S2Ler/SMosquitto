import XCTest
import cmosquitto
@testable import SMosquitto

private let allLogLevels: [Int64] = [
  Int64(MOSQ_LOG_NONE),
  Int64(MOSQ_LOG_INFO),
  Int64(MOSQ_LOG_NOTICE),
  Int64(MOSQ_LOG_WARNING),
  Int64(MOSQ_LOG_ERR),
  Int64(MOSQ_LOG_DEBUG),
  Int64(MOSQ_LOG_SUBSCRIBE),
  Int64(MOSQ_LOG_UNSUBSCRIBE),
  Int64(MOSQ_LOG_WEBSOCKETS),
  Int64(MOSQ_LOG_ALL),
]

class SMosquittoLogLevelTests: XCTestCase {

  func testCreatable() {
    for logLevel in allLogLevels {
      guard let slogLevel = SMosquitto.LogLevel(rawValue: logLevel) else {
        XCTFail("Can't construct correct log level")
        return
      }
      XCTAssertEqual(slogLevel.rawValue, logLevel)
    }
  }

  func testInvalidLogLevel() {
    XCTAssertNil(SMosquitto.LogLevel(rawValue: 88888))
  }

  func testDescription() {
    for logLevel in allLogLevels {
      guard let slogLevel = SMosquitto.LogLevel(rawValue: logLevel) else {
        XCTFail("Can't construct correct log level")
        return
      }
      XCTAssert(slogLevel.description.count > 0)
    }
  }

}

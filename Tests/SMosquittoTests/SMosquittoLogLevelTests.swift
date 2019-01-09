import XCTest
import cmosquitto
@testable import SMosquitto

private let allLogLevels = [
  MOSQ_LOG_NONE,
  MOSQ_LOG_INFO,
  MOSQ_LOG_NOTICE,
  MOSQ_LOG_WARNING,
  MOSQ_LOG_ERR,
  MOSQ_LOG_DEBUG,
  MOSQ_LOG_SUBSCRIBE,
  MOSQ_LOG_UNSUBSCRIBE,
  MOSQ_LOG_WEBSOCKETS,
  MOSQ_LOG_ALL,
]

class SMosquittoLogLevelTests: XCTestCase {

  func testCreatable() {
    for logLevel in allLogLevels {
      guard let slogLevel = SMosquittoLogLevel(rawValue: logLevel) else {
        XCTFail("Can't construct correct log level")
        return
      }
      XCTAssertEqual(slogLevel.rawValue, logLevel)
    }
  }

  func testInvalidLogLevel() {
    XCTAssertNil(SMosquittoLogLevel(rawValue: 88888))
  }

  func testDescription() {
    for logLevel in allLogLevels {
      guard let slogLevel = SMosquittoLogLevel(rawValue: logLevel) else {
        XCTFail("Can't construct correct log level")
        return
      }
      XCTAssert(slogLevel.description.count > 0)
    }
  }

}

import XCTest
import cmosquitto
@testable import SMosquitto

class SMosquittoErrorTests: XCTestCase {
  func testThatSuccessDoNotThrows() {
    do {
      try MOSQ_ERR_SUCCESS.rawValue.failable()
    }
    catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  func testThatErrorCodeThrows() {
    do {
      try MOSQ_ERR_NOMEM.rawValue.failable()
      XCTFail("Doesn't fail")
    }
    catch {
      // expected
    }
  }

  func testUnknownErrorCode() {
    do {
      try (MosqErrRawValue.max - 1).failable()
      XCTFail("Doesn't fail")
    }
    catch SMosquittoError.unknown {
      // expected
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDescription() {
    XCTAssertEqual(SMosquittoError.unknown.description, "Unknown error.")
  }
}

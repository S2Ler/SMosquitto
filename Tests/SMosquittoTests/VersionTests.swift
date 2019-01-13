import XCTest
import SMosquitto

class SMosquittoVersionTests: XCTestCase {

  func testInSupportedVersionsRange() {
    let version = SMosquitto.version()
    guard version.major == 1 && version.minor >= 4 else {
      XCTFail("Unsupported library version")
      return
    }
  }

  func testCodable() {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let version = SMosquitto.version()
    do {
      let encodedValue = try encoder.encode(version)
      let decodedValue = try decoder.decode(SMosquitto.Version.self, from: encodedValue)
      XCTAssertEqual(decodedValue, version)
    }
    catch {
      XCTFail("Error: \(error)")
    }
  }

  func testHashable() {
    var dict = [SMosquitto.Version: Int]()
    dict[SMosquitto.version()] = 10
    XCTAssertEqual(dict[SMosquitto.version()], 10)
  }

}

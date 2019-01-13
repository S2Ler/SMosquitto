import XCTest
@testable import SMosquitto
import cmosquitto

class InstancesTests: XCTestCase {
  func testGetSet() {
    class Handle {}

    var handle = Handle()
    let pointer = UnsafeMutablePointer(&handle)
    let opaquePointer = OpaquePointer(pointer)

    let smosquitto = SMosquitto(id: nil, cleanSession: true)

    SMosquitto.Instances.set(opaquePointer, smosquitto)
    XCTAssert(SMosquitto.Instances.get(opaquePointer) === smosquitto)
    SMosquitto.Instances.clear(opaquePointer)
    XCTAssertNil(SMosquitto.Instances.get(opaquePointer))
  }
}

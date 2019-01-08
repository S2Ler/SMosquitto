import XCTest

extension SMosquittoErrorTests {
    static let __allTests = [
        ("testDescription", testDescription),
        ("testThatErrorCodeThrows", testThatErrorCodeThrows),
        ("testThatSuccessDoNotThrows", testThatSuccessDoNotThrows),
        ("testUnknownErrorCode", testUnknownErrorCode),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SMosquittoErrorTests.__allTests),
    ]
}
#endif

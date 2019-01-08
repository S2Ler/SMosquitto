import XCTest

extension SMosquittoErrorTests {
    static let __allTests = [
        ("testExample", testExample),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SMosquittoErrorTests.__allTests),
    ]
}
#endif

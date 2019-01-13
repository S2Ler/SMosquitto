import XCTest

extension InstancesTests {
    static let __allTests = [
        ("testGetSet", testGetSet),
    ]
}

extension SMosquittoErrorTests {
    static let __allTests = [
        ("testDescription", testDescription),
        ("testThatErrorCodeThrows", testThatErrorCodeThrows),
        ("testThatSuccessDoNotThrows", testThatSuccessDoNotThrows),
        ("testUnknownErrorCode", testUnknownErrorCode),
    ]
}

extension SMosquittoLogLevelTests {
    static let __allTests = [
        ("testCreatable", testCreatable),
        ("testDescription", testDescription),
        ("testInvalidLogLevel", testInvalidLogLevel),
    ]
}

extension SMosquittoVersionTests {
    static let __allTests = [
        ("testCodable", testCodable),
        ("testHashable", testHashable),
        ("testInSupportedVersionsRange", testInSupportedVersionsRange),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InstancesTests.__allTests),
        testCase(SMosquittoErrorTests.__allTests),
        testCase(SMosquittoLogLevelTests.__allTests),
        testCase(SMosquittoVersionTests.__allTests),
    ]
}
#endif

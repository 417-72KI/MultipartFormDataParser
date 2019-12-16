import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MultipartFormDataSwiftKitTests.allTests),
    ]
}
#endif

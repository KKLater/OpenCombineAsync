import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OpenCombineAsyncTests.allTests),
    ]
}
#endif

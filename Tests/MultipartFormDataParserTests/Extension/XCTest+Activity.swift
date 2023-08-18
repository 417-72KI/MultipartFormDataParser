import XCTest

func runActivity<Result>(named name: String, block: () throws -> Result) rethrows -> Result {
    #if os(Linux)
    return try block()
    #else
    return try XCTContext.runActivity(named: name) { _ in try block() }
    #endif
}

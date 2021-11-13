import XCTest

func runActivity<Result>(named name: String, block: () throws -> Result) rethrows -> Result {
    try XCTContext.runActivity(named: name) { _ in try block() }
}

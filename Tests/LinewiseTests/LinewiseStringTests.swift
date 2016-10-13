import XCTest
import Foundation
@testable import Linewise

class LinewiseStringTests: XCTestCase {
    func testGetLinesFromString() {
        XCTAssertEqual(Array("hi\nhello".lines()), ["hi", "hello"])
    }

    func testEmpty() {
        XCTAssertEqual(Array("".lines()), [])
    }

    func testOneChar() {
        XCTAssertEqual(Array("a".lines()), ["a"])
    }

    func testOneNewline() {
        XCTAssertEqual(Array("\n".lines()), [""])
    }

    func testTrailingNewline() {
        XCTAssertEqual(Array("a\n".lines()), ["a"])
    }

    static var allTests : [(String, (LinewiseStringTests) -> () throws -> Void)] {
        return [
            ("testGetLinesFromString", testGetLinesFromString),
            ("testEmpty", testEmpty),
            ("testOneChar", testOneChar),
            ("testOneNewline", testOneNewline),
            ("testTrailingNewline", testTrailingNewline),
        ]
    }
}

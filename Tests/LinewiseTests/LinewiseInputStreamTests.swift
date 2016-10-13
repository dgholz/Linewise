import XCTest
import Foundation
@testable import Linewise

class LinewiseInputStreamTests: XCTestCase {
    func testGetLinesFromInputStream() {
        let stream = InputStream(data: Data(bytes: Array("hi\nhello".utf8)))
        XCTAssertEqual(Array(stream.lines()), ["hi", "hello"])
    }

    func testEmpty() {
        let stream = InputStream(data: Data(bytes: Array("".utf8)))
        XCTAssertEqual(Array(stream.lines()), [])
    }

    func testOneChar() {
        let stream = InputStream(data: Data(bytes: Array("a".utf8)))
        XCTAssertEqual(Array(stream.lines()), ["a"])
    }

    func testOneNewline() {
        let stream = InputStream(data: Data(bytes: Array("\n".utf8)))
        XCTAssertEqual(Array(stream.lines()), [""])
    }

    func testTrailingNewline() {
        let stream = InputStream(data: Data(bytes: Array("a\n".utf8)))
        XCTAssertEqual(Array(stream.lines()), ["a"])
    }

    static var allTests : [(String, (LinewiseInputStreamTests) -> () throws -> Void)] {
        return [
            ("testGetLinesFromInputStream", testGetLinesFromInputStream),
            ("testEmpty", testEmpty),
            ("testOneChar", testOneChar),
            ("testOneNewline", testOneNewline),
            ("testTrailingNewline", testTrailingNewline),
        ]
    }
}

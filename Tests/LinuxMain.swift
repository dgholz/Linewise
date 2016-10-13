import XCTest
@testable import LinewiseTests

XCTMain([
     testCase(LinewiseInputStreamTests.allTests),
     testCase(LinewiseStringTests.allTests),
])

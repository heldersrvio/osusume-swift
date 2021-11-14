import XCTest
@testable import osusume_swift

final class osusume_swiftTests: XCTestCase {
    func testExample() throws {
        let m = [
            [4.0, 0.0],
            [3.0, -5.0],
        ]
        let eigenValueMatrix = try! getJacobiGetEigenvalues(for: m)
        XCTAssertEqual(eigenValueMatrix[0][0], 40.0, accuracy: 0.001)
        XCTAssertEqual(eigenValueMatrix[0][1], 0.0, accuracy: 0.001)
        XCTAssertEqual(eigenValueMatrix[1][0], 0.0, accuracy: 0.001)
        XCTAssertEqual(eigenValueMatrix[1][1], 10.0, accuracy: 0.001)
    }
}

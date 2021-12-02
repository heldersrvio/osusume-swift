import XCTest
@testable import osusume_swift

final class osusume_swiftTests: XCTestCase {
    func testReduceToBidiagonal() throws {
        
        let m = [
            [12.0, -51.0, 4, 10.0],
            [6, 167, -68, 15.6],
            [-4, 24, -41, 9.9],
            [10.3, 2.5, -0.55, 14.4]
        ]
        let bidiagonalM = reduceToBidiagonal(m)
        XCTAssertEqual(bidiagonalM.count, 4)
        XCTAssertEqual(bidiagonalM[0][2], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[0][3], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[1][0], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[1][3], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[2][0], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[2][1], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[3][0], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[3][1], 0.0, accuracy: 0.0001)
        XCTAssertEqual(bidiagonalM[3][2], 0.0, accuracy: 0.0001)
    }
}

import XCTest
import matrix_utils_swift
@testable import osusume_swift

final class osusume_swiftTests: XCTestCase {
    func testSVDProduct() throws {
        
        let m = [
            [12.0, -51.0, 4, 10.0],
            [6, 167, -68, 15.6],
            [-4, 24, -41, 9.9],
            [10.3, 2.5, -0.55, 14.4]
        ]
    
        let (U, D, VT) = calculateSVD(for: m)
        let product = U * D * VT
        
        XCTAssertEqual(product[0][0], m[0][0], accuracy: 0.0001)
        XCTAssertEqual(product[0][1], m[0][1], accuracy: 0.0001)
        XCTAssertEqual(product[0][2], m[0][2], accuracy: 0.0001)
        XCTAssertEqual(product[0][3], m[0][3], accuracy: 0.0001)
        XCTAssertEqual(product[1][0], m[1][0], accuracy: 0.0001)
        XCTAssertEqual(product[1][1], m[1][1], accuracy: 0.0001)
        XCTAssertEqual(product[1][2], m[1][2], accuracy: 0.0001)
        XCTAssertEqual(product[1][3], m[1][3], accuracy: 0.0001)
        XCTAssertEqual(product[2][0], m[2][0], accuracy: 0.0001)
        XCTAssertEqual(product[2][1], m[2][1], accuracy: 0.0001)
        XCTAssertEqual(product[2][2], m[2][2], accuracy: 0.0001)
        XCTAssertEqual(product[2][3], m[2][3], accuracy: 0.0001)
        XCTAssertEqual(product[3][0], m[3][0], accuracy: 0.0001)
        XCTAssertEqual(product[3][1], m[3][1], accuracy: 0.0001)
        XCTAssertEqual(product[3][2], m[3][2], accuracy: 0.0001)
        XCTAssertEqual(product[3][3], m[3][3], accuracy: 0.0001)
    }
}

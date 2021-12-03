import XCTest
import matrix_utils_swift
@testable import osusume_swift

final class osusume_swiftTests: XCTestCase {
    func testSVDProduct() throws {
        
        let m = [
            [1.0, -2.0],
            [4.0, 8.0],
        ]
    
        let (U, D, VT) = calculateSVD(for: m)
        let product = U * D * VT
        
        XCTAssertEqual(product[0][0], m[0][0], accuracy: 0.0001)
        XCTAssertEqual(product[0][1], m[0][1], accuracy: 0.0001)
        XCTAssertEqual(product[1][0], m[1][0], accuracy: 0.0001)
        XCTAssertEqual(product[1][1], m[1][1], accuracy: 0.0001)
    }
    
    func testSVDValues() throws {
        let m1 = [
            [1.0, -2.0],
            [4.0, 8.0],
        ]
        let m2 = [
            [40.0, -2.5, 20.0],
            [-3.67, 0.4, 13.0],
            [29.0, 104.0, 2.4]
        ]
        let S1 = calculateSVD(for: m1).1
        let S2 = calculateSVD(for: m2).1
        
        XCTAssertEqual(S1[0][0], 9.04838186, accuracy: 0.0001)
        XCTAssertEqual(S1[1][1], 1.768272, accuracy: 0.0001)
        XCTAssertEqual(S2[0][0], 108.42043755, accuracy: 0.0001)
        XCTAssertEqual(S2[1][1], 43.83671985, accuracy: 0.0001)
        XCTAssertEqual(S2[2][2], 13.22836398, accuracy: 0.0001)
    }
}

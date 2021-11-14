import matrix_utils_swift
import Darwin

private func findLargestOffDiagonalElement(for matrix: Matrix) -> (MatrixIndex, Double) {
    return matrix.enumerated().filter { (index, _) in
        index.0 != index.1
    }.reduce(((0, 1), matrix[0][1])) { previous, current in
        let value = current.1
        return value > previous.1 ? current : previous
    }
}

private func jacobiRotate(_ matrix: Matrix, withCosine cosine: Double, withSine sine: Double, withRowIndex rowIndex: Int, withColumnIndex columnIndex: Int) -> Matrix {
    let rotationMatrix = Matrix.buildMatrix(from: Matrix.makeIdentity(ofSize: matrix.count).enumerated().map { pair in
        let index = pair.0
        return
            index.0 == rowIndex ?
                index.1 == rowIndex ?
                    (index, cosine)
                : index.1 == columnIndex ?
                    (index, -sine)
                : pair
            : index.0 == columnIndex ?
                index.1  == rowIndex ?
                    (index, sine)
                : index.1 == columnIndex ?
                    (index, cosine)
                : pair
            : pair
    })
    return (rotationMatrix.transposed() * matrix) * rotationMatrix
}

public func getJacobiGetEigenvalues(for matrix: Matrix, withTolerance tolerance: Double = 2 * Double.ulpOfOne) throws -> [[Double]] {
    var updatedMatrix = matrix
    var max = findLargestOffDiagonalElement(for: matrix)
    
    while (max.1 > tolerance) {
        let maxValue = max.1
        let maxIndex = max.0
        let phi = atan(
            (2 * maxValue) / (matrix[maxIndex.0][maxIndex.0] - matrix[maxIndex.1][maxIndex.1])
        ) / 2
        let sine = sin(phi)
        let cosine = cos(phi)
        updatedMatrix = jacobiRotate(matrix, withCosine: cosine, withSine: sine, withRowIndex: maxIndex.0, withColumnIndex: maxIndex.1)
        max = findLargestOffDiagonalElement(for: updatedMatrix)
    }
    return updatedMatrix
}

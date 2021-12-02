import matrix_utils_swift
import Darwin

private func calculateEuclideanNorm(of vector: Matrix) -> Double {
    let sum = vector.reduce(0) { previous, row in
        previous + row.reduce(0) { previousValue, element in
            previousValue + pow(element, 2)
        }
    }
    return sqrt(sum)
}

private func getHouseholderTransformationMatrix(for vector: Matrix) -> Matrix {
    let columnVector = vector.isColumn ? vector : vector.first!.map { [$0] }
    let e1 = Matrix.buildMatrix(from: columnVector.enumerated().map { $0.0.0 == 0 ? ($0.0, 1.0) : ($0.0, 0.0) })
    let u = columnVector - (columnVector.first!.first! < 0 ? -1 : 1) * calculateEuclideanNorm(of: columnVector) * e1
    let v = (1 / (calculateEuclideanNorm(of: u))) * u
    let transposedV = v.transposed()
    
    return (
        Matrix.makeIdentity(ofSize: columnVector.count) - 2 * v * transposedV
    )
}

private func fill(_ matrix: Matrix, withSize size: Int) -> Matrix {
    if matrix.isSquare && matrix.count == size {
        return matrix
    }
    return Matrix.buildMatrix(from: Matrix.makeIdentity(ofSize: size).enumerated().map { indexValuePair in
        indexValuePair.0.0 > (size - matrix.count - 1) && indexValuePair.0.1 > (size - matrix.first!.count - 1) ? (indexValuePair.0, matrix[indexValuePair.0.0 - (size - matrix.count)][indexValuePair.0.1 - (size - matrix.first!.count)]) : indexValuePair
    })
}

private func transformColumn(_ columnIndex: Int, of matrix: Matrix) -> Matrix {
    let column = matrix.enumerated().filter { $0.0.0 >= columnIndex && $0.0.1 == columnIndex }.map { [$0.1] }
    if column.count <= 1 {
        return matrix
    }
    return fill(getHouseholderTransformationMatrix(for: column), withSize: matrix.count) * matrix
}

private func transformRow(_ rowIndex: Int, of matrix: Matrix) -> Matrix {
    let row = [matrix[rowIndex].enumerated().filter { $0.0 > rowIndex }.map { $0.1 }]
    if row.first!.count <= 1 {
        return matrix
    }
    return matrix * fill(getHouseholderTransformationMatrix(for: row), withSize: matrix.count)
}

private func reduceToBidiagonal(_ matrix: Matrix, fromSize size: Int) -> Matrix {
    if size == 1 {
        return matrix
    }
    let transformedMatrix = transformRow(matrix.count - size, of: transformColumn(matrix.count - size, of: matrix))
    return reduceToBidiagonal(
        transformedMatrix,
        fromSize: size - 1
    )
}

public func reduceToBidiagonal(_ matrix: Matrix) -> Matrix {
    return reduceToBidiagonal(matrix, fromSize: matrix.count)
}

private func QRDecompose(_ matrix: Matrix, fromSize size: Int) -> (Matrix, Matrix) {
    if size == 1 {
        return (Matrix.makeIdentity(ofSize: matrix.count), matrix)
    }
    let columnIndex = matrix.count - size
    let column = matrix.enumerated().filter { $0.0.0 >= columnIndex && $0.0.1 == columnIndex }.map { [$0.1] }
    if column.count <= 1 {
        return (Matrix.makeIdentity(ofSize: matrix.count), matrix)
    }
    let Q = fill(getHouseholderTransformationMatrix(for: column), withSize: matrix.count)
    let R = Q * matrix
    let nextDecomposition = QRDecompose(R, fromSize: size - 1)
    return (Q.transposed() * nextDecomposition.0, nextDecomposition.1)
}

public func QRDecompose(_ matrix: Matrix) -> (Matrix, Matrix) {
    return QRDecompose(matrix, fromSize: matrix.count)
}

private func calculateGivensCoefficients(a: Double, b: Double, withPrecision precision: Double  = Double.ulpOfOne) -> (Double, Double) {
    if abs(b) <= precision {
        return (1.0, 0.0)
    }
    let r = sqrt(a * a + b * b)
    return (a / r, b / r)
}

public func performLeftGivensRotation(on matrix: Matrix, withRotationMatrix rotationMatrix: Matrix, atRow1 row1: Int, atRow2 row2: Int) -> Matrix {
    let matrixSection = Matrix.buildMatrix(from: matrix.enumerated().filter { $0.0.0 == row1 || $0.0.0 == row2 }.map { (($0.0.0 == row1 ? 0 : 1, $0.0.1), $0.1) })
    let rotatedSection = rotationMatrix * matrixSection
    return Matrix.buildMatrix(from: matrix.enumerated().map { $0.0.0 == row1 || $0.0.0 == row2 ? ($0.0, rotatedSection[$0.0.0 == row1 ? 0 : 1][$0.0.1]) : $0 })
}

public func performRightGivensRotation(on matrix: Matrix, withRotationMatrix rotationMatrix: Matrix, atColumn1 column1: Int, atColumn2 column2: Int) -> Matrix {
    let matrixSection = Matrix.buildMatrix(from: matrix.enumerated().filter { $0.0.1 == column1 || $0.0.1 == column2 }.map { (($0.0.0, $0.0.1 == column1 ? 0 : 1), $0.1) })
    let rotatedSection = matrixSection * rotationMatrix
    return Matrix.buildMatrix(from: matrix.enumerated().map { $0.0.1 == column1 || $0.0.1 == column2 ? ($0.0, rotatedSection[$0.0.0][$0.0.1 == column1 ? 0 : 1]) : $0 })
}

//public func calculateSVD(for matrix: Matrix) {
//    var bidiagonalMatrix = reduceToBidiagonal(matrix)
//    print(bidiagonalMatrix)
//    let tridiagonalMatrix = bidiagonalMatrix.transposed() * bidiagonalMatrix
//    print(tridiagonalMatrix)
//    let Q1 = QRDecompose(tridiagonalMatrix).0
//    let R = QRDecompose(tridiagonalMatrix).1
//    print(Q1 * R)
//    print(bidiagonalMatrix * Q1)
//}

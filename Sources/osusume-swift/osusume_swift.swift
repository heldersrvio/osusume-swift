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
    if columnVector.enumerated().allSatisfy({ $0.0.0 == 0 || abs($0.1) <= Double.ulpOfOne }) {
        return Matrix.makeIdentity(ofSize: columnVector.count)
    }
    
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

private func transformColumn(_ columnIndex: Int, of matrix: Matrix) -> (Matrix, Matrix) {
    let column = matrix.enumerated().filter { $0.0.0 >= columnIndex && $0.0.1 == columnIndex }.map { [$0.1] }
    if column.count <= 1 {
        return (matrix, Matrix.makeIdentity(ofSize: matrix.count))
    }
    let transformationMatrix = fill(getHouseholderTransformationMatrix(for: column), withSize: matrix.count)
    return (transformationMatrix * matrix, transformationMatrix)
}

private func transformRow(_ rowIndex: Int, of matrix: Matrix) -> (Matrix, Matrix) {
    let row = [matrix[rowIndex].enumerated().filter { $0.0 > rowIndex }.map { $0.1 }]
    if row.first!.count <= 1 {
        return (matrix, Matrix.makeIdentity(ofSize: matrix.count))
    }
    let transformationMatrix = fill(getHouseholderTransformationMatrix(for: row), withSize: matrix.count)
    return (matrix * transformationMatrix, transformationMatrix)
}

private func reduceToBidiagonal(_ matrix: Matrix, fromSize size: Int) -> (Matrix, Matrix, Matrix) {
    if size == 1 {
        let identity = Matrix.makeIdentity(ofSize: matrix.count)
        return (matrix, identity, identity)
    }
    let (columnTransformedMatrix, columnTransformationMatrix) = transformColumn(matrix.count - size, of: matrix)
    let (rowTransformedMatrix, rowTransformationMatrix) = transformRow(matrix.count - size, of: columnTransformedMatrix)

    let (reducedMatrix, nextColumnTransformationMatrix, nextRowTransformationMatrix) = reduceToBidiagonal(rowTransformedMatrix, fromSize: size - 1)
    return (reducedMatrix, nextColumnTransformationMatrix * columnTransformationMatrix, rowTransformationMatrix * nextRowTransformationMatrix)
}

public func reduceToBidiagonal(_ matrix: Matrix) -> (Matrix, Matrix, Matrix) {
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
    return (a / r, -b / r)
}

private func performLeftGivensRotation(on matrix: Matrix, atElement elementIndex: MatrixIndex) -> (Matrix, Matrix) {
    let row1 = elementIndex.0 - 1
    let row2 = elementIndex.0
    let (c, s) = calculateGivensCoefficients(a: matrix[row1][elementIndex.1], b: matrix[row2][elementIndex.1])
    let rotationMatrix = [
        [c, -s],
        [s, c],
    ]
    
    let matrixSection = Matrix.buildMatrix(from: matrix.enumerated().filter { $0.0.0 == row1 || $0.0.0 == row2 }.map { (($0.0.0 == row1 ? 0 : 1, $0.0.1), $0.1) })
    let rotatedSection = rotationMatrix * matrixSection
    return (
        Matrix.buildMatrix(from: matrix.enumerated().map { $0.0.0 == row1 || $0.0.0 == row2 ? ($0.0, rotatedSection[$0.0.0 == row1 ? 0 : 1][$0.0.1]) : $0 }),
        Matrix.buildMatrix(from: matrix.enumerated().map { ($0.0, ($0.0.0 == row1 && $0.0.1 == row1) || ($0.0.0 == row2 && $0.0.1 == row2) ? c : ($0.0.0 == row1 && $0.0.1 == row2) ? -s : ($0.0.0 == row2 && $0.0.1 == row1) ? s : ($0.0.0 == $0.0.1) ? 1 : 0)
        })
    )
}

private func performRightGivensRotation(on matrix: Matrix, atElement elementIndex: MatrixIndex) -> (Matrix, Matrix) {
    let column1 = elementIndex.1 - 1
    let column2 = elementIndex.1
    let (c, s) = calculateGivensCoefficients(a: matrix[elementIndex.0][column1], b: matrix[elementIndex.0][column2])
    let rotationMatrix = [
        [c, s],
        [-s, c],
    ]
    
    let matrixSection = Matrix.buildMatrix(from: matrix.enumerated().filter { $0.0.1 == column1 || $0.0.1 == column2 }.map { (($0.0.0, $0.0.1 == column1 ? 0 : 1), $0.1) })
    let rotatedSection = matrixSection * rotationMatrix
    return (
        Matrix.buildMatrix(from: matrix.enumerated().map { $0.0.1 == column1 || $0.0.1 == column2 ? ($0.0, rotatedSection[$0.0.0][$0.0.1 == column1 ? 0 : 1]) : $0 }),
        Matrix.buildMatrix(from: matrix.enumerated().map { ($0.0, ($0.0.0 == column1 && $0.0.1 == column1) || ($0.0.0 == column2 && $0.0.1 == column2) ? c : ($0.0.0 == column1 && $0.0.1 == column2) ? s : ($0.0.0 == column2 && $0.0.1 == column1) ? -s : ($0.0.0 == $0.0.1) ? 1 : 0)
        })
    )
}

private func restoreBidiagonality(to matrix: Matrix, atIndex index: Int = 0) -> (Matrix, Matrix, Matrix) {
    let numberOfColumns = matrix.first!.count
    if numberOfColumns < 3 {
        let identity = Matrix.makeIdentity(ofSize: matrix.count)
        let (finalMatrix, GL) = performLeftGivensRotation(on: matrix, atElement: (numberOfColumns - 1, numberOfColumns - 2))
        return (finalMatrix, GL, identity)
    }
    let (bandLeftFixedMatrix, GL) = performLeftGivensRotation(on: matrix, atElement: (index + 1, index))
    let (bandRightFixedMatrix, GR) = performRightGivensRotation(on: bandLeftFixedMatrix, atElement: (index, index + 2))
    
    if index == numberOfColumns - 3 {
        let (finalMatrix, GL2) = performLeftGivensRotation(on: bandRightFixedMatrix, atElement: (numberOfColumns - 1, numberOfColumns - 2))
        return (finalMatrix, GL2 * GL, GR)
    }
    let (restoredMatrix, nextGL, nextGR) = restoreBidiagonality(to: bandRightFixedMatrix, atIndex: index + 1)
    return (restoredMatrix, nextGL * GL, GR * nextGR)
}

private func QREigenDecompose(_ matrix: Matrix, withPrecision precision: Double = Double.ulpOfOne) -> (Matrix, Matrix, Matrix) {
    let tridiagonalMatrix = matrix.transposed() * matrix
    let (Q, _) = QRDecompose(tridiagonalMatrix)
    let (bidiagonalMatrix, GL, GR) = restoreBidiagonality(to: matrix * Q)
    if bidiagonalMatrix.enumerated().allSatisfy({ $0.0.0 == $0.0.1 || abs($0.1) <= precision }) {
        
        return (bidiagonalMatrix, GL, Q * GR)
    }
    let (nextMatrix, nextGL, nextGR) = QREigenDecompose(bidiagonalMatrix, withPrecision: precision)
    
    return (nextMatrix, nextGL * GL, Q * GR * nextGR)
}

public func calculateSVD(for matrix: Matrix) -> (Matrix, Matrix, Matrix) {
    let (bidiagonalMatrix, QBidiagonalL, QBidiagonalR) = reduceToBidiagonal(matrix)
    let (B, L, R) = QREigenDecompose(bidiagonalMatrix, withPrecision: 0.00001)

    return (
        QBidiagonalL.transposed() * L.transposed(),
        B,
        R.transposed() * QBidiagonalR.transposed()
    )
}

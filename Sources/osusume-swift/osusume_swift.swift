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

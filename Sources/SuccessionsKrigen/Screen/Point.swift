//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public struct Point: Equatable {
    public let x: Int
    public let y: Int
}

public extension Point {
    static let zero = Self(x: 0, y: 0)
}

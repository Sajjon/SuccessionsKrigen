//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-27.
//

import Foundation


public struct Point: Equatable, Hashable {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public extension Point {
    static let zero = Self(x: 0, y: 0)
}

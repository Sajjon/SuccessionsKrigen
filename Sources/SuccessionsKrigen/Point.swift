//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-27.
//

import Foundation


public struct Point: Equatable, Hashable {
    
    public let x: Value
    public let y: Value
    public init(x: Value, y: Value) {
        self.x = x
        self.y = y
    }
}

public extension Point {
    
    typealias Value = Int
    
    static let zero = Self(x: 0, y: 0)
}

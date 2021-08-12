//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-11.
//

import Foundation

public extension Map.Tile {
    struct Direction: OptionSet, CustomStringConvertible, CaseIterable {
        
        /// In clockwise order
        public static var allCases: [Map.Tile.Direction] = [.center, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left, .topLeft]
        
        public typealias RawValue = Int
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        // In clockwise order
        static let center       = Self(rawValue: 1 << 0)
        static let top          = Self(rawValue: 1 << 1)
        static let topRight     = Self(rawValue: 1 << 2)
        static let right        = Self(rawValue: 1 << 3)
        static let bottomRight  = Self(rawValue: 1 << 4)
        static let bottom       = Self(rawValue: 1 << 5)
        static let bottomLeft   = Self(rawValue: 1 << 6)
        static let left         = Self(rawValue: 1 << 7)
        static let topLeft      = Self(rawValue: 1 << 8)
    }
}

// MARK: Compound direction
public extension Map.Tile.Direction {
    static let topRow: Self = [.topLeft, .top, .topRight]
    static let bottomRow: Self = [.bottomLeft, .bottom, .bottomRight]
    static let centerRow: Self = [.left, .center, .right]
    
    static let leftColumn: Self = [.topLeft, .left, .bottomLeft]
    static let centerColumn: Self = [.top, .center, .bottom]
    static let rightColumn: Self = [.topRight, .right, .bottomRight]
    
    static let all: Self = [.topRow, .bottomRow, .centerRow]
    static let around: Self = [.topRow, .bottomRow, .left, .right]
    
    static let topRightCorner: Self = [.top, .topRight, .right]
    static let topLeftCorner: Self = [.top, .topLeft, .left]
    
    static let bottomRightCorner: Self = [.bottom, .bottomRight, .right]
    static let bottomLeftCorner: Self = [.bottom, .bottomLeft, .left]
    
    static let allCorners: Self = [.topRight, .bottomRight, .bottomLeft, .topLeft]
}


// MARK: CustomStringConvertible
public extension Map.Tile.Direction {
    var description: String {
        var directions = [String]()
        if contains(.center) {
            directions.append("center")
        }
        if contains(.top) {
            directions.append("top")
        }
        if contains(.topRight) {
            directions.append("top right")
        }
        if contains(.right) {
            directions.append("right")
        }
        if contains(.bottomRight) {
            directions.append("bottom right")
        }
        if contains(.bottom) {
            directions.append("bottom")
        }
        if contains(.bottomLeft) {
            directions.append("bottom left")
        }
        if contains(.left) {
            directions.append("left")
        }
        if contains(.topLeft) {
            directions.append("top left")
        }
        return directions.joined(separator: ", ")
    }
}

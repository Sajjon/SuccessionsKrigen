//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    enum Color: UInt8, Equatable, CaseIterable, CustomStringConvertible {
        
        public static var allCases: [Map.Color] = [.blue, .green, .red, .yellow, .orange, .purple]
        
        case none = 0x00,
             blue = 0x01,
             green = 0x02,
             red = 0x04,
             yellow = 0x08,
             orange = 0x10,
             purple = 0x20
        //             unused = 0x80,
        //             ALL = BLUE | GREEN | RED | YELLOW | ORANGE | PURPLE
    }
    
}

public extension Map.Color {
    
    var description: String {
        switch self {
        case .none: return "None"
        case .blue: return "Blue"
        case .green: return "Green"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .orange: return "Orange"
        case .purple: return "Purple"
        }
    }
}

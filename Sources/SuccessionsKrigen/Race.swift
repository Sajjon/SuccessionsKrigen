//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation



public enum Race: UInt8, Equatable, CustomStringConvertible {
    case knight, barbarian, sorceress, warlock, wizard, necromancer
    
    /// "multi"
    case freeChoice
    case random
    
    /// "none"
    case neutral
}

public extension Race {
    
    var description: String {
        switch self {
        case .knight: return "Knight"
        case .barbarian: return "Barbarian"
        case .sorceress: return "Sorceress"
        case .warlock: return "Warlock"
        case .wizard: return "Wizard"
        case .necromancer: return "Necromancer"
        case .freeChoice: return "FreeChoice"
        case .random: return "Random"
        case .neutral: return "Neutral"
        }
    }
}

private extension Race {
    static let castleIncrement: UInt8 = 0x80
}
public extension Race {
    
    init?(id rawValue: UInt8) {
        let raw = rawValue >= Self.castleIncrement ? rawValue - Self.castleIncrement : rawValue
        self.init(rawValue: raw)
    }
}


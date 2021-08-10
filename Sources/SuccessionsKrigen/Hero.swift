//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


public enum Hero: Equatable {
    case knight(Knight)
    case barbarian(Barbarian)
    case sorceress(Sorceress)
    case warlock(Warlock)
    case wizard(Wizard)
    case necromancer(Necromancer)
}

public extension Hero {
    
    enum Knight: Int, Equatable, CaseIterable {
        case lordKilburn = 0, dimitry = 8
    }
    
    enum Barbarian: Int, Equatable, CaseIterable {
        case thundax = 9, atlas = 17
    }
    
    enum Sorceress: Int, Equatable, CaseIterable {
        case astra = 18, luna = 27
    }
    
    enum Warlock: Int, Equatable, CaseIterable {
        case arie = 27, wrathmont = 35
    }
    
    enum Wizard: Int, Equatable, CaseIterable {
        case myra = 36, mandigal = 44
    }
    
    enum Necromancer: Int, Equatable, CaseIterable {
        case zom = 45, celia = 53
    }
    
    static func randomFreeman(race: Race) -> Self {
        switch race {
        case .knight: return .knight(.random())
        case .barbarian: return .barbarian(.random())
        case .sorceress: return .sorceress(.random())
        case .warlock: return .warlock(.random())
        case .wizard: return .wizard(.random())
        case .necromancer: return .necromancer(.random())
        case .random, .freeChoice, .neutral:
            fatalError()
        }
    }
    
    var id: Int {
        switch self {
        case .knight(let hero): return hero.rawValue
        case .barbarian(let hero): return hero.rawValue
        case .sorceress(let hero): return hero.rawValue
        case .warlock(let hero): return hero.rawValue
        case .wizard(let hero): return hero.rawValue
        case .necromancer(let hero): return hero.rawValue
        }
    }
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


public extension Map.Hero {
    enum SecondarySkillType: Int, Equatable {
        case pathfinding = 1,
             archery = 2,
             logistics = 3,
             scouting = 4,
             diplomacy = 5,
             navigation = 6,
             leadership = 7,
             wisdom = 8,
             mysticism = 9,
             luck = 10,
             ballistics = 11,
             eagleEye = 12,
             necromancy = 13,
             estates = 14
    }
    
    enum SecondarySkillLevel: Int, Equatable {
        case basic = 1, advanced, expert
    }
    
    struct SecondarySkill: Equatable {
        let skillType: SecondarySkillType
        let level: SecondarySkillLevel
    }
}

public extension Map.Hero.SecondarySkillType {
    static let learning = eagleEye
}

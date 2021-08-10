//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


public extension Map {

    enum DefeatCondition: Equatable {
        case loseAllHeroesAndTowns
        case loseSpecificTownLocated(at: WorldPosition)
        case loseSpecificHeroLocated(at: WorldPosition)
        case runOutOfTime(deadline: Map.Date)
    }
}

public extension Map.DefeatCondition {
    enum Stripped: UInt8, Equatable, CaseIterable, CustomStringConvertible {
        case loseAllHeroesAndTowns = 0, loseSpecificTown, loseSpecificHero, runOutOfTime
    }
    
    init?(stripped: Stripped?, parameter1: Int = -1, parameter2: Int = -1) {
        guard let condition = stripped else { return nil }
        func position() -> WorldPosition {
            precondition(parameter1 >= 0)
            precondition(parameter2 >= 0)
            return .init(x: parameter1, y: parameter2)
        }
        switch condition {
        case .loseAllHeroesAndTowns: self = .loseAllHeroesAndTowns
        case .loseSpecificTown: self = .loseSpecificTownLocated(at: position())
        case .loseSpecificHero: self = .loseSpecificHeroLocated(at: position())
        case .runOutOfTime:
            let daysLeft = parameter1 - 1
            self = .runOutOfTime(deadline: .in(daysLeft, .days))
        }
    }
}

public extension Map.DefeatCondition.Stripped {
    var description: String {
        switch self {
        case .loseAllHeroesAndTowns: return "Lose all your heroes and towns."
        case .loseSpecificHero: return "Lose a specific hero."
        case .loseSpecificTown: return "Lose a specific town."
        case .runOutOfTime: return "Run out of time. Fail to win by a certain point."
        }
    }
}

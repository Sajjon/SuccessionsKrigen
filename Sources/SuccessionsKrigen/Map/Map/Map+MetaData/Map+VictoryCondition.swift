//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    enum VictoryCondition: Equatable {
        case defeatAllEnemyHeroesAndTowns
        case captureSpecificTownLocated(at: WorldPosition)
        case defeatSpecificHeroLocated(at: WorldPosition)
        case findSpecificArtifact(Artifact)
        case defeatOtherTeam
        case accumlateGoldAmount(Resource.Quantity)
    }
}

// MARK: Init
public extension Map.VictoryCondition {
    
    init(stripped: Stripped, parameter1: Int = -1, parameter2: Int = -1) {
        func position() -> WorldPosition {
            precondition(parameter1 >= 0)
            precondition(parameter2 >= 0)
            return .init(x: parameter1, y: parameter2)
        }
        switch stripped {
        case .accumlateGoldAmount:
            precondition(parameter1 >= 0)
            self = .accumlateGoldAmount(parameter1 * 1000)
            
        case .captureSpecificTown: self = .captureSpecificTownLocated(at: position())
        case .findSpecificArtifact:
            precondition(parameter1 >= 0)
            guard let artifact = Artifact(rawValue: UInt8(parameter1 - 1)) else {
                fatalError("Unknown artifact")
            }
            self = .findSpecificArtifact(artifact)
        case .defeatSpecificHero: self = .defeatSpecificHeroLocated(at: position())
        case .defeatAllEnemyHeroesAndTowns: self = .defeatAllEnemyHeroesAndTowns
        case .defeatOtherTeam: self = .defeatOtherTeam
        }
    }
}

// MARK: Stripped
public extension Map.VictoryCondition {
    enum Stripped: UInt8, Equatable, CaseIterable, CustomStringConvertible {
        case defeatAllEnemyHeroesAndTowns = 0, captureSpecificTown, defeatSpecificHero, findSpecificArtifact, defeatOtherTeam, accumlateGoldAmount
    }
}

// MARK: Stripped + CustomStringConvertible
public extension Map.VictoryCondition.Stripped {
    var description: String {
        switch self {
        case .defeatAllEnemyHeroesAndTowns: return "Defeat all enemy heroes and towns."
        case .captureSpecificTown: return "Capture a specific town."
        case .defeatSpecificHero: return "Defeat a specific hero."
        case .findSpecificArtifact: return "Find a specific artifact."
        case .defeatOtherTeam: return "Your side defeats the opposing side."
        case .accumlateGoldAmount: return "Accumulate a large amount of gold."
        }
    }
}





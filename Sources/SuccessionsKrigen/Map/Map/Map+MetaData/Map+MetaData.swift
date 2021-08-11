//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    
    typealias Colors = [Map.Color]
    
    struct MetaData: Equatable {
        let fileName: String
        let name: String
        let description: String
        let size: Size
        let difficulty: Difficulty
        
        
        let kingdomColors: Colors
        let humanPlayableColors: Colors
        let computerPlayableColors: Colors
        
        let victoryCondition: VictoryCondition
        let defeatCondition: DefeatCondition?
        let computerCanWinUsingVictoryCondition: Bool
        let victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns: Bool
        let isStartingWithHeroInEachCastle: Bool
        let racesByColor: [Map.Color: Race]
        let expansionPack: ExpansionPack?
    }
}

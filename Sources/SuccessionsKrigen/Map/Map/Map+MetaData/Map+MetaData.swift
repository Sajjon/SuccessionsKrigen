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
        public let fileName: String
        public let name: String
        public let description: String
        public let size: Size
        public let difficulty: Difficulty
        
        
        public let kingdomColors: Colors
        public let humanPlayableColors: Colors
        public let computerPlayableColors: Colors
        
        public let victoryCondition: VictoryCondition
        public let defeatCondition: DefeatCondition?
        let computerCanWinUsingVictoryCondition: Bool
        let victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns: Bool
        let isStartingWithHeroInEachCastle: Bool
        public let racesByColor: [Map.Color: Race]
        let expansionPack: ExpansionPack?
    }
}

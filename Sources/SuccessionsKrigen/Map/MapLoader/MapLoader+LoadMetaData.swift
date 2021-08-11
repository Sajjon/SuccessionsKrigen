//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


private extension MapLoader {
    static let homm2MapFileIdentifier: UInt32 = 0x5C000000
    static let mapNameByteCount = 16
    static let mapDescriptionByteCount = 143
}

public extension MapLoader {
    
    
    func loadMapMetaData(filePath mapFilePath: String) throws -> Map.MetaData {
        guard let contentsRaw = FileManager.default.contents(atPath: mapFilePath) else {
            throw Error.fileNotFound
        }
        let fileName = String(mapFilePath.split(separator: "/").last!)
        return try loadMapMetaData(rawData: contentsRaw, fileName: fileName)
    }
 
    // MARK: Load Map MetaData
    func loadMapMetaData(rawData contentsRaw: Data, fileName: String) throws -> Map.MetaData {
        let dataReader = DataReader(data: contentsRaw)
        
        // Check (mp2, mx2) ID
        guard try dataReader.readUInt32(endianess: .big) == Self.homm2MapFileIdentifier else {
            throw Error.notHomm2MapFile
        }
        
        
        let difficultyRaw = Int(try dataReader.readUInt16())
        let difficulty = Map.Difficulty(rawValue: difficultyRaw) ?? .normal
        
        let width = Int(try dataReader.readInt8())
        let height = Int(try dataReader.readInt8())
        guard width == height else { throw Error.mapMustBeSquared }
        let size = Map.Size(rawValue: width)!
        
        
        let kingdomColors: [Map.Color] = try Map.Color.allCases.compactMap { color in
            guard try dataReader.readUInt8() != 0 else {
                return nil
            }
            return color
        }
        
        let humanPlayableColors: [Map.Color] = try Map.Color.allCases.compactMap { color in
            guard try dataReader.readUInt8() != 0 else {
                return nil
            }
            return color
        }
        
        let computerPlayableColors: [Map.Color] = try Map.Color.allCases.compactMap { color in
            guard try dataReader.readUInt8() != 0 else {
                return nil
            }
            return color
        }
        
        assert(humanPlayableColors.allSatisfy({ kingdomColors.contains($0) }))
        assert(computerPlayableColors.allSatisfy({ kingdomColors.contains($0) }))
        
        
        try dataReader.seek(to: 0x1D)
        let victoryConditionRaw = try dataReader.readUInt8()
        guard let victoryConditionStripped = Map.VictoryCondition.Stripped(rawValue: victoryConditionRaw) else {
            fatalError("Unrecognized victory condition")
        }
        
        
        let computerCanWinUsingVictoryCondition = try dataReader.readUInt8() != 0
        
        let victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns = try dataReader.readUInt8() != 0
        let victoryCondition = Map.VictoryCondition(
            stripped: victoryConditionStripped,
            parameter1: .init(try dataReader.readUInt16()),
            parameter2: .init(try dataReader.readUInt16())
        )
        
        
        // Defeat condition
        try dataReader.seek(to: 0x22)
        
        let defeatConditionRaw = try dataReader.readUInt8()
        
        let defeatConditionStripped: Map.DefeatCondition.Stripped? = .init(rawValue: defeatConditionRaw)
        let defeatCondition: Map.DefeatCondition? = try {
            let defeatConditionParameter1 = try dataReader.readUInt16()
            try dataReader.seek(to: 0x2e)
            let defeatConditionParameter2 = try dataReader.readUInt16()
            return Map.DefeatCondition(
                stripped: defeatConditionStripped,
                parameter1: .init(defeatConditionParameter1),
                parameter2: .init(defeatConditionParameter2)
            )
        }()
        
        // start with hero
        try dataReader.seek(to: 0x25)
        let isStartingWithHeroInEachCastle = try dataReader.readUInt8() == 0
        
        
        // race color
        let racesByColor: [Map.Color: Race] = try Dictionary(
            uniqueKeysWithValues: Map.Color.allCases.map { color -> (Map.Color, Race) in
                let raceRaw = try dataReader.readUInt8()
                let race = Race(rawValue: raceRaw) ?? .neutral
                return (color, race)
            }
        )
        
        // Name
        try dataReader.seek(to: 0x3a)
        let name = try dataReader.readString(byteCount: Self.mapNameByteCount)
        
        // Desription
        try dataReader.seek(to: 0x76)
        let description = try dataReader.readString(byteCount: Self.mapDescriptionByteCount)
        
        let expansionPack: ExpansionPack? = fileName.split(separator: ".").last! == ExpansionPack.princeOfLoyalty.mapFileExtension ? ExpansionPack.princeOfLoyalty : nil
        return .init(
            fileName: fileName,
            name: name,
            description: description,
            size: size,
            difficulty: difficulty,
            kingdomColors: kingdomColors,
            humanPlayableColors: humanPlayableColors,
            computerPlayableColors: computerPlayableColors,
            victoryCondition: victoryCondition,
            defeatCondition: defeatCondition,
            computerCanWinUsingVictoryCondition: computerCanWinUsingVictoryCondition,
            victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns: victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns,
            isStartingWithHeroInEachCastle: isStartingWithHeroInEachCastle,
            racesByColor: racesByColor,
            
            expansionPack: expansionPack
        )
    }
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-04.
//

import Foundation

public struct MapLoader {
    public init() {}
}

// MARK: Constants
private extension MapLoader {
    static let offsetData = 428
    static let sizeOfTile = 20
}


// MARK: Error
public extension MapLoader {
    
    enum Error: Swift.Error {
        case fileNotFound
        case notHomm2MapFile
        case parseWidthFailed
        case parseHeightFailed
        case mapMustBeSquared
        case unrecognizedRace(Race.RawValue)
    }
}

// MARK: Load Map
public extension MapLoader {
    func loadMap(filePath mapFilePath: String) throws -> Map {
        guard let contentsRaw = FileManager.default.contents(atPath: mapFilePath) else {
            throw Error.fileNotFound
        }
        
        let metaData = try loadMapMetaData(filePath: mapFilePath)
        let dataReader = DataReader(data: contentsRaw)
        
        
        // Read unique
        try dataReader.seek(to: contentsRaw.count - 4)
        let unique = Int(try dataReader.readUInt32())
        
        
        try dataReader.seek(to: Self.offsetData - 2 * 4) /* From `fheroes2`... why `- 2 * 4` ? */
        
        let widthTypeRaw = try Int(dataReader.readUInt32())
        guard let widthType = Map.Size(rawValue: widthTypeRaw) else {
            throw Error.parseWidthFailed
        }
        
        let width = widthType.rawValue
        
        let heightTypeRaw = try Int(dataReader.readUInt32())
        guard let heightType = Map.Size(rawValue: heightTypeRaw) else {
            throw Error.parseHeightFailed
        }
        
        let height = heightType.rawValue
        
        guard width == height else {
            throw Error.mapMustBeSquared
        }
        
        let worldSize = width * height
        let mapSize = heightType // or width... same since squared
        
        // seek to ADDONS block
        try dataReader.skip(byteCount: worldSize * Self.sizeOfTile)
        
        // Read all addons
        var addsLeftToParse = try Int(dataReader.readUInt32())
        var addOns: [Map.AddOn] = []
        while addsLeftToParse > 0 {
            defer { addsLeftToParse -= 1 }
            let addOn = try dataReader.readMapAddOn()
            addOns.append(addOn)
            
        }
        let addOnsEndIndex = dataReader.offset
        
        
        // Offset data
        try dataReader.seek(to: Self.offsetData)
        
        /// Objects of following types: .castle, .heroes, .sign, .bottle, .event
        var objects = [Map.Object]()
        
        // Read all tiles
        let mapTiles: [Map.Tile] = try dataReader.readMapTiles(worldSize: worldSize, worldWidth: width, addOns: addOns)
        mapTiles.forEach {
            let mapTileInfo = $0.info
            switch mapTileInfo.objectType {
            case .randomTown, .randomCastle, .castle, .heroes, .sign, .bottle, .event, .sphinx, .jail:
                objects.append(.init(objectType: mapTileInfo.objectType, worldPosition: $0.worldPosition)) //[$0.worldPosition] = mapTileInfo.objectType
                break
            default: break
            }
        }
        
        try dataReader.seek(to: addOnsEndIndex)
        
        var captureObjects = Map.CapturedObjects()
        let castlesSimple: [Map.Castle.Simple] = try dataReader.readMapCastlesSimple(captureObjects: &captureObjects)
        assert(dataReader.offset == addOnsEndIndex + DataReader.numberOfCastleCoordinates*3)
        
        try dataReader.readMapCapturableObject(captureObjects: &captureObjects, mapSize: mapSize)
        
        try dataReader.seek(to: addOnsEndIndex + (Map.Size.extraLarge.rawValue + Map.Size.medium.rawValue) * 3) // even though map might be small, the next data always starts 144*3 bytes from `minesStartIndex`
        
        // byte: num obelisks (01 default)
        try dataReader.skip(byteCount: 1)
        
        // Count final mp2 blocks
        let blockCount = try dataReader.readMapBlockCount()
        
        // Castle, heroes or (events, rumors, etc)
        var kingsdoms: [Kingdom] = metaData.racesByColor.map({ Kingdom.init(color: $0.key, race: $0.value, heroes: []) })
        let castlesHeroesEventsRumorsEtc = try dataReader.readCastlesHeroesEventsRumorsEtc(
            worldBlockCount: blockCount,
            tiles: mapTiles,
            objects: objects,
            simpleCastles: castlesSimple,
            difficulty: metaData.difficulty,
            kingdoms: &kingsdoms
        )
        
        let unproccesedMap = try Map(
            metaData: metaData,
            unique: unique,
            tiles: mapTiles,
            heroes: castlesHeroesEventsRumorsEtc.heroes,
            castles: castlesHeroesEventsRumorsEtc.castles,
            kingdoms: kingsdoms,
            rumors: castlesHeroesEventsRumorsEtc.rumors,
            eventsDay: castlesHeroesEventsRumorsEtc.events,
            capturedObjects: captureObjects,
            signEventRiddles: castlesHeroesEventsRumorsEtc.signEventRiddle
        )
        
        let processedMap = process(map: unproccesedMap)
        
        let postLoaded = postLoad(map: processedMap)
        
        return postLoaded
        
    }
    
    func process(map: Map) -> Map {
        map.processed()
    }
    
    func postLoad(map: Map) -> Map {
        map.postLoaded()
    }
}

// MARK: Read Map.AddOn
private extension DataReader {
    func readMapAddOn() throws -> Map.AddOn {
        
        let nextAddOnIndex = try readUInt16()
        let objectNameN1 = Int(try readUInt8()) * 2 // why *2 ?
        let indexNameN1 = try readUInt8()
        let quantityN = try readUInt8()
        let objectNameN2 = try readUInt8()
        let indexNameN2 = try readUInt8()
        
        let level1ObjectUID = try readUInt32()
        let level2ObjectUID = try readUInt32()
        
        let level1 = Map.Level(
            object: objectNameN1,
            index: .init(indexNameN1),
            uid: .init(level1ObjectUID),
            quantity: nil
        )
        
        let level2 = Map.Level(
            object: .init(objectNameN2),
            index: .init(indexNameN2),
            uid: .init(level2ObjectUID),
            quantity: nil
        )
        
        return .init(
            level1: level1,
            level2: level2,
            nextAddOnIndex: .init(nextAddOnIndex),
            quantityN: .init(quantityN)
        )
    }
}



// MARK: Read Map.Tile
private extension DataReader {
    func readMapTiles(worldSize: Int, worldWidth: Int, addOns: [Map.AddOn]) throws -> [Map.Tile] {
        
        var mapTiles = [Map.Tile]()
        for worldPositionIndex in 0..<worldSize {
            let qr = worldPositionIndex.quotientAndRemainder(dividingBy: worldWidth)
            let worldPositionX = qr.remainder
            let worldPositionY = qr.quotient
            let worldPosition: WorldPosition = .init(x: worldPositionX, y: worldPositionY)
            let tileInfoWithoutAddons = try readMapTileInfo()
            
            
            // Read extra information if it's present.
            var addOnIndex = tileInfoWithoutAddons.nextAddonIndex
            if worldPositionIndex == 1 {
                print("nextAddOnIndex: \(addOnIndex), tile.info: \(tileInfoWithoutAddons)")
            }
            var level1Addons = [Map.AddOn]()
            var level2Addons = [Map.AddOn]()
            while addOnIndex > 0 {
                guard
                    addOnIndex <= addOns.count
                else {
                    break
                }
                let addOn = addOns[addOnIndex]
                level1Addons.append(addOn)
                level2Addons.append(addOn) // Cyon: is this correct? same AddOn added to arrays level1 and level2 ??
                addOnIndex = addOn.nextAddOnIndex
                if worldPositionIndex == 1 {
                    print("\n\n\n\naddOn: \(addOn), \n\nnextAddOnIndex: \(addOnIndex)")
                }
            }
            
            let mapTileInfoWithAddons = Map.Tile.Info(
                info: tileInfoWithoutAddons,
                replacementLevel1AddOns: level1Addons,
                replacementLevel2AddOns: level2Addons
            )
            
            let mapTile = Map.Tile(
                index: worldPositionIndex,
                worldPosition: worldPosition,
                info: mapTileInfoWithAddons
            )
            
            if worldPositionIndex == 1 {
                print("mapTile before fix: \(mapTile.debugDescription)")
            }
            
            let fixedTile = mapTile.withSortedAddonsAndVariousFixes()
            if worldPositionIndex == 1 {
                print("mapTile after fix: \(fixedTile.debugDescription)")
            }
            mapTiles.append(fixedTile)
        }
        
        return mapTiles
    }
}

// MARK: Read Map.Castle.Simple
private extension DataReader {
    static let numberOfCastleCoordinates = 72
    func readMapCastlesSimple(captureObjects: inout Map.CapturedObjects) throws -> [Map.Castle.Simple] {
        
        // Coordinates for castles
        // 72 x 3 byte (x, y, id)
        var simpleCastles = [Map.Castle.Simple]()
        for _ in 0..<Self.numberOfCastleCoordinates {
            let x = try readUInt8()
            let y = try readUInt8()
            let raceId = try readUInt8()
            guard !(x == 0xff && y == 0xff) else { /* Empty block */ continue }
            let worldPosition = WorldPosition(x: Int(x), y: Int(y))
            
            
            guard let race = Race(id: raceId) else { throw MapLoader.Error.unrecognizedRace(raceId) }
            let castle = Map.Castle.Simple(race: race, worldPosition: worldPosition)
            simpleCastles.append(castle)
            
            // Preload in to capture objects cache
            captureObjects = captureObjects.capture(objectOfType: .castle, at: worldPosition, by: .none)
        }
        return simpleCastles
    }
}


// MARK: Capturables Mines, Lighthouse
private extension DataReader {
    
    /// Temporary
    enum MineLighthouseOrDragonCity: UInt8, Equatable {
        case sawmill, alchemyLab, oreMine, sulfurMine, crystalMine, gemMine, goldMine
        case lighthouse = 0x64
        case dragonCity = 0x65
        case abandonedMine = 0x67
        
        var objectMapType: Map.Tile.Info.ObjectType {
            switch self {
            case .sawmill: return .sawmill
            case .alchemyLab: return .alchemyLab
            case .oreMine, .sulfurMine, .crystalMine, .gemMine, .goldMine: return .mines
            case .lighthouse: return .lighthouse
            case .dragonCity: return .dragonCity
            case .abandonedMine: return .abandonedMine
            }
        }
    }
    
    /// e.g. "mines" and "lighthouse"
    func readMapCapturableObject(captureObjects: inout Map.CapturedObjects, mapSize: Map.Size) throws {
        // MAPSIZE x 3 byte (x, y, id)
        for _ in 0..<mapSize.rawValue {
            let x = try readUInt8()
            let y = try readUInt8()
            let mineId = try readUInt8()
            
            guard !(x == 0xff && y == 0xff) else { /* Empty block */ continue }
            let worldPosition = WorldPosition(x: Int(x), y: Int(y))
            
            guard let capturableObject = MineLighthouseOrDragonCity(rawValue: mineId) else { fatalError("Unrecognized capturable object") }
            
            captureObjects = captureObjects.capture(
                objectOfType: capturableObject.objectMapType,
                at: worldPosition,
                by: .none
            )
            
        }
    }
}

// MARK: Read Map.Tile.Info
private extension DataReader {
    func readMapTileInfo() throws -> Map.Tile.Info {
        
        let tileIndex = try readUInt16()
        let objectName1 = try readUInt8()
        let indexName1 = try readUInt8()
        let quantity1 = try readUInt8()
        let quantity2 = try readUInt8()
        let objectName2 = try readUInt8()
        let indexName2 = try readUInt8()
        let flags = try readUInt8()
        let mapObjectTypeRaw = try readUInt8()
        
        guard let objectType = Map.Tile.Info.ObjectType(rawValue: mapObjectTypeRaw) else {
            //            fatalError("Found mapObject with value \(mapObjectTypeRaw) at tileIndex: \(tileIndex)")
            throw Map.Tile.Info.Error.unknownObjectType(mapObjectTypeRaw)
        }
        //        if objectType == .nothing {
        //            print("Found mapObject with value \(objectType.rawValue) at tileIndex: \(tileIndex)")
        //        }
        
        let nextAddonIndex = try readUInt16()
        let level1ObjectUID = try readUInt32()
        let level2ObjectUID = try readUInt32()
        
        let level1 = Map.Level(
            object: .init(objectName1),
            index: .init(indexName1),
            uid: .init(level1ObjectUID),
            quantity: .init(quantity1)
        )
        
        let level2 = Map.Level(
            object: .init(objectName2),
            index: .init(indexName2),
            uid: .init(level2ObjectUID),
            quantity: .init(quantity2)
        )
                
        return .init(
            tileIndex: .init(tileIndex),
            level1: level1,
            level2: level2,
            flags: .init(flags),
            objectType: objectType,
            nextAddonIndex: .init(nextAddonIndex),
            unique: 0,
            level1AddOns: [],
            level2AddOns: []
        )
    }
}


// MARK: Read Map.Hero
private extension DataReader {
    
    func readHero(heroType: SuccessionsKrigen.Hero, worldPosition: WorldPosition) throws -> Map.Hero {
        try skip(byteCount: 1) // unknown
        let hasCustomTroops = try readUInt8()
        let army: Map.Hero.Army
        let numberOfTroopSlots = 5
        if hasCustomTroops > 0 {
            let troopCreatures: [Creature] = try (0..<numberOfTroopSlots).map { _ -> Creature in
                let rawCreature = try readUInt8() + 1
                guard let creature = Creature(rawValue: Int(rawCreature)) else {
                    fatalError("Failed to read creature")
                }
                return creature
            }
            let quantities: [Troop.Quantity] = try (0..<numberOfTroopSlots).map { _ -> Troop.Quantity in
                .init(try readUInt16())
            }
            
            assert(quantities.count == troopCreatures.count)
            let troops: [Troop] = zip(troopCreatures, quantities).map {
                .init(creatureType: $0.0, quantity: $0.1)
            }
            army = .init(troops: troops)
        } else {
            try skip(byteCount: numberOfTroopSlots * 3)
            army = .init(troops: [])
        }
        
        let hasCustomPortrait = try readUInt8() != 0
        let portraitRawId: Int
        if hasCustomPortrait {
            portraitRawId = .init(try readUInt8())
        } else {
            portraitRawId = heroType.id
            try skip(byteCount: 1)
        }
        
        let artifactCount = 3
        let artifacts = try (0..<artifactCount).map { _ -> Artifact in
            let artifactRawId = try readUInt8()
            guard let artifact = Artifact(rawValue: artifactRawId) else {
                fatalError("unknown artifact")
            }
            return artifact
        }
        
        try skip(byteCount: 1) // unknown
        
        let experiencePointsRaw = Int(try readUInt32())
        let experiencePoints = max(experiencePointsRaw, Map.Hero.randomStartingExperiencePointCount())
        
        let hasCustomSecondarySkill = try readUInt8() != 0
        
        let secondarySkillTypeStartingMaxRawValue = 8
        let secondarySkills: [Map.Hero.SecondarySkill]
        if hasCustomSecondarySkill {
            
            let offsetBeforeReadingSkills = offset
            
            secondarySkills = try (0..<secondarySkillTypeStartingMaxRawValue).map { _ in
                let skillTypeRawValue = Int(try readUInt8() + 1)
                guard let skillType = Map.Hero.SecondarySkillType(rawValue: skillTypeRawValue) else {
                    fatalError("Unknown secondary skill type value")
                }
                
                let skillLevelRawValue = Int(try readUInt8())
                guard let skillLevel = Map.Hero.SecondarySkillLevel(rawValue: skillLevelRawValue) else {
                    fatalError("Unknown secondary skill level value")
                }
                return Map.Hero.SecondarySkill(skillType: skillType, level: skillLevel)
            }
            assert(offset == offsetBeforeReadingSkills + secondarySkillTypeStartingMaxRawValue * 2)
        } else {
            try skip(byteCount: secondarySkillTypeStartingMaxRawValue * 2)
            secondarySkills = []
        }
        
        try skip(byteCount: 1) // unknown
        
        // Custom name
        let hasCustomName = try readUInt8() != 0
        var customName: String?
        let nameByteCount = 13
        if hasCustomName {
            let nameBytes = Data(try read(byteCount: nameByteCount))
            customName = String.init(data: nameBytes, encoding: .utf8)
        } else {
            try skip(byteCount: nameByteCount)
        }
        
        let patrols = try readUInt8() != 0
        if patrols {
            fatalError("what to do? `if ( st.get() ) { SetModes( PATROL ); patrol_center = GetCenter(); }`")
        }
        
        // Count squares
        let patrolSquare = Int(try readUInt8())
        
        
        return .init(
            hero: heroType,
            color: .none,
            worldPosition: worldPosition,
            army: army,
            portraitRawId: portraitRawId,
            experiencePoints: experiencePoints,
            artifacts: artifacts,
            secondarySkills: secondarySkills,
            customName: customName,
            patrols: patrols,
            patrolSquare: patrolSquare
        )
    }
}

private extension Map.Color {
    init(id: UInt8) {
        switch id {
        case 0: self = .blue
        case 1: self = .green
        case 2: self = .red
        case 3: self = .yellow
        case 4: self = .orange
        case 5: self = .purple
        default: self = .none
        }
    }
}

 
// MARK: Read Map.Castle
private extension DataReader {
    func readCastle(simpleCastle: Map.Castle.Simple, difficulty: Map.Difficulty) throws -> Map.Castle {
        print("🔮 READING CASTLE")
        let colorId = try readUInt8()
        let color = Map.Color(id: colorId)
        let hasCustomBuilding = try readUInt8() > 0
        var buildings: UInt32 = 0
        if hasCustomBuilding {
            let buildingRaw = try readUInt16()
            if buildingRaw & 0x0002 != 0 {
                buildings |= Map.Castle.Building.thievesGuild.rawValue
            }
            if buildingRaw & 0x0004 != 0 {
                buildings |= Map.Castle.Building.tavern.rawValue
            }
            if buildingRaw & 0x0008 != 0 {
                buildings |= Map.Castle.Building.shipyard.rawValue
            }
            if buildingRaw & 0x0010 != 0 {
                buildings |= Map.Castle.Building.well.rawValue
            }
            if buildingRaw & 0x0080 != 0 {
                buildings |= Map.Castle.Building.statue.rawValue
            }
            if buildingRaw & 0x0100 != 0 {
                buildings |= Map.Castle.Building.turretLeft.rawValue
            }
            if buildingRaw & 0x0200 != 0 {
                buildings |= Map.Castle.Building.turretRight.rawValue
            }
            if buildingRaw & 0x0400 != 0 {
                buildings |= Map.Castle.Building.marketplace.rawValue
            }
            if buildingRaw & 0x1000 != 0 {
                buildings |= Map.Castle.Building.moat.rawValue
            }
            if buildingRaw & 0x2000 != 0 {
                buildings |= Map.Castle.Building.spec.rawValue
            }
            
            // Dwelling
            let dwellingRaw = try readUInt16()
            if dwellingRaw & 0x0008 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel1NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0010 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel2NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0020 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel3NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0040 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel4NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0080 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel5NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0100 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel6NonUpgraded.rawValue
            }
            if dwellingRaw & 0x0200 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel2NonUpgraded.rawValue | Map.Castle.Building.dwellingLevel2Upgraded.rawValue
            }
            if dwellingRaw & 0x0400 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel3NonUpgraded.rawValue | Map.Castle.Building.dwellingLevel3Upgraded.rawValue
            }
            if dwellingRaw & 0x0800 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel4NonUpgraded.rawValue | Map.Castle.Building.dwellingLevel4Upgraded.rawValue
            }
            if dwellingRaw & 0x1000 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel5NonUpgraded.rawValue | Map.Castle.Building.dwellingLevel5Upgraded.rawValue
            }
            if dwellingRaw & 0x2000 != 0 {
                buildings |= Map.Castle.Building.dwellingLevel6NonUpgraded.rawValue | Map.Castle.Building.dwellingLevel6Upgraded.rawValue
            }
            
            // Mage guild
            let mageGuildLevelRaw = try readUInt8()
            if mageGuildLevelRaw > 0 {
                buildings |= Map.Castle.Building.mageGuildLevel1.rawValue
            }
            if mageGuildLevelRaw > 1 {
                buildings |= Map.Castle.Building.mageGuildLevel2.rawValue
            }
            if mageGuildLevelRaw > 2 {
                buildings |= Map.Castle.Building.mageGuildLevel3.rawValue
            }
            if mageGuildLevelRaw > 3 {
                buildings |= Map.Castle.Building.mageGuildLevel4.rawValue
            }
            if mageGuildLevelRaw > 4 {
                buildings |= Map.Castle.Building.mageGuildLevel5.rawValue
            }
            
        } else {
            try skip(byteCount: 5) // why??
            // Default building
            buildings |= Map.Castle.Building.dwellingLevel1NonUpgraded.rawValue
            
            let probabilityOfSecondDwelling: UInt32
            switch difficulty {
            case .easy:
                probabilityOfSecondDwelling = 75
            case .normal:
                probabilityOfSecondDwelling = 50
            case .hard:
                probabilityOfSecondDwelling = 25
            case .expert:
                probabilityOfSecondDwelling = 10
            case .impossible:
                probabilityOfSecondDwelling = 0
            }
            if probabilityOfSecondDwelling >= .random(in: 1...100) {
                buildings |= Map.Castle.Building.dwellingLevel2NonUpgraded.rawValue
            }
        }
        
        return Map.Castle(
            race: simpleCastle.race,
            worldPosition: simpleCastle.worldPosition,
            color: color, buildingsBitMask: buildings
        )
    }
}
 

// MARK: Read Map Event
private extension DataReader {
    func readMapEvent(worldPosition: WorldPosition) throws -> Map.SignEventRiddle {
        let id = try readUInt8()
        guard id == 0x01 else {
            fatalError("unknown id")
        }
        
        let wood = Resources.Quantity(try readUInt32())
        let mercury = Resources.Quantity(try readUInt32())
        let ore = Resources.Quantity(try readUInt32())
        let sulfur = Resources.Quantity(try readUInt32())
        let crystal = Resources.Quantity(try readUInt32())
        let gems = Resources.Quantity(try readUInt32())
        let gold = Resources.Quantity(try readUInt32())
        
        let resources = Resources(
            wood: wood,
            mercury: mercury,
            ore: ore,
            sulfur: sulfur,
            crystal: crystal,
            gems: gems,
            gold: gold
        )
        
        let artifact: Artifact? = .init(rawValue: try readUInt(byteCount: 2))
        
        // allow computer
        let allowComputer = try readUInt8() != 0
        
        let shouldCancelEventAfterFirstvisit =  try readUInt8() != 0
        
        try skip(byteCount: 10)
        var visitableByColors: [Map.Color] = []
        if try readUInt8() != 0 {
            visitableByColors.append(.blue)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.green)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.red)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.yellow)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.orange)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.purple)
        }
        
        let message = try? readStringUntilNullTerminator()
        
        let event = Map.SignEventRiddle.Event(
            worldPosition: worldPosition,
            resources: resources,
            artifact: artifact,
            allowComputer: allowComputer,
            shouldCancelEventAfterFirstvisit: shouldCancelEventAfterFirstvisit,
            visitableByColors: visitableByColors,
            message: message
        )
        
        return .event(event)
    }
}

// MARK: Read Map Riddle
private extension DataReader {
    
    func readMapRiddle(worldPosition: WorldPosition) throws -> Map.SignEventRiddle {
        
        let id = try readUInt8()
        guard id == 0x00 else {
            fatalError("unknown id")
        }
        
        
        let wood = Resources.Quantity(try readUInt32())
        let mercury = Resources.Quantity(try readUInt32())
        let ore = Resources.Quantity(try readUInt32())
        let sulfur = Resources.Quantity(try readUInt32())
        let crystal = Resources.Quantity(try readUInt32())
        let gems = Resources.Quantity(try readUInt32())
        let gold = Resources.Quantity(try readUInt32())
        
        let resources = Resources(
            wood: wood,
            mercury: mercury,
            ore: ore,
            sulfur: sulfur,
            crystal: crystal,
            gems: gems,
            gold: gold
        )
        
        let artifact: Artifact? = .init(rawValue: UInt8(try readUInt16()))
        
        var answersLeft = try readUInt8()
        let answers: [String] = try (0..<8).compactMap { _ -> String? in
            defer { answersLeft -= 1 }
            let answerBytes = try read(byteCount: 13)
            guard
                let answer = String(bytes: answerBytes, encoding: .utf8),
                answersLeft > 0
            else {
                return nil
            }
            return answer.lowercased()
        }
        
        guard let question = try? readStringUntilNullTerminator() else {
            fatalError("Failed to read sphinx question")
        }
        
        
        let riddle = Map.SignEventRiddle.Riddle(
            worldPosition: worldPosition,
            question: question,
            validAnswers: answers,
            bounty: .init(
                artifact: artifact,
                resources: resources
            )
        )
        return .riddle(riddle)
    }
}

// MARK: Read Map Sign
private extension DataReader {
    func readMapSign(worldPosition: WorldPosition) throws -> Map.SignEventRiddle {
        try skip(byteCount: 9)
        let message = try readStringUntilNullTerminator()
        let sign = Map.SignEventRiddle.Sign(worldPosition: worldPosition, message: message)
        return .sign(sign)
    }
}

// MARK: Read Map.EventDate
private extension DataReader {
    func readMapEventDate() throws -> Map.EventDate {
        let id = try readUInt8()
        guard id == 0x00 else {
            fatalError("unknown id")
        }
        
        
        let wood = Resources.Quantity(try readUInt32())
        let mercury = Resources.Quantity(try readUInt32())
        let ore = Resources.Quantity(try readUInt32())
        let sulfur = Resources.Quantity(try readUInt32())
        let crystal = Resources.Quantity(try readUInt32())
        let gems = Resources.Quantity(try readUInt32())
        let gold = Resources.Quantity(try readUInt32())
        
        let resources = Resources(
            wood: wood,
            mercury: mercury,
            ore: ore,
            sulfur: sulfur,
            crystal: crystal,
            gems: gems,
            gold: gold
        )
        
        try skip(byteCount: 2)
        
        // allow computer
        let allowComputer = try readUInt16() != 0
        
        let dayOfFirstOccurent = try readUInt16()
        
        let subsequentOccurrences =  try readUInt16()
        
        try skip(byteCount: 6)
        
        
        var visitableByColors: [Map.Color] = []
        if try readUInt8() != 0 {
            visitableByColors.append(.blue)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.green)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.red)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.yellow)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.orange)
        }
        if try readUInt8() != 0 {
            visitableByColors.append(.purple)
        }
        
        let message = try? readStringUntilNullTerminator()
        
        return .init(
            resources: resources,
            allowComputer: allowComputer,
            dayOfFirstOccurent: .init(dayOfFirstOccurent),
            subsequentOccurrences: .init(subsequentOccurrences),
            visitableByColors: visitableByColors,
            message: message
        )
        
    }
}


// MARK: CastlesHeroesEventsRumors
private extension Map {
    struct CastlesHeroesEventsRumorsEtc: Equatable {
        let castles: [Map.Castle]
        let heroes: [Map.Hero]
        let signEventRiddle: [Map.SignEventRiddle]
        let rumors: [Map.Rumor]
        let events: [Map.EventDate]
    }
}

// MARK: Read Map CastlesHeroesEventsRumorsEtc
private extension DataReader {
    
    
    static let eventByteCount = 0x32
    static let rumorByteCount = 0x09
    static let castleByteCount = 0x46
    static let heroesByteCount = 0x4c
    static let signByteCount = 0x0a
    static let riddleByteCount = 0x8a
    
    func readCastlesHeroesEventsRumorsEtc(
        worldBlockCount blockCount: Int,
        tiles: [Map.Tile],
        objects: [Map.Object],
        simpleCastles: [Map.Castle.Simple],
        difficulty: Map.Difficulty,
        kingdoms: inout [Kingdom]
    ) throws -> Map.CastlesHeroesEventsRumorsEtc {
        
        print("\n\n🔮 READ CASTLE HEROES EVENTS RUMORS:\nblockcount: \(blockCount)\ncurrent offset: \(self.offset)\n")
        
        var castles: [Map.Castle] = []
        var signEventRiddles: [Map.SignEventRiddle] = []
        var heroes: [Map.Hero] = []
        var dateEvents: [Map.EventDate] = []
        var rumors: [Map.Rumor] = []
        
        for ii in 0..<blockCount {
            // Read block
            let blockSize = Int(try readUInt16())
            let blockData = try read(byteCount: blockSize)
            let shaHashBlockdata = sha256Hex(data: blockData)
            let blockDataReader = DataReader(data: blockData)
            print("ii=\(ii), offset: \(self.offset), blockdata shahash: \(shaHashBlockdata)")
            
            var tileFound: Map.Tile?
            for objectIndex in 0..<objects.count {
                let object = objects[objectIndex]
                guard let tile = tiles.first(where: { $0.worldPosition == object.worldPosition  }) else { continue }
                var orders = tile.info.quantity2
                assert(orders >= 0)
                orders <<= 8 // like `*= 8`
                orders |= tile.info.quantity1
                if orders % 8 == 0 && (ii + 1 == orders / 8) {
                    tileFound = tile
                    break
                }
            }
            var isRandomCastle = false
            if let foundTile = tileFound {
                print("ii=\(ii), found tile: \(foundTile.debugDescription)")
                switch foundTile.info.objectType {
                case .randomTown, .randomCastle:
                    // Add random castle
                    isRandomCastle = true
                    fallthrough
                case .castle:
                    // add castle
                    guard blockSize == Self.castleByteCount else {
                        fatalError("Incorrect block size of castle, expected: \(Self.castleByteCount)")
                    }
                    guard let simpleCastle = simpleCastles.first(where: { $0.worldPosition == foundTile.worldPosition }) else {
                        fatalError("Did not find castle at expected position")
                    }
                    var castle = try blockDataReader.readCastle(simpleCastle: simpleCastle, difficulty: difficulty)
                    if isRandomCastle {
//                        castle.setRandomSprite()
                    }
                    castles.append(castle)
                case .jail:
                    // Add jail
                    guard blockSize == Self.heroesByteCount else {
                        fatalError("Incorrect block size of castle, expected: \(Self.castleByteCount)")
                    }
                    var race = Race.knight
                    switch blockData[0x3c] {
                    case 1:
                        race = .barbarian
                    case 2:
                        race = .sorceress
                    case 3:
                        race = .warlock
                    case 4:
                        race = .wizard
                    case 5:
                        race = .necromancer
                    default: fatalError()
                    }
                    let heroType = Hero.randomFreeman(race: race)
                    let hero = try blockDataReader.readHero(heroType: heroType, worldPosition: foundTile.worldPosition)
                    heroes.append(hero)
                case .heroes:
                    guard blockSize == Self.heroesByteCount else {
                        fatalError("Incorrect block size of castle, expected: \(Self.castleByteCount)")
                    }
                    var (color, race) = foundTile.raceAndColorOfOccupyingHero()
                    guard let kingdom = kingdoms.first(where: { $0.color == color }) else { fatalError() }
                    if race == .random && color == .none {
                        race = kingdom.race
                    }
                // check heroes max count
                //                    if kingdom.allowsRecruiting(of: hero)
                //                    if ( kingdom.AllowRecruitHero( false, 0 ) ) {
                //                        Heroes * hero = nullptr;
                //
                //                        if ( pblock[17] && pblock[18] < Heroes::BAX )
                //                            hero = vec_heroes.Get( pblock[18] );
                //
                //                        if ( !hero || !hero->isFreeman() )
                //                            hero = vec_heroes.GetFreeman( colorRace.second );
                //
                //                        if ( hero )
                //                            hero->LoadFromMP2( findobject, colorRace.first, colorRace.second, StreamBuf( pblock ) );
                //                    }
                case .sign, .bottle:
                    if blockSize > Self.signByteCount - 1 && blockData[0] == 0x01 {
                        
                        let sign = try blockDataReader.readMapSign(worldPosition: foundTile.worldPosition)
                        signEventRiddles.append(sign)
                    }
                case .event:
                    if blockSize > Self.eventByteCount - 1 && blockData[0] == 0x01 {
                        
                        let event = try blockDataReader.readMapEvent(worldPosition: foundTile.worldPosition)
                        signEventRiddles.append(event)
                    }
                case .sphinx:
                    if blockSize > Self.riddleByteCount - 1 && blockData[0] == 0x00 {
                        
                        let riddle = try blockDataReader.readMapRiddle(worldPosition: foundTile.worldPosition)
                        signEventRiddles.append(riddle)
                    }
                default:
                    fatalError()
                }
            } else {
                // Other events
                print("ii=\(ii), NOT found tile")
                
                // Add event day
                if  blockData.count > Self.eventByteCount - 1 && blockData[42] == 1 { // why 42?
                    let eventDate = try blockDataReader.readMapEventDate()
                    dateEvents.append(eventDate)
                } else if blockData.count > Self.rumorByteCount - 1 {
                    let rumorByteCount = Int(blockData[8])
                    if rumorByteCount > 0  {
                        let rumorBytes = try blockDataReader.read(byteCount: rumorByteCount)
                        guard let rumorString = String(bytes: rumorBytes, encoding: .utf8) else {
                            fatalError("Failed to get rumor string")
                        }
                        let rumor = Map.Rumor(rumor: rumorString)
                        rumors.append(rumor)
                    }
                } else {
                    print("Warning unknown block while loading (parsing) map from binary.")
                }
            }
        }
        
        return .init(
            castles: castles,
            heroes: heroes,
            signEventRiddle: signEventRiddles,
            rumors: rumors,
            events: dateEvents
        )
    }
}

// MARK: Read Block count
private extension DataReader {
    func readMapBlockCount() throws -> Int {
        var blockCount: UInt32 = 0
        
        /*
         u32 countblock = 0;
         while ( 1 ) {
         const u32 l = fs.get();
         const u32 h = fs.get();
         
         if ( 0 == h && 0 == l )
         break;
         else {
         countblock = 256 * h + l - 1;
         }
         }
         */
        
        while true {
            let l = UInt32(try readUInt8())
            let h = UInt32(try readUInt8())
            
            if h == 0 && l == 0 {
                break
            }
            
            blockCount = 256 * h + l - 1
        }
        return Int(blockCount)
    }
}

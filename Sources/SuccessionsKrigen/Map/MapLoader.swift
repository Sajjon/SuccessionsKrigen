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

public struct Map: Equatable {
    let metaData: MetaData
    let unique: Int
    let tiles: Tiles
    let heroes: Heroes
    let castles: Castles
    let kingdoms: Kingdoms
    let rumors: Rumors
    let eventsDay: EventsDates
    let capturedObjects: CapturedObjects
    let signEventRiddles: SignEventRiddles
    
    let date: MapDate
    
    let weekOfCurrent: WeekOf
    let weekOfNext: WeekOf
    let ultimateArtifact: UltimateArtifact?
    
    fileprivate init(
        metaData: MetaData,
        unique: Int,
        
        tiles tileList: [Tile],
        heroes heroList: [Hero],
        castles castleList: [Castle],
        kingdoms kingdomList: [Kingdom],
        rumors rumorList: [Rumor],
        eventsDay eventsDayList: [EventDate],
        capturedObjects: CapturedObjects,
        signEventRiddles signEventRiddlesList: [Map.SignEventRiddle]
    ) throws {
        self.metaData = metaData
        precondition(tileList.count == metaData.size.rawValue * metaData.size.rawValue, "Disrepancy between size and number of tiles")
        self.unique = unique
        self.tiles = .init(tiles: tileList)
        self.heroes = .init(heroes: heroList)
        self.castles = .init(castles: castleList)
        self.kingdoms = .init(kingdoms: kingdomList)
        self.rumors = .init(rumors: rumorList)
        self.eventsDay = .init(eventDate: eventsDayList)
        self.capturedObjects = capturedObjects
        self.signEventRiddles = .init(signEventRiddles: signEventRiddlesList)
        
        self.date = .init(day: 1, week: 1, month: 1)
        self.weekOfCurrent = .random()
        self.weekOfNext = .random()
        
        if let tileForUltimateArtifact = tileList.first(where: { $0.info.mapObjectType == .randomUltimateArtifact }) {
            self.ultimateArtifact = .init(artifact: .randomUltimate(), worldPosition: tileForUltimateArtifact.worldPosition, isFound: false)
        } else {
            self.ultimateArtifact = .init(artifact: .randomUltimate(), worldPosition: WorldPosition(x: 1, y: 1), isFound: false)
        }
    }
    
    public struct MapDate: Equatable {
        let day: Int
        let week: Int
        let month: Int
        
        public init(day: Int, week: Int, month: Int) {
            self.day = day
            self.week = week
            self.month = month
        }
        
        public enum Deadline {
            case days
        }
        public static let daysPerWeek = 7
        public static let weeksPerMonth = 4
        public static let daysPerMonth = Self.daysPerWeek * Self.weeksPerMonth
        public static func `in`(_ daysUntilDeadline: Int, _: Deadline) -> Self {
 
            let month = daysUntilDeadline.quotientAndRemainder(dividingBy: daysPerMonth).quotient + 1
            let week = daysUntilDeadline.quotientAndRemainder(dividingBy: weeksPerMonth).quotient + 1
            let day = daysUntilDeadline.quotientAndRemainder(dividingBy: month * daysPerMonth + week * daysPerWeek).remainder + 1
            
            return .init(day: day, week: week, month: month)
        }
    }
    public struct Tiles: Equatable {
        let tiles: [Tile]
    }
    public struct EventsDates: Equatable {
        let eventDate: [EventDate]
    }
    public struct SignEventRiddles: Equatable {
        let signEventRiddles: [Map.SignEventRiddle]
    }
    public struct Heroes: Equatable {
        let heroes: [Hero]
    }
    public struct Castles: Equatable {
        let castles: [Castle]
    }
    public struct Rumors: Equatable {
        let rumors: [Rumor]
    }
    public struct Kingdoms: Equatable {
        let kingdoms: [Kingdom]
    }
    
    public struct UltimateArtifact: Equatable {
        let artifact: Artifact
        let worldPosition: WorldPosition
        let isFound: Bool
    }
    
    public enum WeekOf: Equatable, CaseIterable {
        case plague,
              ant,
              grasshopper,
              dragonfly,
              spider,
              butterfly,
              bumblebee,
              locust,
              earthworm,
              hornet,
              beetle,
              squirrel,
              rabbit,
              gopher,
              badger,
              eagle,
              weasel,
              raven,
              mongoose,
              aardvark,
              lizard,
              tortoise,
              hedgehog,
              condor
    }
}

// MARK: - Size
public extension Map {
    enum Size: Int, Equatable {
        case small = 36, medium = 72, large = 108, extraLarge = 144
    }
}

// MARK: - AddOn
public extension Map {
    struct AddOn: Equatable {
        
        let nextAddInIndex: Int
        let objectNameN1: Int
        let indexNameN1: Int
        let quantityN: Int
        let objectNameN2: Int
        let indexNameN2: Int
        let level1ObjectUID: Int
        let level2ObjectUID: Int
    }
}

private extension DataReader {
    func readMapAddOn() throws -> Map.AddOn {

        let nextAddInIndex = try readUInt16()
        let objectNameN1 = try readUInt8() * 2 // why *2 ?
        let indexNameN1 = try readUInt8()
        let quantityN = try readUInt8()
        let objectNameN2 = try readUInt8()
        let indexNameN2 = try readUInt8()
        
        let level1ObjectUID = try readUInt32()
        let level2ObjectUID = try readUInt32()
        
        return .init(
            nextAddInIndex: .init(nextAddInIndex),
            objectNameN1: .init(objectNameN1),
            indexNameN1: .init(indexNameN1),
            quantityN: .init(quantityN),
            objectNameN2: .init(objectNameN2),
            indexNameN2: .init(indexNameN2),
            level1ObjectUID: .init(level1ObjectUID),
            level2ObjectUID: .init(level2ObjectUID)
        )
    }
}
    
// MARK: - Tiles
public extension Map {
    struct Tile: Equatable {
        let info: Info
        let worldPosition: WorldPosition
    }
}

public extension Map.Tile {
    struct Info: Equatable {
        let tileIndex: Int
        let objectName1: Int
        let indexName1: Int
        let quantity1: Int
        let quantity2: Int
        let objectName2: Int
        let indexName2: Int
        let flags: Int
        
        /// "mapObject"
        let mapObjectType: Map.Tile.Info.MapObjectType
        
        let nextAddonIndex: Int
        let level1ObjectUID: Int
        let level2ObjectUID: Int
        
        internal private(set) var level1AddOns: [Map.AddOn]
        internal private(set) var level2AddOns: [Map.AddOn]
        
        private(set) var objectIndex: UInt8 = 255
        
    }
}

public extension Map.Tile {
    
    func raceAndColorOfOccupyingHero() -> (color: Map.Color, race: Race) {
        guard case .heroes = info.mapObjectType else { fatalError("wrong mapobject type") }
        
        let heroSpriteIndex = info.objectIndex
        
        let color: Map.Color
        if 7 > heroSpriteIndex {
            color = .blue
        } else if 14 > heroSpriteIndex {
            color = .green
        } else if 21 > heroSpriteIndex {
            color = .red
        } else if 28 > heroSpriteIndex {
            color = .yellow
        } else if 35 > heroSpriteIndex {
            color = .orange
        } else {
            color = .purple
        }
     
        guard let race = Race(rawValue: .init(heroSpriteIndex % 7)) else {
            fatalError("failed to get race")
        }
        
        return (color, race)
    }
    
    mutating func sortAddOns() {
        fatalError()
        /*
     // Push everything to the container and sort it by level.
         if ( objectTileset != 0 && objectIndex < 255 ) {
             addons_level1.emplace_front( _level, uniq, objectTileset, objectIndex );
         }

         // Some original maps have issues with identifying tiles as roads. This code fixes it. It's not an ideal solution but works fine in most of cases.
         if ( !tileIsRoad ) {
             for ( const TilesAddon & addon : addons_level1 ) {
                 if ( addon.isRoad() ) {
                     tileIsRoad = true;
                     break;
                 }
             }
         }

         addons_level1.sort( TilesAddon::PredicateSortRules1 );

         if ( !addons_level1.empty() ) {
             const TilesAddon & highestPriorityAddon = addons_level1.back();
             uniq = highestPriorityAddon.uniq;
             objectTileset = highestPriorityAddon.object;
             objectIndex = highestPriorityAddon.index;
             _level = highestPriorityAddon.level & 0x03;

             addons_level1.pop_back();
         }

         // Level 2 objects don't have any rendering priorities so they should be rendered first in queue first to render.
     }
     */
    }
}


public extension Map.Tile.Info {
    func appendingLevel1AddOns(_ level1AddOns: [Map.AddOn]) -> Self {
        var copy = self
        copy.level1AddOns = level1AddOns
        return copy
    }
    
    func appendingLevel2AddOns(_ level2AddOns: [Map.AddOn]) -> Self {
        var copy = self
        copy.level2AddOns = level2AddOns
        return copy
    }
    
    enum Error: Swift.Error {
        case unknownObjectType(Map.Tile.Info.MapObjectType.RawValue)
    }
    
    /// Type of object. Most of them have two versions, one with suffix `N` which I dunno what it stands for...
    /// first bit indicates if you can interact with object
    enum MapObjectType: UInt8, Equatable {
        case alchemyLabN = 0x01,
        skeletonN = 0x04,
        daemonCaveN = 0x05,
        faerieRingN = 0x07,
        gazeboN = 0x0a,
        graveyardN = 0x0c,
        archerHouseN = 0x0d,
        dwarfCottageN = 0x0f,

        peasantHutN = 0x10,
        dragonCityN = 0x14,
        lighthouseN = 0x15,
        waterwheelN = 0x16,
        minesN = 0x17,
        obeliskN = 0x19,
        oasisN = 0x1a,
        coastN = 0x1c,
        sawmillN = 0x1d,
        oracleN = 0x1e,

        shipwreckN = 0x20,
        desertTentN = 0x22,
        castleN = 0x23,
        stoneLithsN = 0x24,
        wagoncampN = 0x25,
        windmillN = 0x28,

        randomCownM = 0x30,
        randomCastleN = 0x31,
        nothingSpecial = 0x38,
        nothingSpecial2 = 0x39,
        watchTowerN = 0x3a,
        treeHouseN = 0x3b,
        treeCityN = 0x3c,
        ruinsN = 0x3d,
        fortN = 0x3e,
        tradingpostN = 0x3f,

        /// OBJN_ABANDONEDMINE vs OBJ_ABANDONEDMINE
        abandonedMineN = 0x40,

        /// OBJN_TREEKNOWLEDGE vs OBJ_TREEKNOWLEDGE
        treeKnowledgeN = 0x44,

        /// OBJN_DOCTORHUT vs OBJ_DOCTORHUT
        doctorHutN = 0x45,

        /// OBJN_TEMPLE vs OBJ_TEMPLE
        templeN = 0x46,

        /// OBJN_HILLFORT vs OBJ_HILLFORT
        hillfortN = 0x47,

        /// OBJN_HALFLINGHOLE vs OBJ_HALFLINGHOLE
        halflingHoleN = 0x48,

        /// OBJN_MERCENARYCAMP vs OBJ_MERCENARYCAMP
        mercenaryCampN = 0x49,

        /// "OBJN_PYRAMID" vs OBJ_PYRAMID (0xCC)
        pyramidN = 0x4c,

        /// "OBJN_CITYDEAD" vs OBJ_CITYDEAD (0xCD)
        cityDeadN = 0x4d,

        /// "OBJN_EXCAVATION" vs OBJ_EXCAVATION (0xCE)
        excavationN = 0x4e,

        /// "OBJN_SPHINX" vs OBJN_SPHINX (0xCF)
        sphinxN = 0x4f,

        tarpit = 0x51,
        artesianSpringN = 0x52,
        trollBridgeN = 0x53,
        wateringHoleN = 0x54,
        witchsHutN = 0x55,
        xanaduN = 0x56,
        caveN = 0x57,

        /// "OBJN_MAGELLANMAPS" vs OBJ_MAGELLANMAPS (0xd9)
        magellanMapsN = 0x59,

        /// "OBJN_DERELICTSHIP" vs OBJ_DERELICTSHIP (0xde)
        derelictShipN = 0x5b,

        /// "OBJN_MAGICWELL" vs OBJ_MAGICWELL (0xDE)
        magicWellN = 0x5e,

        /// OBJN_OBSERVATIONTOWER vs OBJ_OBSERVATIONTOWER (0xE0)
        observationTowerN = 0x60,

        /// "OBJN_FREEMANFOUNDRY" vs OBJ_FREEMANFOUNDRY (0xE1)
        freemanFoundryN = 0x61,
        trees = 0x63,
        mounts = 0x64,
        volcano = 0x65,
        flowers = 0x66,
        stones = 0x67,
        waterLake = 0x68,
        mandrake = 0x69,
        deadTree = 0x6a,
        stump = 0x6b,
        crater = 0x6c,
        cactus = 0x6d,
        mound = 0x6e,
        dune = 0x6f,

        lavaPool = 0x70,
        shrub = 0x71,

        /// "OBJN_ARENA" vs OBJ_ARENA (0xF2)
        arenaN = 0x72,

        /// "OBJN_BARROWMOUNDS" vs OBJ_BARROWMOUNDS (0xF4)
        barrowMoundsN = 0x73,

        /// "OBJN_MERMAID" vs OBJ_MERMAID (0xEC)
        mermaidM = 0x74,

          /// "OBJN_SIRENS"  vs OBJ_SIRENS (0xED)
        sirensN = 0x75,

        /// "OBJN_HUTMAGI"  vs OBJ_HUTMAGI (0xEE)
        hutMagiN = 0x76,

        /// "OBJN_EYEMAGI"  vs OBJ_EYEMAGI (0xEF)
        eyeMagiN = 0x77,

        /// "OBJN_TRAVELLERTENT"  vs OBJ_TRAVELLERTENT (0x78)
        travellerTentN = 0x78,
        jailN = 0x7b,


        /// "OBJN_FIREALTAR" vs OBJ_FIREALTAR (0xfc)
        firAaltarN = 0x7c,

        /// "OBJN_AIRALTAR" vs OBJ_AIRALTAR (0xfd)
        airAltarN = 0x7d,

        /// "OBJN_EARTHALTAR" vs OBJ_EARTHALTAR (0xfe)
        earthAltarN = 0x7e,

        /// "OBJN_WATERALTAR" vs OBJ_WATERALTAR (0xff)
        waterAltarN = 0x7f,

        waterChest = 0x80,
        alchemyLab = 0x81,
        sign = 0x82,
        buoy = 0x83,
        skeleton = 0x84,
        daemonCave = 0x85,
        treasureChest = 0x86,
        faerieRing = 0x87,
        campfire = 0x88,
        fountain = 0x89,
        gazebo = 0x8a,
        ancientLamp = 0x8b,
        graveyard = 0x8c,
        archerHouse = 0x8d,
        goblinHut = 0x8e,
        dwarfCottage = 0x8f,

        peasantHut = 0x90,
        event = 0x93,
        dragonCity = 0x94,
        lighthouse = 0x95,
        waterWheel = 0x96,
        mines = 0x97,
        monster = 0x98,
        obelisk = 0x99,
        oasis = 0x9a,
        resource = 0x9b,
        sawmill = 0x9d,
        oracle = 0x9e,
        shrine1 = 0x9f,

        shipwreck = 0xa0,
        desertTent = 0xa2,
        castle = 0xa3,
        stoneLiths = 0xa4,
        wagonCamp = 0xa5,
        whirlpool = 0xa7,
        windmill = 0xa8,
        artifact = 0xa9,
        boat = 0xab,
        randomUltimateArtifact = 0xac,
        randomartifact = 0xad,
        randomResource = 0xae,
        randomMonster = 0xaf,

        randomTown = 0xb0,
        randomCastle = 0xb1,
        randomMonster1 = 0xb3,
        randomMonster2 = 0xb4,
        randomMonster3 = 0xb5,
        randomMonster4 = 0xb6,
        heroes = 0xb7,
        watchTower = 0xba,
        treeHouse = 0xbb,
        treeCity = 0xbc,
        ruins = 0xbd,
        fort = 0xbe,
        tradingPost = 0xbf,

        abandonedMine = 0xc0,
        thatchedHut = 0xc1,
        standingStones = 0xc2,
        idol = 0xc3,
        treeKnowledge = 0xc4,
        doctorHut = 0xc5,
        temple = 0xc6,
        hillfort = 0xc7,
        halflingHole = 0xc8,
        mercenaryCamp = 0xc9,
        shrine2 = 0xca,
        shrine3 = 0xcb,
        pyramid = 0xcc,
        cityDead = 0xcd,
        excavation = 0xce,
        sphinx = 0xcf,

        wagon = 0xd0,
        artesianSpring = 0xd2,
        trollBridge = 0xd3,
        wateringHole = 0xd4,
        witchshut = 0xd5,
        xanadu = 0xd6,
        cave = 0xd7,
        leanTo = 0xd8,
        magellanMaps = 0xd9,
        flotsam = 0xda,
        derelictShip = 0xdb,
        shipwreckSurviror = 0xdc,
        bottle = 0xdd,
        magicWell = 0xde,
        magicGarden = 0xdf,

        observationTower = 0xe0,
        freemanFoundry = 0xe1,
        reefs = 0xe9,
        alchemyTowerN = 0xea,
        stablesN = 0xeb,
        mermaid = 0xec,
        sirens = 0xed,
        hutMagi = 0xee,
        eyeMagi = 0xef,

        alchemyTower = 0xf0,
        stables = 0xf1,
        arena = 0xf2,
        barrowMounds = 0xf3,
        randomArtifact1 = 0xf4,
        randomArtifact2 = 0xf5,
        randomArtifact3 = 0xf6,
        barrier = 0xf7,
        travellerTent = 0xf8,
        jail = 0xfb,
        fireAltar = 0xfc,
        airAltar = 0xfd,
        earthAltar = 0xfe,
        waterAltar = 0xff
    }

}

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

extension CGPoint: Hashable {}
public extension CGPoint {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

public extension Map {
    struct Castle: Equatable {
        let race: Race
        let worldPosition: WorldPosition
        let color: Color
        
        // TODO replace Castle.Building enum with an OptionSet struct, and change type of this variable to said OptionSet struct.
        let buildingsBitMask: UInt32
    }
}

extension Map.Castle {
    
    mutating func setRandomSprite() {
        fatalError()
    }
}

public extension Map.Castle {
    struct Simple: Equatable {
        let race: Race
        let worldPosition: WorldPosition
    }
}

private extension DataReader {
    func readMapTiles(worldSize: Int, worldWidth: Int, addOns: [Map.AddOn]) throws -> [Map.Tile] {
        
        var mapTiles = [Map.Tile]()
        for worldPositionIndex in 0..<worldSize {
            let qr = worldPositionIndex.quotientAndRemainder(dividingBy: worldWidth)
            let worldPositionX = qr.remainder
            let worldPositionY = qr.quotient
            let worldPosition: WorldPosition = .init(x: worldPositionX, y: worldPositionY)
            let mapTileInfo = try readMapTileInfo()

            
            // Read extra information if it's present.
            var addOnIndex = mapTileInfo.nextAddonIndex
            
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
                addOnIndex = addOn.nextAddInIndex
            }
            
            var mapTile = Map.Tile(
                info:
                    mapTileInfo
                    .appendingLevel1AddOns(level1Addons)
                    .appendingLevel2AddOns(level2Addons),
                worldPosition: worldPosition
            )
            mapTile.sortAddOns()
            mapTiles.append(mapTile)
        }
        
        return mapTiles
    }
}

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
            let worldPosition = CGPoint(x: Int(x), y: Int(y))

            
            guard let race = Race(id: raceId) else { throw MapLoader.Error.unrecognizedRace(raceId) }
            let castle = Map.Castle.Simple(race: race, worldPosition: worldPosition)
            simpleCastles.append(castle)

            // Preload in to capture objects cache
            captureObjects = captureObjects.capture(objectOfType: .castle, at: worldPosition, by: .none)
        }
        return simpleCastles
    }
}



private extension DataReader {
    
    /// Temporary
    enum MineLighthouseOrDragonCity: UInt8, Equatable {
        case sawmill, alchemyLab, oreMine, sulfurMine, crystalMine, gemMine, goldMine
        case lighthouse = 0x64
        case dragonCity = 0x65
        case abandonedMine = 0x67
        
        var objectMapType: Map.Tile.Info.MapObjectType {
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
            let worldPosition = CGPoint(x: Int(x), y: Int(y))
            
            guard let capturableObject = MineLighthouseOrDragonCity(rawValue: mineId) else { fatalError("Unrecognized capturable object") }
            captureObjects = captureObjects.capture(objectOfType: capturableObject.objectMapType, at: worldPosition, by: .none)
            
        }
    }
}

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
        guard let mapObjectType = Map.Tile.Info.MapObjectType(rawValue: mapObjectTypeRaw) else {
            throw Map.Tile.Info.Error.unknownObjectType(mapObjectTypeRaw)
        }
        let nextAddonIndex = try readUInt16()
        let level1ObjectUID = try readUInt32()
        let level2ObjectUID = try readUInt32()
        
        return .init(
            tileIndex: .init(tileIndex),
            objectName1: .init(objectName1),
            indexName1: .init(indexName1),
            quantity1: .init(quantity1),
            quantity2: .init(quantity2),
            objectName2: .init(objectName2),
            indexName2: .init(indexName2),
            flags: .init(flags),
            mapObjectType: mapObjectType,
            nextAddonIndex: .init(nextAddonIndex),
            level1ObjectUID: .init(level1ObjectUID),
            level2ObjectUID: .init(level2ObjectUID),
            level1AddOns: [],
            level2AddOns: []
        )
    }
}

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

public extension Map {
    enum VictoryCondition: Equatable {
        case defeatAllEnemyHeroesAndTowns
        case captureSpecificTownLocated(at: WorldPosition)
        case defeatSpecificHeroLocated(at: WorldPosition)
        case findSpecificArtifact(Artifact)
        case defeatOtherTeam
        case accumlateGoldAmount(Resource.Quantity)
    }
    
    enum DefeatCondition: Equatable {
        case loseAllHeroesAndTowns
        case loseSpecificTownLocated(at: WorldPosition)
        case loseSpecificHeroLocated(at: WorldPosition)
        case runOutOfTime(deadline: Map.MapDate)
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
    
    enum Stripped: UInt8, Equatable, CaseIterable, CustomStringConvertible {
        case defeatAllEnemyHeroesAndTowns = 0, captureSpecificTown, defeatSpecificHero, findSpecificArtifact, defeatOtherTeam, accumlateGoldAmount
    }

}

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

public struct Troop: Equatable {
    let creatureType: Creature
    public typealias Quantity = UInt32
    let quantity: Quantity
}

public typealias WorldPosition = CGPoint

public extension Map {
    struct CapturedObject: Equatable {
        let objectMapType: Map.Tile.Info.MapObjectType
        let color: Color
        let guardians: Troop?
    }
    
    struct CapturedObjects: Equatable {
        private let capturedObjects: [WorldPosition: CapturedObject]
        init(capturedObjects: [WorldPosition: CapturedObject] = [:]) {
            self.capturedObjects = capturedObjects
        }
    }
}

public extension Map.CapturedObjects {
    func capture(objectOfType: Map.Tile.Info.MapObjectType, at worldPosition: WorldPosition, by color: Map.Color) -> Self {
        var mutableDictionary = self.capturedObjects
        mutableDictionary[worldPosition] = .init(objectMapType: objectOfType, color: color, guardians: nil)
        return .init(capturedObjects: mutableDictionary)
    }
}


private extension MapLoader {
    static let homm2MapFileIdentifier: UInt32 = 0x5C000000
    
    static let offsetData = 428
    static let sizeOfTile = 20
}

public extension Map {
    struct Object: Equatable {
        let objectType: Map.Tile.Info.MapObjectType
        let worldPosition: WorldPosition
    }
}

public extension Map {
    struct MetaData: Equatable {
        let fileName: String
        let name: String
        let description: String
        let size: Size
        let difficulty: Difficulty
        let victoryCondition: VictoryCondition
        let defeatCondition: DefeatCondition?
        let computerCanWinUsingVictoryCondition: Bool
        let victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns: Bool
        let isStartingWithHeroInEachCastle: Bool
        let racesByColor: [Map.Color: Race]
        let expansionPack: ExpansionPack?
    }
    
    enum Difficulty: Int, Equatable, CaseIterable {
        case easy = 0, normal, hard, expert, impossible
    }
}

public struct ExpansionPack: Equatable {
    let name: String
    let mapFileExtension: String
}
public extension ExpansionPack {
    static let princeOfLoyalty = Self(name: "Price of loyalty", mapFileExtension: "MX2")
}

public extension MapLoader {
    
    
    enum Error: Swift.Error {
        case fileNotFound
        case notHomm2MapFile
        case parseWidthFailed
        case parseHeightFailed
        case mapMustBeSquared
        case unrecognizedRace(Race.RawValue)
    }
    
 
    
    func loadMapMetaData(filePath mapFilePath: String) throws -> Map.MetaData {
        guard let contentsRaw = FileManager.default.contents(atPath: mapFilePath) else {
            throw Error.fileNotFound
        }
        let fileName = String(mapFilePath.split(separator: "/").last!)
        return try loadMapMetaData(rawData: contentsRaw, fileName: fileName)
    }
    
    private static let mapNameByteCount = 16
    private static let mapDescriptionByteCount = 143
    
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
            victoryCondition: victoryCondition,
            defeatCondition: defeatCondition,
            computerCanWinUsingVictoryCondition: computerCanWinUsingVictoryCondition,
            victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns: victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns,
            isStartingWithHeroInEachCastle: isStartingWithHeroInEachCastle,
            racesByColor: racesByColor,
            expansionPack: expansionPack
        )
    }
    
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
            switch mapTileInfo.mapObjectType {
            case .randomTown, .randomCastle, .castle, .heroes, .sign, .bottle, .event, .sphinx, .jail:
                objects.append(.init(objectType: mapTileInfo.mapObjectType, worldPosition: $0.worldPosition)) //[$0.worldPosition] = mapTileInfo.mapObjectType
                break
            default: break
            }
        }
        
        try dataReader.seek(to: addOnsEndIndex)
        
        var captureObjects = Map.CapturedObjects()
        let castlesSimple: [Map.Castle.Simple] = try dataReader.readMapCastlesSimple(captureObjects: &captureObjects)
        assert(dataReader.offset == addOnsEndIndex + DataReader.numberOfCastleCoordinates*3)
        
        let minesStartIndex = dataReader.offset
        
        try dataReader.readMapCapturableObject(captureObjects: &captureObjects, mapSize: mapSize)
        
        try dataReader.seek(to: minesStartIndex + Map.Size.extraLarge.rawValue + 3) // even though map might be small, the next data always starts 144*3 bytes from `minesStartIndex`

        // byte: num obelisks (01 default)
        try dataReader.skip(byteCount: 1)
        
        // Count final mp2 blocks
        let blockCount = try dataReader.readMapBlockCount()
        
        // Castle, heroes or (events, rumors, etc)
        var kingsdoms = [Kingdom]()
        let castlesHeroesEventsRumorsEtc = try dataReader.readCastlesHeroesEventsRumorsEtc(
            worldBlockCount: blockCount,
            tiles: mapTiles,
            objects: objects,
            simpleCastles: castlesSimple,
            difficulty: metaData.difficulty,
            kingdoms: &kingsdoms
        )
        
        let map = try Map(
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
        
        return map
    }
}


/// "Player"
public struct Kingdom: Equatable {
    let color: Map.Color
    let race: Race
    let heroes: [Hero]
}

public extension Map {
    struct CastlesHeroesEventsRumorsEtc: Equatable {
        let castles: [Map.Castle]
        let heroes: [Map.Hero]
        let signEventRiddle: [Map.SignEventRiddle]
        let rumors: [Map.Rumor]
        let events: [Map.EventDate]
    }
}


public extension Map {
    enum SignEventRiddle: Equatable {
        case sign(Sign)
        case event(Event)
        case riddle(Riddle)
        
        public struct Sign: Equatable {
            let worldPosition: WorldPosition
            let message: String
        }
        public struct Event: Equatable {
            let worldPosition: WorldPosition
            let resources: Resources
            let artifact: Artifact?
            let allowComputer: Bool
            let shouldCancelEventAfterFirstvisit: Bool
            let visitableByColors: [Map.Color]
            let message: String?
        }
        
        public struct Riddle: Equatable {
            let worldPosition: WorldPosition
            let question: String
            let validAnswers: [String]
            let bounty: Bounty
            
            public struct Bounty: Equatable {
                let artifact: Artifact?
                let resources: Resources
            }
        }
    }
    
    struct EventDate: Equatable {
        
        let resources: Resources
        let allowComputer: Bool
        let dayOfFirstOccurent: Int
        let subsequentOccurrences: Int
        let visitableByColors: [Map.Color]
        let message: String?
    }
    
    struct Rumor: Equatable {
        let rumor: String
    }
    
    struct Hero: Equatable {
        let hero: SuccessionsKrigen.Hero
        let color: Map.Color
        let worldPosition: WorldPosition
        let army: Army
        let portraitRawId: Int
        let experiencePoints: Int
        let artifacts: [Artifact]
        let secondarySkills: [Map.Hero.SecondarySkill]
        let customName: String?
        let patrols: Bool
        let patrolSquare: Int
    }
}

public extension Map.Hero {
    
    static func randomStartingExperiencePointCount() -> Int {
        .random(in: 40...90)
    }
    
    struct Army: Equatable {
        let troops: [Troop]
    }
    
    enum PortraitSize: Equatable {
        case big, medium, small
    }
    
    func portraitSprite(size: PortraitSize, aggFile: AGGFile) throws -> Sprite {
        /*
         const fheroes2::Sprite & Heroes::GetPortrait( int id, int type )
         {
             if ( Heroes::UNKNOWN != id )
                 switch ( type ) {
                 case PORT_BIG:
                     return fheroes2::AGG::GetICN( ICN::PORTxxxx( id ), 0 );
                 case PORT_MEDIUM:
                     return Heroes::DEBUG_HERO > id ? fheroes2::AGG::GetICN( ICN::PORTMEDI, id + 1 ) : fheroes2::AGG::GetICN( ICN::PORTMEDI, BAX + 1 );
                 case PORT_SMALL:
                     return Heroes::DEBUG_HERO > id ? fheroes2::AGG::GetICN( ICN::MINIPORT, id ) : fheroes2::AGG::GetICN( ICN::MINIPORT, BAX );
                 default:
                     break;
                 }

             return fheroes2::AGG::GetICN( -1, 0 );
         }
         */
        fatalError()
    }
}

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

extension CaseIterable {
    static func random() -> Self {
        allCases.randomElement()!
    }
}

public enum Artifact: UInt8, Equatable, CaseIterable {
    case ultimateBook = 0
    case spaceNecromancy = 102
}

public extension Artifact {
    static func randomUltimate() -> Self {
        return .ultimateBook
    }
}

public struct Resources: Equatable {
    public typealias Quantity = Resource.Quantity
    let wood: Quantity
    let mercury: Quantity
    let ore: Quantity
    let sulfur: Quantity
    let crystal: Quantity
    let gems: Quantity
    let gold: Quantity
}

public struct Resource: Equatable {
    let resourceType: ResourceType
    public typealias Quantity = Int
    let quantity: Quantity
}
public extension Resource {
    enum ResourceType: Equatable {
        case wood, mercury, ore, sulfur, crystal, gems, gold
    }
}

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
        
        func readCastle(simpleCastle: Map.Castle.Simple) throws -> Map.Castle {
            let colorRaw = try readUInt8()
            guard let color = Map.Color(rawValue: colorRaw) else {
                fatalError("Invalid color")
            }
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
        
        var castles: [Map.Castle] = []
        var signEventRiddles: [Map.SignEventRiddle] = []
        var heroes: [Map.Hero] = []
        var dateEvents: [Map.EventDate] = []
        var rumors: [Map.Rumor] = []
        
        for ii in 0..<blockCount {
            // Read block
            let blockSize = Int(try readUInt16())
            
            let blockData = try read(byteCount: blockSize)
            
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
                switch foundTile.info.mapObjectType {
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
                    var castle = try readCastle(simpleCastle: simpleCastle)
                    if isRandomCastle {
                        castle.setRandomSprite()
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
                    let hero = try readHero(heroType: heroType, worldPosition: foundTile.worldPosition)
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
                        func readMapSign() throws -> Map.SignEventRiddle {
                            try skip(byteCount: 9)
                            let message = try readStringUntilNullTerminator()
                            let sign = Map.SignEventRiddle.Sign(worldPosition: foundTile.worldPosition, message: message)
                            return .sign(sign)
                        }
                        
                        let sign = try readMapSign()
                        signEventRiddles.append(sign)
                    }
                case .event:
                        if blockSize > Self.eventByteCount - 1 && blockData[0] == 0x01 {
                            func readMapEvent() throws -> Map.SignEventRiddle {
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
                                
                                let artifact: Artifact? = .init(rawValue: UInt8(try readUInt16()))
                                
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
                                    worldPosition: foundTile.worldPosition,
                                    resources: resources,
                                    artifact: artifact,
                                    allowComputer: allowComputer,
                                    shouldCancelEventAfterFirstvisit: shouldCancelEventAfterFirstvisit,
                                    visitableByColors: visitableByColors,
                                    message: message
                                )
                                
                                return .event(event)
                            }
                            
                            let event = try readMapEvent()
                            signEventRiddles.append(event)
                        }
                case .sphinx:
                    if blockSize > Self.riddleByteCount - 1 && blockData[0] == 0x00 {
                        func readMapRiddle() throws -> Map.SignEventRiddle {
                            
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
                                worldPosition: foundTile.worldPosition,
                                question: question,
                                validAnswers: answers,
                                bounty: .init(
                                    artifact: artifact,
                                    resources: resources
                                )
                            )
                            return .riddle(riddle)
                        }
                        let riddle = try readMapRiddle()
                        signEventRiddles.append(riddle)
                    }
                default:
                    fatalError()
                }
            } else {
                // Other events
                
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
                    
                    return .init(
                        resources: resources,
                        allowComputer: allowComputer,
                        dayOfFirstOccurent: .init(dayOfFirstOccurent),
                        subsequentOccurrences: .init(subsequentOccurrences),
                        visitableByColors: visitableByColors,
                        message: message
                    )
                 
                }
              
                
                // Add event day
                if  blockData.count > Self.eventByteCount - 1 && blockData[42] == 1 { // why 42?
                    let eventDate = try readMapEventDate()
                    dateEvents.append(eventDate)
                } else if blockData.count > Self.rumorByteCount - 1 {
                    let rumorByteCount = Int(blockData[8])
                    if rumorByteCount > 0  {
                        let rumorBytes = try read(byteCount: rumorByteCount)
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
        
private extension DataReader {
    func readMapBlockCount() throws -> Int {
        var blockCount = 0
        while true {
            let l = Int(try readUInt8())
            let h = Int(try readUInt8())

            guard !(h == 0 && l == 0) else {
                break
            }
            
            blockCount = 256 * h + l - 1
        }
        return blockCount
    }
}

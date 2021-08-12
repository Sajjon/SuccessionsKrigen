import XCTest

@testable import SuccessionsKrigen

final class SuccessionsKrigenTests: XCTestCase {
    
    private let heroes2AggFileName = "HEROES2.AGG"
    private let gameFilesPath = "/Users/sajjon/Developer/Fun/Games/HoMM/HoMM_2_Gold_GAME_FILES/"
    private lazy var dataPath = "\(gameFilesPath)/DATA"
    private lazy var mapsPath = "\(gameFilesPath)/MAPS"
    private lazy var heroes2AggFilePath = "\(dataPath)/\(heroes2AggFileName)"
    
    func test_assert_can_open_heroes2agg_agg_file() throws {
        XCTAssertNoThrow(try AGGFile(path: heroes2AggFilePath))
    }
    
    func test_assert_size_of_heroes2agg_agg_file() throws {
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        XCTAssertEqual(aggFile.size, 43363026)
        XCTAssertEqual(aggFile.size, AGGFile.heroes2.size)
    }
    
    func testIntConversion() {
        func doTest(uint16: UInt16, expected: Int16) {
            let converted: Int16 = .init(bitPattern: uint16)
            XCTAssertEqual(converted, expected)
        }
        doTest(uint16: 65516, expected: -20)
        doTest(uint16: 65520, expected: -16)
        doTest(uint16: 65528, expected: -8)
        doTest(uint16: 65517, expected: -19)
        
    }
    
    func test_assert_number_of_records_in_heroes2agg_agg_file() throws {
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        XCTAssertEqual(aggFile.numberOfRecords, 1434)
        XCTAssertEqual(aggFile.numberOfRecords, AGGFile.heroes2.numberOfRecords)
    }
    
    func test_assert_contents_of_peasant_data_file_in_heroes2agg_agg_file() throws {
        
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        let creatureData = aggFile.dataFor(creature: .peasant)
        
        XCTAssertEqual(creatureData.hexDescription, "01feffc8ff0000000000000000000000000000000000000000000000000000000000000000000509111519202700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3f5a83ec3f5a83ec3f5a83e0000000000000000ee02000000000000000000000000000000000000da160000d101000052030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fdffffff00000800000800010101010000070301060100000702000008010000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffff01ffffffffffffffffffffffffffffff02ffffffffffffffffffffffffffffff03ffffffffffffffffffffffffffffff04ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0d0e0f22232425ffffffffffffffffff0d0e0fffffffffffffffffffffffffff0effffffffffffffffffffffffffffff101112131415ffffffffffffffffffff16ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1011121718191affffffffffffffffff1b1cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1011121d1e1f2021ffffffffffffffff20ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")
        
    }
    
    func test_assert_contents_of_archer_data_file_in_heroes2agg_agg_file() throws {
        
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        let creatureData = aggFile.dataFor(creature: .archer)
        
        XCTAssertEqual(creatureData.hexDescription, "010200c7ff000000000000000000000000000000000000000000000000000000000000000000040912141a222800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003cdcc4c3ecdcccc3ecdcccc3e00000000000000005e0100005e010000e80300005e01000000000000e21d0000d101000052030000000000002800c2ff3e00d1ff2800ffff090000b4420a0034424585d4416e1a9241000000006e1a92c14585d4c10a0034c20000b4c2000000000000000000000000030000000000000000000800000800010402030000060302060400000605000006050000070107010701ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffff01ffffffffffffffffffffffffffffff02030403ffffffffffffffffffffffff0203ffffffffffffffffffffffffffff030403ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2d2e2f303132ffffffffffffffffffff0d0e0fffffffffffffffffffffffffff0e0dffffffffffffffffffffffffffff202223242526ffffffffffffffffffff25232220ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff202223272829ffffffffffffffffffff2827232220ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2022232a2b2cffffffffffffffffffff2b2a232220ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff10111213141516ffffffffffffffffff17ffffffffffffffffffffffffffffff1011121318191affffffffffffffffff1bffffffffffffffffffffffffffffff101112131c1d1effffffffffffffffff1fffffffffffffffffffffffffffffff")
        
    }
    
    func test_assert_contents_of_water_elemental_data_file_in_heroes2agg_agg_file() throws {
        
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        let creatureData = aggFile.dataFor(creature: .waterElemental)
        
        XCTAssertEqual(creatureData.hexDescription, "010700bbff000000000000000000000000000000000000000000000000000000000000000000060810171c2029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000803f00000000000000000000000000000000ee02000000000000000000000000000000000000b42d0000d10100005203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000007000000000008000008000103000000000b0302040300000503000006030000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffff01ffffffffffffffffffffffffffffff020304ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1f20212223242526272829ffffffffff0d0e0fffffffffffffffffffffffffff0e0dffffffffffffffffffffffffffff10111213ffffffffffffffffffffffff121110ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1415161718ffffffffffffffffffffff171514ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff191a1b1c1d1effffffffffffffffffff1d1a19ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")
        
    }
    
    
    func test_assert_data_for_all_elementals_in_heroes2agg_agg_file_are_the_same() throws {
        
        func animationDataHex(for creature: Creature) throws -> String {
            let aggFile = try AGGFile(path: heroes2AggFilePath)
            return aggFile.dataFor(creature: creature).hexDescription
        }
        
        XCTAssertAllEqual([
            try animationDataHex(for: .airElemental),
            try animationDataHex(for: .earthElemental),
            try animationDataHex(for: .fireElemental),
            try animationDataHex(for: .waterElemental)
        ])
    }
    
    func testLoadMapMetaData() throws {
        let mapLoader = MapLoader()
        /// Name of map is "Pandemonium", but name of file is "PANDAMON.MP2", difficulty is "HARD:
        let pathToMap_Pandemonium = "\(mapsPath)/PANDAMON.MP2"
        print("pathToMap_Pandemonium: \(pathToMap_Pandemonium)")
        let map = try mapLoader.loadMap(filePath: pathToMap_Pandemonium)
        let mapMetaData = map.metaData
        
        XCTAssertEqual(mapMetaData.fileName, "PANDAMON.MP2")
        XCTAssertEqual(mapMetaData.name, "Pandemonium")
        XCTAssertEqual(mapMetaData.description, "The King will sell you this land for 200,000 gold or you can take it by force. The choice is yours.")
        XCTAssertEqual(mapMetaData.size, .small)
        XCTAssertEqual(mapMetaData.difficulty, .hard)
        XCTAssertEqual(mapMetaData.victoryCondition, .accumlateGoldAmount(200_000))
        XCTAssertEqual(mapMetaData.defeatCondition, .loseSpecificTownLocated(at: .init(x: 19, y: 4)))
        XCTAssertEqual(mapMetaData.computerCanWinUsingVictoryCondition, false)
        XCTAssertEqual(mapMetaData.victoryCanAlsoBeAchivedByDefeatingAllEnemyHeroesAndTowns, true)
        XCTAssertEqual(mapMetaData.isStartingWithHeroInEachCastle, false)
        XCTAssertEqualDictionaries(mapMetaData.racesByColor, [
            .blue: .random,
            .green: .random,
            .red: .random,
            .yellow: .necromancer,
            .orange: .neutral,
            .purple: .neutral
        ])
        
        XCTAssertNil(mapMetaData.expansionPack)
        
        
        func doAssertTile(at indexOfTile: Int, expectedTile: (_ indexOfTile: Int) -> Map.Tile, _ line: UInt = #line) {
            let actual = map.tiles[indexOfTile]
            let expected = expectedTile(indexOfTile)
            XCTAssertEqual(actual.debugDescription, expected.debugDescription, line: line)
        }
        
        doAssertTile(at: 0, expectedTile: {
            .expected(
                index: $0, point: .init(x: 0, y: 0),
                mp2TileIndex: 415,
                uniq: 2026,
                mp2Object: .ancientLamp,
                tileset: 184, tilesetIcon: .OBJNRSRC,
                objectIndex: 15, isAnimated: false,
                level: 0,
                region: 8,
                ground: .beach, isRoad: false,
                passable: [.center, .right, .bottomRight, .bottom],
                quantity1: 0,
                quantity2: 4,
                level1Addons: [
                    Map.Level.AddOn.expected(
                        uniq: 2340,
                        tileset: 196, tilesetIcon: .TREDECI,
                        index: 32,
                        level: (202, 2)
                    )
                ]
            )
        }
        )
        

        doAssertTile(at: 1, expectedTile: {
            .expected(
                index: $0, point: .init(x: 1, y: 0),
                mp2TileIndex: 419,
                uniq: 2340,
                mp2Object: .trees,
                tileset: 196, tilesetIcon: .TREDECI,
                objectIndex: 33, isAnimated: false,
                level: 0,
                region: 0,
                ground: .beach, isRoad: false,
                passable: nil,
                quantity1: 2,
                quantity2: 0,
                level1Addons: [
                    .expected(
                        uniq: 2337,
                        tileset: 196, tilesetIcon: .TREDECI,
                        index: 20,
                        level: (2, 2)
                    ),
                    .expected(
                        uniq: 2338,
                        tileset: 196, tilesetIcon: .TREDECI,
                        index: 26,
                        level: (202, 2)
                    )
                ],
                level2Addons: [
                    .expected(
                        uniq: 2342,
                        tileset: 220, tilesetIcon: .OBJNDSRT,
                        index: 7,
                        level: (2, 2)
                    )
                ]
            )
        }
        )
        
        
        
        doAssertTile(at: 163, expectedTile: {
            .expected(
                index: $0, point: .init(x: 19, y: 4),
                mp2TileIndex: 418,
                uniq: 1176,
                mp2Object: .randomCastle,
                tileset: 152, tilesetIcon: .OBJNTWRD,
                objectIndex: 13, isAnimated: false,
                level: 0,
                region: 0,
                ground: .beach, isRoad: false,
                passable: .all,
                quantity1: 8,
                quantity2: 0,
                level1Addons: [
                    Map.Level.AddOn.expected(
                        uniq: 1176,
                        tileset: 144, tilesetIcon: .OBJNTWBA,
                        index: 72,
                        level: (202, 2)
                    )
                ]
            )
        }
        )
        
        XCTAssertEqual(map.eventsDay.first!.resources, nil)
        XCTAssertEqual(map.eventsDay.first!.allowComputer, false)
        XCTAssertEqual(map.eventsDay.first!.dayOfFirstOccurent, 1)
        XCTAssertEqual(map.eventsDay.first!.subsequentOccurrences, 0)
        XCTAssertEqual(map.eventsDay.first!.message, "My leige, we have established a foothold (which we cannot afford to lose) and all of our Heroes have joined us. The king has made us the offer to purchase this land for 200,000 gold or we may take it by force. The local lords have been fighting and each wants to be the one that defeats us. Now all the local armies have arrived on the beach, creating a state of complete Pandemonium!")
    }
}

private extension Map.Tile {

    static func expected(
        index: Int,
        point: Point,
        mp2TileIndex tileIndex: Int,
        uniq: UInt32,
        mp2Object: Map.Tile.Info.ObjectType,
        tileset: Int,
        tilesetIcon: Icon.Raw,
        objectIndex infoLevel1Index: UInt8,
        isAnimated: Bool,
        level: Int,
        region: Int,
        ground: Ground, isRoad: Bool,
        passable: Passability?,
        quantity1: Int,
        quantity2: Int,
        quantity3: Int = 0,
        level1Addons: [Map.Level.AddOn],
        level2Addons: [Map.Level.AddOn] = []
    ) -> Self {
        let iconFromTileset = Icon.fromObjectTileset(tileset)!
        precondition(iconFromTileset.raw == tilesetIcon)
        
        
        let tile = Self(
            index: index,
            worldPosition: point,
            quantity3: quantity3,
            
            info: .init(
                tileIndex: tileIndex,
                
                level1: .init(
                    object: tileset,
                    index: .init(infoLevel1Index),
                    uid: uniq,
                    quantity: quantity1
                ),
                
                level2: .init(
                    object: .dontKnowAndWontAssert,
                    index: .dontKnowAndWontAssert,
                    uid: .dontKnowAndWontAssert,
                    quantity: quantity2
                ),
                
                flags: .dontKnowAndWontAssert,
                objectType: mp2Object,
                nextAddonIndex: .dontKnowAndWontAssert,
                unique: uniq,
                level1AddOns: level1Addons,
                level2AddOns: level2Addons
            )
        )
        
        assert(tile.isRoad == isRoad)
        
        return tile
    }
}



private extension Map.Level.AddOn {
    
    static func expected(
        uniq: UInt32,
        tileset object: Int,
        tilesetIcon: Icon.Raw,
        index: Int,
        level: (Int, Int)
    ) -> Self {
        precondition(level.1 == level.0 % 4)
        let addOn = Self(level: level.0, unique: uniq, object: object, index: index)
        assert(addOn.icon.raw == tilesetIcon)
        return addOn
    }
}

private extension Int {
    static let dontKnowAndWontAssert: Self = -1
}

private extension UInt32 {
    static let dontKnowAndWontAssert: Self = 0
}

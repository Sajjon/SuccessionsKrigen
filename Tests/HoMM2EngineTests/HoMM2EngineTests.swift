import XCTest

import HoMM2Engine

final class HoMM2EngineTests: XCTestCase {
    
    private let heroes2AggFileName = "heroes2.agg"
    private let dataPath = "/Users/sajjon/Developer/Fun/Games/HoMM/HoMM_2_Gold_GAME_FILES/DATA"
    private lazy var heroes2AggFilePath = "\(dataPath)/\(heroes2AggFileName)"
    
    func test_assert_can_open_heroes2agg_agg_file() throws {
        XCTAssertNoThrow(try AGGFile(path: heroes2AggFilePath))
    }
    
    
    func test_assert_size_of_heroes2agg_agg_file() throws {
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        XCTAssertEqual(aggFile.size, 43363026)
    }

    func test_assert_number_of_records_in_heroes2agg_agg_file() throws {
        let aggFile = try AGGFile(path: heroes2AggFilePath)
        XCTAssertEqual(aggFile.numberOfRecords, 1434)
    }
    
    func test_assert_contents_of_peasant_animation_data_file_in_heroes2agg_agg_file() throws {

        let aggFile = try AGGFile(path: heroes2AggFilePath)
        let peasantCreateureInfoRawData = try aggFile.read(fileName: CreatureInfo.peasant.binFileName)

        XCTAssertEqual(peasantCreateureInfoRawData.hexDescription, "01feffc8ff0000000000000000000000000000000000000000000000000000000000000000000509111519202700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3f5a83ec3f5a83ec3f5a83e0000000000000000ee02000000000000000000000000000000000000da160000d101000052030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fdffffff00000800000800010101010000070301060100000702000008010000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff05060708090a0b0cffffffffffffffffffffffffffffffffffffffffffffffff01ffffffffffffffffffffffffffffff02ffffffffffffffffffffffffffffff03ffffffffffffffffffffffffffffff04ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0d0e0f22232425ffffffffffffffffff0d0e0fffffffffffffffffffffffffff0effffffffffffffffffffffffffffff101112131415ffffffffffffffffffff16ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1011121718191affffffffffffffffff1b1cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1011121d1e1f2021ffffffffffffffff20ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")

    }
}

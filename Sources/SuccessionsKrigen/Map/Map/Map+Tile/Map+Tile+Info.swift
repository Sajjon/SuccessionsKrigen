//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map.Tile {
    struct Info: Equatable {
        
        /// Tile index representing a type of surface: ocean, grass, snow, swamp, lava, desert, dirt, wasteland, beach.
        /// NOT to be confused with `Map.Tile`.index
        let tileIndex: Int
        
        /// level 1
        let level1: Map.Level
        
        /// level 2
        let level2: Map.Level
        
        /// First 2 bits responsible for tile shape (0 - 3). Subsequent 3 bits are still unknown. Possible values are 1 and 5. They are set only for tiles with transition between land and sea.
        let flags: Int
        
        /// "mapObject"
        let mapObjectType: Map.Tile.Info.MapObjectType
        
        /// Next add-on index. Zero value means it's the last addon chunk.
        let nextAddonIndex: Int
        
        let unique: Int
        
        let level1AddOns: [Map.Level.AddOn]
        let level2AddOns: [Map.Level.AddOn]
        
        //        private(set) var objectIndex: UInt8 = 255
        
    }
}

// MARK: Error
public extension Map.Tile.Info {
    enum Error: Swift.Error {
        case unknownObjectType(Map.Tile.Info.MapObjectType.RawValue)
    }
}

// MARK: Public
public extension Map.Tile.Info {
    
    /// Bitfield, first 3 bits are flags, rest is used as quantity
    var quantity1: Int { level1.quantity! }
    
    /// Used as a part of quantity, field size is actually 13 bits. Has most significant bits
    var quantity2: Int { level2.quantity! }
    
    func appendingLevel1AddOns(_ level1AddOns: [Map.AddOn]) -> Self {
//        var copy = self
//        copy.level1AddOns = level1AddOns
//        return copy
        fatalError()
    }
    
    func appendingLevel2AddOns(_ level2AddOns: [Map.AddOn]) -> Self {
        fatalError()
//        var copy = self
//        copy.level2AddOns = level2AddOns
//        return copy
    }
    
    
}

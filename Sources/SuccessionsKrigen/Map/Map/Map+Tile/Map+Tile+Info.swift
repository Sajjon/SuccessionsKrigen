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
        let objectType: Map.Tile.Info.ObjectType
        
        /// Next add-on index. Zero value means it's the last addon chunk.
        let nextAddonIndex: Int
        
        let unique: UInt32
        
        let level1AddOns: [Map.Level.AddOn]
        let level2AddOns: [Map.Level.AddOn]
        
        //        private(set) var objectIndex: UInt8 = 255
        
        public init(
            tileIndex: Int,
            level1: Map.Level,
            level2: Map.Level,
            flags: Int,
            objectType: Map.Tile.Info.ObjectType,
            nextAddonIndex: Int,
            unique: UInt32 = 0,
            level1AddOns: [Map.Level.AddOn] = [],
            level2AddOns: [Map.Level.AddOn] = []
        ) {
      
            self.tileIndex = tileIndex
            self.level1 = level1
            self.level2 = level2
            self.flags = flags
            self.objectType = objectType
            self.nextAddonIndex = nextAddonIndex
            self.unique = unique
            self.level1AddOns = level1AddOns
            self.level2AddOns = level2AddOns
        }
        
    }
}


// MARK: Initializers
public extension Map.Tile.Info {
    
    init(info: Self, overridingUnique: UInt32) {
        self.init(
            info: info,
            
            overriding: (
                tileIndex: nil,
                level1: nil,
                level2: nil,
                flags: nil,
                objectType: nil,
                nextAddonIndex: nil,
                unique: overridingUnique,
                level1AddOns: nil,
                level2AddOns: nil
            )
        )
    }
    
    init(info: Self, overridingLevel1Addons: [Map.Level.AddOn]) {
        self.init(
            info: info,
            
            overriding: (
                tileIndex: nil,
                level1: nil,
                level2: nil,
                flags: nil,
                objectType: nil,
                nextAddonIndex: nil,
                unique: nil,
                level1AddOns: overridingLevel1Addons,
                level2AddOns: nil
            )
        )
    }
    
    
    init(info: Self, overridingLevel2Addons: [Map.Level.AddOn]) {
        self.init(
            info: info,
            
            overriding: (
                tileIndex: nil,
                level1: nil,
                level2: nil,
                flags: nil,
                objectType: nil,
                nextAddonIndex: nil,
                unique: nil,
                level1AddOns: nil,
                level2AddOns: overridingLevel2Addons
            )
        )
    }
    
    init(
        info: Self,
        replacementLevel1AddOns: [Map.AddOn],
        replacementLevel2AddOns: [Map.AddOn]
    ) {
        
        self.init(
            tileIndex: info.tileIndex,
            level1: info.level1,
            level2: info.level2,
            flags: info.flags,
            objectType: info.objectType,
            nextAddonIndex: info.nextAddonIndex,
            unique: info.unique,
            level1AddOns: replacementLevel1AddOns.compactMap { (addOn: Map.AddOn) -> Map.Level.AddOn? in
                guard addOn.level1.object > 0 && addOn.level1.index < 0xFF else { return nil }
                return Map.Level.AddOn(
                    level: addOn.quantityN,
                    unique: addOn.level1.uid,
                    object: addOn.level1.object,
                    index: addOn.level1.index
                )},
            
            level2AddOns: replacementLevel2AddOns.compactMap { (addOn: Map.AddOn) -> Map.Level.AddOn? in
                guard addOn.level2.object > 0 && addOn.level2.index < 0xFF else { return nil }
                return Map.Level.AddOn(
                    level: addOn.quantityN,
                    unique: addOn.level2.uid,
                    object: addOn.level2.object,
                    index: addOn.level2.index
                )
            }
        )
    }
    
}
private extension Map.Tile.Info {
    
    init(
        info: Self,
        overriding maybeOverriding: (
            tileIndex: Int?,
            level1: Map.Level?,
            level2: Map.Level?,
            flags: Int?,
            objectType: Map.Tile.Info.ObjectType?,
            nextAddonIndex: Int?,
            unique: UInt32?,
            level1AddOns: [Map.Level.AddOn]?,
            level2AddOns: [Map.Level.AddOn]?
        )?
    ) {
        guard let overriding = maybeOverriding else {
            self.init(info: info, replacementLevel1AddOns: [], replacementLevel2AddOns: [])
            return
        }
        self.init(
            tileIndex: overriding.tileIndex ?? info.tileIndex,
            level1: overriding.level1 ?? info.level1,
            level2: overriding.level2 ?? info.level2,
            flags: overriding.flags ?? info.flags,
            objectType: overriding.objectType ?? info.objectType,
            nextAddonIndex: overriding.nextAddonIndex ?? info.nextAddonIndex,
            unique: overriding.unique ?? info.unique,
            level1AddOns: overriding.level1AddOns ?? info.level1AddOns,
            level2AddOns: overriding.level2AddOns ?? info.level2AddOns
        )
    }
}

// MARK: Error
public extension Map.Tile.Info {
    enum Error: Swift.Error {
        case unknownObjectType(Map.Tile.Info.ObjectType.RawValue)
    }
}

// MARK: Public
public extension Map.Tile.Info {
    
    /// Bitfield, first 3 bits are flags, rest is used as quantity
    var quantity1: Int { level1.quantity! }
    
    /// Used as a part of quantity, field size is actually 13 bits. Has most significant bits
    var quantity2: Int { level2.quantity! }
    
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


// MARK: Tile
public extension Map {
    struct Tile: Equatable, CustomDebugStringConvertible {
        public typealias Passability = Direction
        
        /// NOT to be confused with: `info.tileIndex`
        let index: Int
        let info: Info
        let worldPosition: WorldPosition
        
        let isRoad: Bool
        let level: Int
        
        private(set) var quantity1: Int
        private(set) var quantity2: Int
        
        
        /// Metadata field (used for things like adventure spell ID)
        let quantity3: Int
        
        
        // MARK: Init
        public init(
            index: Int,
            worldPosition: WorldPosition,
            quantity1: Int? = nil,
            quantity2: Int? = nil,
            quantity3: Int = 0,
            info: Info
        ) {
            var unique = 0
            
            let level = info.quantity1 & 0x03
            self.level = level
            
            if !(info.objectType == .nothing && ((level >> 1) & 1) != 0) {
                unique = info.level1.uid
            }
            
            if !info.level1AddOns.isEmpty {
                unique = info.level1AddOns.last!.unique
            }

            self.index = index
       
            self.info = Map.Tile.Info(info: info, overridingUnique: unique)
            self.worldPosition = worldPosition
            self.isRoad = (( info.level1.object >> 1 ) & 1) != 0
            self.quantity3 = quantity3
            
            self.quantity1 = quantity1 ?? info.quantity1
            self.quantity2 = quantity2 ?? info.quantity2
            
        }
    }
}

public extension Map.Tile {
    var objectIndex: Int {
        info.level1.index
    }
    
    var objectTileset: Int {
        info.level1.object
    }
    
    var icon: Icon {
        guard let icon = Icon.fromObjectTileset(objectTileset) else {
            fatalError("failed to get icon from objectTileset: \(objectTileset)")
        }
        return icon
    }
    
    var iconName: String {
        icon.iconFileName
    }
    
    var hasSpriteAnimation: Bool {
        objectTileset & 1 != 0
    }
    
    var monsterCount: Int {
        (quantity1 << 8) | quantity2
    }
    
    var ground: Ground {
        let groundId = UInt16(info.tileIndex) & 0x3FFF
        // list grounds from `GROUND32.TIL`
        if 30 > groundId {
            return .water
        } else if 92 > groundId {
            return .grass
        } else if 146 > groundId {
            return .snow
        } else if 208 > groundId {
            return .swamp
        } else if 262 > groundId {
            return .lava
        } else if 321 > groundId {
            return .desert
        } else if 361 > groundId {
            return .dirt
        } else if 415 > groundId {
            return .wasteland
        } else {
            return .sand
        }
    }
}


// MARK: CustomDebugStringConvertible
public extension Map.Tile {
    
    var debugDescription: String {
        let addOnsLevel1String = info.level1AddOns.map {
            $0.debugString(prefix: "----------------1--------")
        }.joined(separator: "\n")
        let addOnsLevel2String = info.level2AddOns.map {
            $0.debugString(prefix: "----------------2--------")
        }.joined(separator: "\n")
        
        let extraObjectInfoString: String = {
            var extraObjectInfo = ""
            
            switch info.objectType {
            case .ruins, .treeCity, .wagonCamp, .desertTent, .trollBridge, .dragonCity, .cityDead, .watchTower, .excavation, .cave, .treeHouse, .archerHouse, .goblinHut, .dwarfCottage, .halflingHole, .peasantHut, .thatchedHut, .monster:
                extraObjectInfo += "count           : \(monsterCount)"
                
            case .heroes:
                extraObjectInfo += "HERO but unknown which"
            case .castleN, .castle:
                extraObjectInfo += "CASTLE but unknown which"
            default:
                break
                // TODO check capturedObjects and check guarded tiles
            }
            
            return extraObjectInfo
        }()
        
        
        return """
        \n\n----------------:>>>>>>>>
        index           : \(index), point: (\(worldPosition.x), \(worldPosition.y))
        mp2.tileIndex:  : \(info.tileIndex)
        unique          : \(info.unique)
        mp2 object      : \(info.objectType.rawValue), (\(info.objectType)
        tileset         : \(objectTileset), (\(iconName)
        object index    : \(objectIndex), (animated: \(hasSpriteAnimation)
        level           : \(level)
        region          : NOT_IMPLEMENTED
        ground          : \(ground), (isRoad: \(isRoad)
        passable        : \(passability)
        quantity 1      : \(quantity1)
        quantity 2      : \(quantity2)
        quantity 3      : \(quantity3)
        \(addOnsLevel1String)\(addOnsLevel2String)
        ----------------I--------
        \(extraObjectInfoString)
        ----------------:>>>>>>>>\n\n
        """
    }
}

// MARK: Public
public extension Map.Tile {
    
    func raceAndColorOfOccupyingHero() -> (color: Map.Color, race: Race) {
        guard case .heroes = info.objectType else { fatalError("wrong mapobject type") }
        
        let heroSpriteIndex = index
        
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

}

// MARK: Private

private extension Map.Tile {
    
    var isEmpty: Bool {
        let isEmpty = objectTileset == 0 || objectIndex == 255 || (((level >> 1) & 1) > 0)
        assert(info.objectType == .nothing)
        return isEmpty
    }
    
    var passability: Passability {
        return .all
//        if info.objectType.isActionObject {
//            return info.objectType.actionObjectDirection
//        }
//
//        if isEmpty {
//            // No object exists. Make it fully passable.
//            return .all
//        }
//
//        // Objects have fixed passability.
//        return [.centerRow, .bottomRow]
 
    }
}


// MARK: Post init
extension Map.Tile {
    func fixedPreload() -> Self {
        self
    }
    
    func updatedQuantity(isFirstLoad: Bool = true) -> Self {
        var withUpdatedQuantity = self
        switch info.objectType {
        case .ancientLamp:
            if isFirstLoad {
                let minQ: UInt32 = 2
                let maxQ: UInt32 = 4
                var newCount: UInt32 = .random(in: minQ...maxQ)
                #if DEBUG
                newCount = maxQ
                #endif
                withUpdatedQuantity = updatedMonsterCount(newCount)
            }
        default: break
        }
        return withUpdatedQuantity
    }
}

private extension Map.Tile {
    func updatedMonsterCount(_ newMonsterCount: UInt32) -> Self {
        let quantity1 = newMonsterCount >> 8
        let quantity2 = 0x00FF & newMonsterCount
        return Self(
            index: index,
            worldPosition: worldPosition,
            quantity1: .init(quantity1),
            quantity2: .init(quantity2),
            quantity3: quantity3,
            info: info
        )
    }
}


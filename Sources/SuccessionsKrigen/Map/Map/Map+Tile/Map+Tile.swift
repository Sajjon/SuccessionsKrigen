//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map.Tile {
    struct Direction: OptionSet, CustomStringConvertible, CaseIterable {
        
        /// In clockwise order
        public static var allCases: [Map.Tile.Direction] = [.center, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left, .topLeft]
        
        public typealias RawValue = Int
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        // In clockwise order
        static let center       = Self(rawValue: 1 << 0)
        static let top          = Self(rawValue: 1 << 1)
        static let topRight     = Self(rawValue: 1 << 2)
        static let right        = Self(rawValue: 1 << 3)
        static let bottomRight  = Self(rawValue: 1 << 4)
        static let bottom       = Self(rawValue: 1 << 5)
        static let bottomLeft   = Self(rawValue: 1 << 6)
        static let left         = Self(rawValue: 1 << 7)
        static let topLeft      = Self(rawValue: 1 << 8)
    }
}

// MARK: Compound direction
public extension Map.Tile.Direction {
    static let topRow: Self = [.topLeft, .top, .topRight]
    static let bottomRow: Self = [.bottomLeft, .bottom, .bottomRight]
    static let centerRow: Self = [.left, .center, .right]
    
    static let leftColumn: Self = [.topLeft, .left, .bottomLeft]
    static let centerColumn: Self = [.top, .center, .bottom]
    static let rightColumn: Self = [.topRight, .right, .bottomRight]
    
    static let all: Self = [.topRow, .bottomRow, .centerRow]
    static let around: Self = [.topRow, .bottomRow, .left, .right]
    
    static let topRightCorner: Self = [.top, .topRight, .right]
    static let topLeftCorner: Self = [.top, .topLeft, .left]
    
    static let bottomRightCorner: Self = [.bottom, .bottomRight, .right]
    static let bottomLeftCorner: Self = [.bottom, .bottomLeft, .left]
    
    static let allCorners: Self = [.topRight, .bottomRight, .bottomLeft, .topLeft]
}


// MARK: CustomStringConvertible
public extension Map.Tile.Direction {
    var description: String {
        var directions = [String]()
        if contains(.center) {
            directions.append("center")
        }
        if contains(.top) {
            directions.append("top")
        }
        if contains(.topRight) {
            directions.append("top right")
        }
        if contains(.right) {
            directions.append("right")
        }
        if contains(.bottomRight) {
            directions.append("bottom right")
        }
        if contains(.bottom) {
            directions.append("bottom")
        }
        if contains(.bottomLeft) {
            directions.append("bottom left")
        }
        if contains(.left) {
            directions.append("left")
        }
        if contains(.topLeft) {
            directions.append("top left")
        }
        return directions.joined(separator: ", ")
    }
}

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
        
        /// Metadata field (used for things like adventure spell ID)
        let quantity3: Int
        
        // MARK: Init
        public init(
            index: Int,
            info: Info,
            worldPosition: WorldPosition,
            quantity3: Int = 0
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
    
    var quantity1: Int { info.level1.quantity! }
    var quantity2: Int { info.level2.quantity! }
    
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
        /*
         ----------------:>>>>>>>>
         Tile index      : 163, point: (19, 4)
         uniq            : 1176
         mp2 object      : 177, (Random Castle)
         tileset         : 152, (OBJNTWRD.ICN)
         object index    : 13, (animated: 0)
         level           : 0
         region          : 0
         ground          : Beach, (isRoad: 0)
         passable        : center,top,top right,right,bottom right,bottom,bottom left,left,top left,
         quantity 1      : 8
         quantity 2      : 0
         quantity 3      : 0
         ----------------1--------
         uniq            : 1176
         tileset         : 144, (OBJNTWBA.ICN)
         index           : 72
         level           : 202, (2)
         ----------------I--------
         ----------------:<<<<<<<<
         */
        
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
        Tile index      : \(index), point: (\(worldPosition.x), \(worldPosition.y))
        unique          : \(info.unique)
        mp2 object      : \(info.objectType.rawValue), (\(info.objectType)
        tileset         : \(objectTileset), (\(iconName)
        object index    : \(objectIndex), (animated: \(hasSpriteAnimation)
        level           : \(level)
        region          : NOT_IMPLEMENTED
        ground          : \(ground), (isRoad: \(isRoad)
        passable        : \(passability)
        quantity 1      : \(info.level1.quantity!)
        quantity 2      : \(info.level2.quantity!)
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

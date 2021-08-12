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
        public let index: Int
        public private(set) var info: Info
        public let worldPosition: WorldPosition
        
        internal private(set) var isRoad: Bool
        internal private(set) var level: Int
        
        internal private(set) var quantity1: Int
        internal private(set) var quantity2: Int
        
        
        /// Metadata field (used for things like adventure spell ID)
        let quantity3: Int
        
        internal private(set) var passability: Passability?
        
        internal private(set) var objectTileset: Int
        
        internal private(set) var objectIndex: Int
        
        
        // MARK: Init
        public init(
            index: Int,
            worldPosition: WorldPosition,
            quantity1: Int? = nil,
            quantity2: Int? = nil,
            quantity3: Int = 0,
            passability: Passability? = .all,
            info infoWeMightWannaOverride: Info
        ) {
            let unique: UInt32
            var info = infoWeMightWannaOverride
            let level = info.quantity1 & 0x03
            self.level = level
            
            var isRoad = (( info.level1.object >> 1 ) & 1) != 0
            
            var objectTileset = 0
            var objectIndex =  0
            
            // If an object has priority 2 (shadow) or 3 (ground) then we put it as an addon.
            if info.objectType == .nothing && ((level >> 1) & 1) != 0 {
                var level1AddonsOverride = info.level1AddOns
       
                if info.level1.object > 0 && info.level1.index < 0xff {
                    level1AddonsOverride.append(.init(level: info.quantity1, unique: info.level1.uid, object: info.level1.object, index: info.level1.index))
                }
                
                if ((info.level1.object >> 1) & 1) != 0 {
                    isRoad = true
                }
                
                
                info = .init(info: info, overridingLevel1Addons: level1AddonsOverride)
                
                unique = 0
              
            } else {
                objectTileset = info.level1.object
                objectIndex = info.level1.index
                unique = info.level1.uid
            }
            

            if info.level2.object > 0 && info.level2.index < 0xff {
                var level2AddonsOverride = info.level2AddOns
                level2AddonsOverride.append(.init(level: info.quantity1, unique: info.level2.uid, object: info.level2.object, index: info.level2.index))
                info = .init(info: info, overridingLevel2Addons: level2AddonsOverride)
            }

      
            self.index = index
       
            self.info = Map.Tile.Info(info: info, overridingUnique: unique)
            self.worldPosition = worldPosition
            self.isRoad = isRoad
            self.quantity3 = quantity3
            
            self.quantity1 = quantity1 ?? info.quantity1
            self.quantity2 = quantity2 ?? info.quantity2
            self.passability = passability
            
            self.objectTileset = objectTileset
            self.objectIndex =  objectIndex
        }
    }
}

public extension Map.Tile {
    
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
        mp2 object      : \(info.objectType.rawValue), (\(info.objectType))
        tileset         : \(objectTileset), (\(iconName))
        object index    : \(objectIndex), (animated: \(hasSpriteAnimation))
        level           : \(level)
        region          : NOT_IMPLEMENTED
        ground          : \(ground), (isRoad: \(isRoad))
        passable        : \(passability != nil ? String(describing: passability!) : "false")
        quantity 1      : \(quantity1)
        quantity 2      : \(quantity2)
        quantity 3      : \(quantity3)
        \(addOnsLevel1String)
        \(addOnsLevel2String)
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
    
    func isValidDirection(from: WorldPosition, direction vector: Direction, worldWidth: Map.Size.RawValue) -> Bool {
        let width = worldWidth
        
        switch vector {
        case .top: return from.x >= width
        default: return true // TODO fix me
        }
        
        
        /*
         // check bound
         bool Maps::isValidDirection( int32_t from, int vector )
         {
             const int32_t width = world.w();

             switch ( vector ) {
             case Direction::TOP:
                 return ( from >= width );
             case Direction::RIGHT:
                 return ( ( from % width ) < ( width - 1 ) );
             case Direction::BOTTOM:
                 return ( from < width * ( world.h() - 1 ) );
             case Direction::LEFT:
                 return ( from % width ) != 0;

             case Direction::TOP_RIGHT:
                 return ( from >= width ) && ( ( from % width ) < ( width - 1 ) );

             case Direction::BOTTOM_RIGHT:
                 return ( from < width * ( world.h() - 1 ) ) && ( ( from % width ) < ( width - 1 ) );

             case Direction::BOTTOM_LEFT:
                 return ( from < width * ( world.h() - 1 ) ) && ( from % width );

             case Direction::TOP_LEFT:
                 return ( from >= width ) && ( from % width );

             default:
                 break;
             }

             return false;
         }
         */
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
    
    func updatedPassability(mapSize: Map.Size) -> Self {
        
        var copy = self
        var directions: Direction = copy.passability ?? []
        
        let worldWidth = mapSize.rawValue // assumes rectangular map...
        
        
//        if !info.objectType.isActionObject &&  objectTileset > 0 && objectIndex < 255 && ((level >> 1) & 1) == 0 {
//
//        }
        
        /*
         
         void Maps::Tiles::updatePassability()
         {
             if ( !Maps::isValidDirection( _index, Direction::LEFT ) ) {
                 tilePassable &= ~( Direction::LEFT | Direction::TOP_LEFT | Direction::BOTTOM_LEFT );
             }
             if ( !Maps::isValidDirection( _index, Direction::RIGHT ) ) {
                 tilePassable &= ~( Direction::RIGHT | Direction::TOP_RIGHT | Direction::BOTTOM_RIGHT );
             }
             if ( !Maps::isValidDirection( _index, Direction::TOP ) ) {
                 tilePassable &= ~( Direction::TOP | Direction::TOP_LEFT | Direction::TOP_RIGHT );
             }
             if ( !Maps::isValidDirection( _index, Direction::BOTTOM ) ) {
                 tilePassable &= ~( Direction::BOTTOM | Direction::BOTTOM_LEFT | Direction::BOTTOM_RIGHT );
             }

             const int objId = GetObject( false );
             const bool isActionObject = MP2::isActionObject( objId );
             if ( !isActionObject && objectTileset > 0 && objectIndex < 255 && ( ( _level >> 1 ) & 1 ) == 0 ) {
                 // This is a non-action object.
                 if ( Maps::isValidDirection( _index, Direction::BOTTOM ) ) {
                     const Tiles & bottomTile = world.GetTiles( Maps::GetDirectionIndex( _index, Direction::BOTTOM ) );

                     // If a bottom tile has the same object ID then this tile is inaccessible.
                     std::vector<uint32_t> tileUIDs;
                     if ( objectTileset > 0 && objectIndex < 255 && uniq != 0 && ( ( _level >> 1 ) & 1 ) == 0 ) {
                         tileUIDs.emplace_back( uniq );
                     }

                     for ( const TilesAddon & addon : addons_level1 ) {
                         if ( addon.uniq != 0 && ( ( addon.level >> 1 ) & 1 ) == 0 ) {
                             tileUIDs.emplace_back( addon.uniq );
                         }
                     }

                     for ( const uint32_t objectId : tileUIDs ) {
                         if ( bottomTile.doesObjectExist( objectId ) ) {
                             tilePassable = 0;
                             return;
                         }
                     }

                     if ( isWater() != bottomTile.isWater() ) {
                         // If object is bordering water then it must be marked as not passable.
                         tilePassable = 0;
                         return;
                     }

                     const bool isBottomTileObject = ( ( bottomTile._level >> 1 ) & 1 ) == 0;

                     if ( bottomTile.objectTileset > 0 && bottomTile.objectIndex < 255 && isBottomTileObject ) {
                         const int bottomTileObjId = bottomTile.GetObject( false );
                         const bool isBottomTileActionObject = MP2::isActionObject( bottomTileObjId );
                         if ( isBottomTileActionObject ) {
                             if ( ( MP2::getActionObjectDirection( bottomTileObjId ) & Direction::TOP ) == 0 ) {
                                 if ( isShortObject( bottomTileObjId ) ) {
                                     tilePassable &= ~( Direction::BOTTOM | Direction::BOTTOM_LEFT | Direction::BOTTOM_RIGHT );
                                 }
                                 else {
                                     tilePassable = 0;
                                     return;
                                 }
                             }
                         }
                         else if ( bottomTile.mp2_object != 0 && bottomTile.mp2_object < 128 && MP2::isActionObject( bottomTile.mp2_object + 128 )
                                   && isShortObject( bottomTile.mp2_object + 128 ) && ( bottomTile.getOriginalPassability() & Direction::TOP ) == 0 ) {
                             // TODO: add extra logic to handle Stables.
                             tilePassable &= ~( Direction::BOTTOM | Direction::BOTTOM_LEFT | Direction::BOTTOM_RIGHT );
                         }
                         else if ( isShortObject( bottomTile.mp2_object ) ) {
                             tilePassable &= ~( Direction::BOTTOM | Direction::BOTTOM_LEFT | Direction::BOTTOM_RIGHT );
                         }
                         else {
                             tilePassable = 0;
                             return;
                         }
                     }
                 }
                 else {
                     tilePassable = 0;
                     return;
                 }
             }

             // Left side.
             if ( ( tilePassable & Direction::TOP_LEFT ) && Maps::isValidDirection( _index, Direction::LEFT ) ) {
                 const Tiles & leftTile = world.GetTiles( Maps::GetDirectionIndex( _index, Direction::LEFT ) );
                 const bool leftTileTallObject = isTallObject( leftTile.GetObject( false ) );
                 if ( leftTileTallObject && ( leftTile.getOriginalPassability() & Direction::TOP ) == 0 ) {
                     tilePassable &= ~Direction::TOP_LEFT;
                 }
             }

             // Right side.
             if ( ( tilePassable & Direction::TOP_RIGHT ) && Maps::isValidDirection( _index, Direction::RIGHT ) ) {
                 const Tiles & rightTile = world.GetTiles( Maps::GetDirectionIndex( _index, Direction::RIGHT ) );
                 const bool rightTileTallObject = isTallObject( rightTile.GetObject( false ) );
                 if ( rightTileTallObject && ( rightTile.getOriginalPassability() & Direction::TOP ) == 0 ) {
                     tilePassable &= ~Direction::TOP_RIGHT;
                 }
             }
         }
*/
        
        copy.passability = directions
        return copy
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

extension Map.Tile {
    func withSortedAddonsAndVariousFixes() -> Self {
        var copy = self
        var level1Addons = copy.info.level1AddOns
        
        // Push everything to the container and sort it by level.
        if objectTileset != 0 && objectIndex < 255 {
            level1Addons.insert(.init(level: level, unique: info.unique, object: objectTileset, index: objectIndex), at: 0)
        }
        
        // Some original maps have issues with identifying tiles as roads. This code fixes it. It's not an ideal solution but works fine in most of cases.
        if !isRoad {
            copy.isRoad = copy.info.level1AddOns.contains(where: { $0.isRoad })
        }
        
        level1Addons = level1Addons.sorted(by: { $0.level % 4 > $1.level % 4  })
        
        if let highestPriorityAddon = level1Addons.last {
            copy.info = .init(info: copy.info, overridingUnique: highestPriorityAddon.unique)
            copy.objectTileset = highestPriorityAddon.object
            copy.objectIndex = highestPriorityAddon.index
            copy.level = highestPriorityAddon.level & 0x03
            level1Addons.removeLast()
        }
        
        copy.info = .init(info: copy.info, overridingLevel1Addons: level1Addons)
        
        return copy
    }
}

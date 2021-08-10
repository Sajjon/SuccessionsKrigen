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
        
        /// NOT to be confused with: `info.tileIndex`
        let index: Int
        let info: Info
        let worldPosition: WorldPosition
        
        let tileIsRoad: Bool
        /*

             uint16_t pack_sprite_index = 0;

             uint8_t objectTileset = 0;
             uint8_t objectIndex = 255;
             uint8_t mp2_object = 0;
             uint16_t tilePassable = DIRECTION_ALL;
             uint8_t fog_colors = Color::ALL;

             uint8_t heroID = 0;
             uint8_t quantity1 = 0;
             uint8_t quantity2 = 0;
             uint8_t quantity3 = 0;

             bool tileIsRoad = false;

             // These fields do not persist in savegame
             uint32_t _region = 0;
             uint8_t _level = 0;
         */
        
        
        // MARK: Init
        public init(
            index: Int,
            info: Info,
            worldPosition: WorldPosition
        ) {
            var addOnsLevel1 = [Map.Level.AddOn]()
            var unique = 0
            func addOnsPushLevel1() {
                fatalError()
                /*
                 
                 void Maps::Tiles::AddonsPushLevel1( const MP2::mp2tile_t & mt )
                 {
                     if ( mt.objectName1 && mt.indexName1 < 0xFF ) {
                         addons_level1.emplace_back( mt.quantity1, mt.level1ObjectUID, mt.objectName1, mt.indexName1 );
                     }

                     // MP2 "objectName" is a bitfield
                     // 6 bits is ICN tileset id, 1 bit isRoad flag, 1 bit hasAnimation flag
                     if ( ( mt.objectName1 >> 1 ) & 1 )
                         tileIsRoad = true;
                 }
                 */
                if info.level1.object > 0 && info.level1.index < 0xFF {
                   
                }
                
            }
            
            var addOnsLevel2 = [AddOn]()
            func addOnsPushLevel2() {
                fatalError()
                /*
                 void Maps::Tiles::AddonsPushLevel2( const MP2::mp2tile_t & mt )
                 {
                     if ( mt.objectName2 && mt.indexName2 < 0xFF ) {
                         addons_level2.emplace_back( mt.quantity1, mt.level2ObjectUID, mt.objectName2, mt.indexName2 );
                     }
                 }
                 */
            }
            
            func sortAddOns() {
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
                 */
            }
            
            let level = info.quantity1 & 0x03
            /*
             
                tilePassable = DIRECTION_ALL;

                _level = mp2.quantity1 & 0x03;
                quantity1 = mp2.quantity1;
                quantity2 = mp2.quantity2;
                quantity3 = 0;
                fog_colors = Color::ALL;

                SetTile( mp2.tileIndex, mp2.flags );
                SetIndex( index );
                SetObject( mp2.mapObject );

                addons_level1.clear();
                addons_level2.clear();

                // those bitfields are set by map editor regardless if map object is there
                tileIsRoad = ( mp2.objectName1 >> 1 ) & 1;

                // If an object has priority 2 (shadow) or 3 (ground) then we put it as an addon.
                if ( mp2.mapObject == MP2::OBJ_ZERO && ( _level >> 1 ) & 1 ) {
                    AddonsPushLevel1( mp2 );
                }
                else {
                    objectTileset = mp2.objectName1;
                    objectIndex = mp2.indexName1;
                    uniq = mp2.level1ObjectUID;
                }
                AddonsPushLevel2( mp2 );
             */
            if info.mapObjectType == .nothing && ((level >> 1) & 1) != 0 {
                addOnsPushLevel1()
            } else {
                unique = info.level1.uid
            }
            addOnsPushLevel2()
            
            // LASTly call sortAddons
            sortAddOns()
            
            fatalError()
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
        
        """
        ----------------:>>>>>>>>
        Tile index      : \(index), point: (\(worldPosition.x), \(worldPosition.y)
        unique          : \(info.unique)
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
        ----------------I--------
        ----------------:>>>>>>>>
        """
    }
}

// MARK: Public
public extension Map.Tile {
    
    func raceAndColorOfOccupyingHero() -> (color: Map.Color, race: Race) {
        guard case .heroes = info.mapObjectType else { fatalError("wrong mapobject type") }
        
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

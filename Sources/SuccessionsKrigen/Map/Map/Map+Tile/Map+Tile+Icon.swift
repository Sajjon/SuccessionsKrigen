//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

/// Info: https://thaddeus002.github.io/fheroes2-WoT/infos/ICN_Reference.html
/// More info: https://sourceforge.net/p/fheroes2/discussion/335992/thread/e4eeeb7b/#7197
public enum Icon: Equatable, Hashable {
    case mainMenuBackground
    case randomCastle
    case castleBase
    case phoenix
    case phoenixSpriteSet
    case mainMenuButtonsSpriteSet
    case creaturesSpriteSet
    case mainMenuShiningAnimationsSpriteSet
    case boatSpriteSet
    case smallMapArtifactsSpriteSet
    
    /// Castle flags
    case flagsSpriteSet
    case heroMinitiaturesForEditor
    
    case mountainsWastelandTerrainElementsSpriteSet
    case mountainsGrassTerrainElementsSpriteSet
    case mountainsSnowTerrainElementsSpriteSet
    case mountainsSwampTerrainElementsSpriteSet
    case mountainsLavaTerrainElementsSpriteSet
    case mountainsDesertTerrainElementsSpriteSet
    case mountainsDirtTerrainElementsSpriteSet
    case mountainsAllTerrainElementsSpriteSet
    case mineTypesSpriteSet
    case roadTerrainElementsSpriteSet
    case treesJungleTerrainElementsSpriteSet
    case treesEvilTerrainElementsSpriteSet
    case treesSnowTerrainElementsSpriteSet
    case treesFirTerrainElementsSpriteSet
    case treesDeciduousTerrainElementsSpriteSet
    case treesFallTerrainElementsSpriteSet
    case townMapObjectsSpriteSet
    case castleShadowsSpriteSet
    case mineGuardiansElementalsSpriteSet
    case waterObjectsSpriteSet
    case genericMapObjectsSpriteSet
    case genericMapObjectsSpriteSet2
    case streamTerrainElementsSpriteSet
    case resourceOnMapObjectSpriteSet
    case grassMapObjectSpriteSet
    case waterMapObjectSpriteSet
    case grassTerrainObjectSpriteSet
    case snowTerrainObjectSpriteSet
    case swampTerrainObjectSpriteSet
    
    case desertTerrainObjectSpriteSet
    case dirtTerrainObjectSpriteSet
    case wastelandTerrainObjectSpriteSet
    
    case lavaTerrainObjectSpriteSet
    case lavaTerrainObjectSpriteSet3
    case lavaTerrainObjectSpriteSet2
        

}


// MARK: Raw
public extension Icon {
    
    /// Info: https://thaddeus002.github.io/fheroes2-WoT/infos/ICN_Reference.html
    /// More info: https://sourceforge.net/p/fheroes2/discussion/335992/thread/e4eeeb7b/#7197
    enum Raw: String, Equatable, CaseIterable {
        
        /// mainMenuButtonsSpriteSet
        case BTNSHNGL,
             
        /// mainMenuBackground
        HEROES,
        
        /// Phoenix single sprite, not to be confused with `MONH0028` (phoenixSpriteSet)
        PHOENIX,
        
        /// phoenixSpriteSet
        MONH0028,
        
        /// randomCastle
        OBJNTWRD,
        
        /// creaturesSpriteSet
        MONS32,
        
        /// mainMenuShiningAnimationsSpriteSet
        SHNGANIM,
        
        /// castleBase
        OBJNTWBA,
        
        /// boatSpriteSet
        BOAT32,
        
        /// smallMapArtifactsSpriteSet
        OBJNARTI,
        
        /// flagsSpriteSet
        FLAG32,
        
        /// heroMinitiaturesForEditor
        MINIHERO,
        
        /// mountainsWastelandTerrainElementsSpriteSet
        MTNCRCK,
        
        /// mountainsGrassTerrainElementsSpriteSet
        MTNGRAS,
        
        /// mountainsSnowTerrainElementsSpriteSet
        MTNSNOW,
        
        /// mountainsSwampTerrainElementsSpriteSet
        MTNSWMP,
        
        /// mountainsLavaTerrainElementsSpriteSet
        MTNLAVA,
        
        /// mountainsDesertTerrainElementsSpriteSet
        MTNDSRT,
        
        /// mountainsDirtTerrainElementsSpriteSet
        MTNDIRT,
        
        /// mountainsAllTerrainElementsSpriteSet
        MTNMULT,
        
        /// mineTypesSpriteSet
        EXTRAOVR,
        
        /// roadTerrainElementsSpriteSet
        ROAD,
        
        /// treesJungleTerrainElementsSpriteSet
        TREJNGL,
        
        /// treesEvilTerrainElementsSpriteSet
        TREEVIL,
        
        /// treesSnowTerrainElementsSpriteSet
        TRESNOW,
        
        /// tressFir
        TREFIR,
        
        /// treesFallTerrainElementsSpriteSet
        TREFALL,
        
        /// treesDeciduousTerrainElementsSpriteSet
        TREDECI,
        
        /// townMapObjectsSpriteSet
        OBJNTOWN,
        
        /// Castle Shadow
        OBJNTWSH,
        
        /// Mine guardians (elementals)
        OBJNXTRA,
        
        /// Water object
        OBJNWAT2,
        
        /// Generic map object 1/2
        OBJNMULT,
        /// Generic map object 2/2
        OBJNMUL2,
        
        /// streamTerrainElementsSpriteSet (river)
        STREAM,
        
        /// Resource map object
        OBJNRSRC,
        
        /// Grass map object
        OBJNGRA2,
        
        /// waterMapObjectSpriteSet
        OBJNWATR,
        
        /// grassTerrainObjectSpriteSet
        OBJNGRAS,
        
        /// snowTerrainObjectSpriteSet
        OBJNSNOW,
        
        /// swampTerrainObjectSpriteSet
        OBJNSWMP,
        
        /// desertTerrainObjectSpriteSet
        OBJNDSRT,

        /// dirtTerrainObjectSpriteSet
        OBJNDIRT,

        /// wastelandTerrainObjectSpriteSet
        OBJNCRCK,

        /// lavaTerrainObjectSpriteSet 1/3
        OBJNLAVA,
        
        /// lavaTerrainObjectSpriteSet 2/3
        OBJNLAV2,
        
        /// lavaTerrainObjectSpriteSet 3/3
        OBJNLAV3
    }
}

public extension Icon.Raw {
    var icon: Icon {
        switch self {
        case .BTNSHNGL: return .mainMenuButtonsSpriteSet
        case .HEROES: return .mainMenuBackground
        case .PHOENIX: return .phoenix
        case .MONH0028: return .phoenixSpriteSet
        case .OBJNTWRD: return .randomCastle
        case .MONS32: return .creaturesSpriteSet
        case .SHNGANIM: return .mainMenuShiningAnimationsSpriteSet
        case .OBJNTWBA: return .castleBase
        case .BOAT32: return .boatSpriteSet
        case .OBJNARTI: return .smallMapArtifactsSpriteSet
        case .FLAG32: return .flagsSpriteSet
        case .MINIHERO: return .heroMinitiaturesForEditor
        case .MTNSNOW: return .mountainsSnowTerrainElementsSpriteSet
        case .MTNSWMP: return .mountainsSwampTerrainElementsSpriteSet
        case .MTNLAVA: return .mountainsLavaTerrainElementsSpriteSet
        case .MTNDSRT: return .mountainsDesertTerrainElementsSpriteSet
        case .MTNDIRT: return .mountainsDirtTerrainElementsSpriteSet
        case .MTNMULT: return .mountainsAllTerrainElementsSpriteSet
        case .EXTRAOVR: return .mineTypesSpriteSet
        case .ROAD: return .roadTerrainElementsSpriteSet
        case .MTNCRCK: return .mountainsWastelandTerrainElementsSpriteSet
        case .MTNGRAS: return .mountainsGrassTerrainElementsSpriteSet
        case .TREJNGL: return .treesJungleTerrainElementsSpriteSet
        case .TREEVIL: return .treesEvilTerrainElementsSpriteSet
        case .TRESNOW: return .treesSnowTerrainElementsSpriteSet
        case .TREFIR: return .treesFirTerrainElementsSpriteSet
        case .TREFALL: return .treesFallTerrainElementsSpriteSet
        case .OBJNTOWN: return .townMapObjectsSpriteSet
        case .OBJNTWSH: return .castleShadowsSpriteSet
        case .OBJNXTRA: return .mineGuardiansElementalsSpriteSet
        case .OBJNWAT2: return .waterObjectsSpriteSet
        case .OBJNMULT: return .genericMapObjectsSpriteSet
        case .OBJNMUL2: return .genericMapObjectsSpriteSet2
        case .STREAM: return .streamTerrainElementsSpriteSet
        case .OBJNRSRC: return .resourceOnMapObjectSpriteSet
        case .OBJNGRA2: return .grassMapObjectSpriteSet
        case .TREDECI: return .treesDeciduousTerrainElementsSpriteSet
        case .OBJNWATR: return .waterMapObjectSpriteSet
        case .OBJNGRAS: return .grassTerrainObjectSpriteSet
        case .OBJNSNOW: return .snowTerrainObjectSpriteSet
        case .OBJNSWMP: return .swampTerrainObjectSpriteSet
    
            
        case .OBJNDSRT: return .desertTerrainObjectSpriteSet

        case .OBJNDIRT: return .dirtTerrainObjectSpriteSet

        case .OBJNCRCK: return .wastelandTerrainObjectSpriteSet

        case .OBJNLAVA: return .lavaTerrainObjectSpriteSet
        case .OBJNLAV2: return .lavaTerrainObjectSpriteSet2
        case .OBJNLAV3: return .lavaTerrainObjectSpriteSet3
        
        }
    }
}




extension Icon {
    static func fromObjectTileset(_ objectTileset: Int) -> Icon? {
        let tilesetValue = objectTileset >> 2
           
        switch tilesetValue {
        
        case 6: return .boatSpriteSet
        case 11: return .smallMapArtifactsSpriteSet
        case 12: return .creaturesSpriteSet
        case 14: return .flagsSpriteSet
        case 21: return .heroMinitiaturesForEditor
        case 22: return .mountainsSnowTerrainElementsSpriteSet
        case 23: return .mountainsSwampTerrainElementsSpriteSet
        case 24: return .mountainsLavaTerrainElementsSpriteSet
        case 25: return .mountainsDesertTerrainElementsSpriteSet
        case 26: return .mountainsDirtTerrainElementsSpriteSet
        case 27: return .mountainsAllTerrainElementsSpriteSet
        case 29: return .mineTypesSpriteSet
        case 30: return .roadTerrainElementsSpriteSet
        case 31: return .mountainsWastelandTerrainElementsSpriteSet
        case 32: return .mountainsGrassTerrainElementsSpriteSet
        case 33: return .treesJungleTerrainElementsSpriteSet
        case 34: return .treesEvilTerrainElementsSpriteSet
        case 35: return .townMapObjectsSpriteSet
        case 36: return .castleBase
        case 37: return .castleShadowsSpriteSet
        case 38: return .randomCastle
        case 39: return .mineGuardiansElementalsSpriteSet
        case 40: return .waterObjectsSpriteSet
        case 41: return .genericMapObjectsSpriteSet2
        case 42: return .treesSnowTerrainElementsSpriteSet
        case 43: return .treesFirTerrainElementsSpriteSet
        case 44: return .treesFallTerrainElementsSpriteSet
        case 45: return .streamTerrainElementsSpriteSet
        case 46: return .resourceOnMapObjectSpriteSet
        case 48: return .grassMapObjectSpriteSet
        case 49: return .treesDeciduousTerrainElementsSpriteSet
        case 50: return .waterMapObjectSpriteSet
        case 51: return .grassTerrainObjectSpriteSet
        case 52: return .snowTerrainObjectSpriteSet
        case 53: return .swampTerrainObjectSpriteSet
        case 54: return .lavaTerrainObjectSpriteSet
        case 55: return .desertTerrainObjectSpriteSet
        case 56: return .dirtTerrainObjectSpriteSet
        case 57: return .wastelandTerrainObjectSpriteSet
        case 58: return .lavaTerrainObjectSpriteSet3
        case 59: return .genericMapObjectsSpriteSet
        case 60: return .lavaTerrainObjectSpriteSet2

        
        default: fatalError("not done yet: tilesetValue \(objectTileset), tilesetValue: \(tilesetValue)")
        }
    }
}


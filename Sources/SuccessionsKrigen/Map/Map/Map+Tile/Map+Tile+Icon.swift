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
    
    /// "OBJNTWBA"
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
    
    /// "ROAD"
    case roadTerrainElementsSpriteSet
    
    case treesJungleTerrainElementsSpriteSet
    case treesEvilTerrainElementsSpriteSet
    case treesSnowTerrainElementsSpriteSet
    case treesFirTerrainElementsSpriteSet
    case treesDeciduousTerrainElementsSpriteSet
    case treesFallTerrainElementsSpriteSet
    
    /// "OBJNTOWN"
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




public extension Icon {
    
    static let iconToObjectTilesetBitshiftedRightTwiceMap: [Icon: Int] = [
        .boatSpriteSet: 06,
        .smallMapArtifactsSpriteSet: 11,
        .creaturesSpriteSet: 12,
        .flagsSpriteSet: 14,
        .heroMinitiaturesForEditor: 21,
        .mountainsSnowTerrainElementsSpriteSet: 22,
        .mountainsSwampTerrainElementsSpriteSet: 23,
        .mountainsLavaTerrainElementsSpriteSet: 24,
        .mountainsDesertTerrainElementsSpriteSet: 25,
        .mountainsDirtTerrainElementsSpriteSet: 26,
        .mountainsAllTerrainElementsSpriteSet: 27,
        .mineTypesSpriteSet: 29,
        .roadTerrainElementsSpriteSet: 30,
        .mountainsWastelandTerrainElementsSpriteSet: 31,
        .mountainsGrassTerrainElementsSpriteSet: 32,
        .treesJungleTerrainElementsSpriteSet: 33,
        .treesEvilTerrainElementsSpriteSet: 34,
        .townMapObjectsSpriteSet: 35,
        .castleBase: 36,
        .castleShadowsSpriteSet: 37,
        .randomCastle: 38,
        .mineGuardiansElementalsSpriteSet: 39,
        .waterObjectsSpriteSet: 40,
        .genericMapObjectsSpriteSet2: 41,
        .treesSnowTerrainElementsSpriteSet: 42,
        .treesFirTerrainElementsSpriteSet: 43,
        .treesFallTerrainElementsSpriteSet: 44,
        .streamTerrainElementsSpriteSet: 45,
        .resourceOnMapObjectSpriteSet: 46,
        .grassMapObjectSpriteSet: 48,
        .treesDeciduousTerrainElementsSpriteSet: 49,
        .waterMapObjectSpriteSet: 50,
        .grassTerrainObjectSpriteSet: 51,
        .snowTerrainObjectSpriteSet: 52,
        .swampTerrainObjectSpriteSet: 53,
        .lavaTerrainObjectSpriteSet: 54,
        .desertTerrainObjectSpriteSet: 55,
        .dirtTerrainObjectSpriteSet: 56,
        .wastelandTerrainObjectSpriteSet: 57,
        .lavaTerrainObjectSpriteSet3: 58,
        .genericMapObjectsSpriteSet: 59,
        .lavaTerrainObjectSpriteSet2: 60,
    ]
    
    static func fromObjectTileset(_ objectTileset: Int) -> Icon? {
        let tilesetValue = objectTileset >> 2
        
        guard let icon = iconToObjectTilesetBitshiftedRightTwiceMap.first(where: { $0.value == tilesetValue })?.key else {
            fatalError("not done yet: tilesetValue \(objectTileset), tilesetValue: \(tilesetValue)")
        }
        
        return icon
    }
}


//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-07.
//

import Foundation

public extension Map.Castle {

enum Building: UInt32, Equatable {
    
    case thievesGuild = 0x00000001,
    tavern = 0x00000002,
    shipyard = 0x00000004,
    well = 0x00000008,
    statue = 0x00000010,
    turretLeft = 0x00000020,
    turretRight = 0x00000040,
    marketplace = 0x00000080,
    
    /// Farm, Garbage He, Crystal Gar, Waterfall, Orchard, Skull Pile
    well2 = 0x00000100,
    
    moat = 0x00000200,

    /// Fortification, Coliseum, Rainbow, Dungeon, Library, Storm
    spec = 0x00000400,

    castle = 0x00000800,
    captain = 0x00001000,
    shrine = 0x00002000,
    mageGuildLevel1 = 0x00004000,
    mageGuildLevel2 = 0x00008000,
    mageGuildLevel3 = 0x00010000,
    mageGuildLevel4 = 0x00020000,
    mageGuildLevel5 = 0x00040000,
//    MAGEGUILD = BUILD_MAGEGUILD1 | BUILD_MAGEGUILD2 | BUILD_MAGEGUILD3 | BUILD_MAGEGUILD4 | BUILD_MAGEGUILD5,
    
    /// Deprecated
    tent = 0x00080000,
    
    dwellingLevel1NonUpgraded = 0x00100000,
    dwellingLevel2NonUpgraded = 0x00200000,
    dwellingLevel3NonUpgraded = 0x00400000,
    dwellingLevel4NonUpgraded = 0x00800000,
    dwellingLevel5NonUpgraded = 0x01000000,
    dwellingLevel6NonUpgraded = 0x02000000,
//    dwellingLevelS = DWELLING_MONSTER1 | DWELLING_MONSTER2 | DWELLING_MONSTER3 | DWELLING_MONSTER4 | DWELLING_MONSTER5 | DWELLING_MONSTER6,
    dwellingLevel2Upgraded = 0x04000000,
    dwellingLevel3Upgraded = 0x08000000,
    dwellingLevel4Upgraded = 0x10000000,
    dwellingLevel5Upgraded = 0x20000000,
    dwellingLevel6Upgraded = 0x40000000,
    
    /// Black dragon
    dwellingLevel7Upgraded = 0x80000000
    
//    dwellingUPGRADES = DWELLING_UPGRADE2 | DWELLING_UPGRADE3 | DWELLING_UPGRADE4 | DWELLING_UPGRADE5 | DWELLING_UPGRADE6 | DWELLING_UPGRADE7
}
    
}

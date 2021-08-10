//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map.Tile.Info {
    
    /// Type of object. Most of them have two versions, one with suffix `N` which I dunno what it stands for...
    /// first bit indicates if you can interact with object
    enum MapObjectType: UInt8, Equatable {
        case nothing = 0x00,
             alchemyLabN = 0x01,
             skeletonN = 0x04,
             daemonCaveN = 0x05,
             faerieRingN = 0x07,
             gazeboN = 0x0a,
             graveyardN = 0x0c,
             archerHouseN = 0x0d,
             dwarfCottageN = 0x0f,
             
             peasantHutN = 0x10,
             dragonCityN = 0x14,
             lighthouseN = 0x15,
             waterwheelN = 0x16,
             minesN = 0x17,
             obeliskN = 0x19,
             oasisN = 0x1a,
             coastN = 0x1c,
             sawmillN = 0x1d,
             oracleN = 0x1e,
             
             shipwreckN = 0x20,
             desertTentN = 0x22,
             castleN = 0x23,
             stoneLithsN = 0x24,
             wagoncampN = 0x25,
             windmillN = 0x28,
             
             randomCownM = 0x30,
             randomCastleN = 0x31,
             nothingSpecial = 0x38,
             nothingSpecial2 = 0x39,
             watchTowerN = 0x3a,
             treeHouseN = 0x3b,
             treeCityN = 0x3c,
             ruinsN = 0x3d,
             fortN = 0x3e,
             tradingpostN = 0x3f,
             
             /// OBJN_ABANDONEDMINE vs OBJ_ABANDONEDMINE
             abandonedMineN = 0x40,
             
             /// OBJN_TREEKNOWLEDGE vs OBJ_TREEKNOWLEDGE
             treeKnowledgeN = 0x44,
             
             /// OBJN_DOCTORHUT vs OBJ_DOCTORHUT
             doctorHutN = 0x45,
             
             /// OBJN_TEMPLE vs OBJ_TEMPLE
             templeN = 0x46,
             
             /// OBJN_HILLFORT vs OBJ_HILLFORT
             hillfortN = 0x47,
             
             /// OBJN_HALFLINGHOLE vs OBJ_HALFLINGHOLE
             halflingHoleN = 0x48,
             
             /// OBJN_MERCENARYCAMP vs OBJ_MERCENARYCAMP
             mercenaryCampN = 0x49,
             
             /// "OBJN_PYRAMID" vs OBJ_PYRAMID (0xCC)
             pyramidN = 0x4c,
             
             /// "OBJN_CITYDEAD" vs OBJ_CITYDEAD (0xCD)
             cityDeadN = 0x4d,
             
             /// "OBJN_EXCAVATION" vs OBJ_EXCAVATION (0xCE)
             excavationN = 0x4e,
             
             /// "OBJN_SPHINX" vs OBJN_SPHINX (0xCF)
             sphinxN = 0x4f,
             
             tarpit = 0x51,
             artesianSpringN = 0x52,
             trollBridgeN = 0x53,
             wateringHoleN = 0x54,
             witchsHutN = 0x55,
             xanaduN = 0x56,
             caveN = 0x57,
             
             /// "OBJN_MAGELLANMAPS" vs OBJ_MAGELLANMAPS (0xd9)
             magellanMapsN = 0x59,
             
             /// "OBJN_DERELICTSHIP" vs OBJ_DERELICTSHIP (0xde)
             derelictShipN = 0x5b,
             
             /// "OBJN_MAGICWELL" vs OBJ_MAGICWELL (0xDE)
             magicWellN = 0x5e,
             
             /// OBJN_OBSERVATIONTOWER vs OBJ_OBSERVATIONTOWER (0xE0)
             observationTowerN = 0x60,
             
             /// "OBJN_FREEMANFOUNDRY" vs OBJ_FREEMANFOUNDRY (0xE1)
             freemanFoundryN = 0x61,
             trees = 0x63,
             mounts = 0x64,
             volcano = 0x65,
             flowers = 0x66,
             stones = 0x67,
             waterLake = 0x68,
             mandrake = 0x69,
             deadTree = 0x6a,
             stump = 0x6b,
             crater = 0x6c,
             cactus = 0x6d,
             mound = 0x6e,
             dune = 0x6f,
             
             lavaPool = 0x70,
             shrub = 0x71,
             
             /// "OBJN_ARENA" vs OBJ_ARENA (0xF2)
             arenaN = 0x72,
             
             /// "OBJN_BARROWMOUNDS" vs OBJ_BARROWMOUNDS (0xF4)
             barrowMoundsN = 0x73,
             
             /// "OBJN_MERMAID" vs OBJ_MERMAID (0xEC)
             mermaidM = 0x74,
             
             /// "OBJN_SIRENS"  vs OBJ_SIRENS (0xED)
             sirensN = 0x75,
             
             /// "OBJN_HUTMAGI"  vs OBJ_HUTMAGI (0xEE)
             hutMagiN = 0x76,
             
             /// "OBJN_EYEMAGI"  vs OBJ_EYEMAGI (0xEF)
             eyeMagiN = 0x77,
             
             /// "OBJN_TRAVELLERTENT"  vs OBJ_TRAVELLERTENT (0x78)
             travellerTentN = 0x78,
             jailN = 0x7b,
             
             
             /// "OBJN_FIREALTAR" vs OBJ_FIREALTAR (0xfc)
             firAaltarN = 0x7c,
             
             /// "OBJN_AIRALTAR" vs OBJ_AIRALTAR (0xfd)
             airAltarN = 0x7d,
             
             /// "OBJN_EARTHALTAR" vs OBJ_EARTHALTAR (0xfe)
             earthAltarN = 0x7e,
             
             /// "OBJN_WATERALTAR" vs OBJ_WATERALTAR (0xff)
             waterAltarN = 0x7f,
             
             waterChest = 0x80,
             alchemyLab = 0x81,
             sign = 0x82,
             buoy = 0x83,
             skeleton = 0x84,
             daemonCave = 0x85,
             treasureChest = 0x86,
             faerieRing = 0x87,
             campfire = 0x88,
             fountain = 0x89,
             gazebo = 0x8a,
             ancientLamp = 0x8b,
             graveyard = 0x8c,
             archerHouse = 0x8d,
             goblinHut = 0x8e,
             dwarfCottage = 0x8f,
             
             peasantHut = 0x90,
             event = 0x93,
             dragonCity = 0x94,
             lighthouse = 0x95,
             waterWheel = 0x96,
             mines = 0x97,
             monster = 0x98,
             obelisk = 0x99,
             oasis = 0x9a,
             resource = 0x9b,
             sawmill = 0x9d,
             oracle = 0x9e,
             shrine1 = 0x9f,
             
             shipwreck = 0xa0,
             desertTent = 0xa2,
             castle = 0xa3,
             stoneLiths = 0xa4,
             wagonCamp = 0xa5,
             whirlpool = 0xa7,
             windmill = 0xa8,
             artifact = 0xa9,
             boat = 0xab,
             randomUltimateArtifact = 0xac,
             randomartifact = 0xad,
             randomResource = 0xae,
             randomMonster = 0xaf,
             
             randomTown = 0xb0,
             randomCastle = 0xb1,
             randomMonster1 = 0xb3,
             randomMonster2 = 0xb4,
             randomMonster3 = 0xb5,
             randomMonster4 = 0xb6,
             heroes = 0xb7,
             watchTower = 0xba,
             treeHouse = 0xbb,
             treeCity = 0xbc,
             ruins = 0xbd,
             fort = 0xbe,
             tradingPost = 0xbf,
             
             abandonedMine = 0xc0,
             thatchedHut = 0xc1,
             standingStones = 0xc2,
             idol = 0xc3,
             treeKnowledge = 0xc4,
             doctorHut = 0xc5,
             temple = 0xc6,
             hillfort = 0xc7,
             halflingHole = 0xc8,
             mercenaryCamp = 0xc9,
             shrine2 = 0xca,
             shrine3 = 0xcb,
             pyramid = 0xcc,
             cityDead = 0xcd,
             excavation = 0xce,
             sphinx = 0xcf,
             
             wagon = 0xd0,
             artesianSpring = 0xd2,
             trollBridge = 0xd3,
             wateringHole = 0xd4,
             witchshut = 0xd5,
             xanadu = 0xd6,
             cave = 0xd7,
             leanTo = 0xd8,
             magellanMaps = 0xd9,
             flotsam = 0xda,
             derelictShip = 0xdb,
             shipwreckSurviror = 0xdc,
             bottle = 0xdd,
             magicWell = 0xde,
             magicGarden = 0xdf,
             
             observationTower = 0xe0,
             freemanFoundry = 0xe1,
             reefs = 0xe9,
             alchemyTowerN = 0xea,
             stablesN = 0xeb,
             mermaid = 0xec,
             sirens = 0xed,
             hutMagi = 0xee,
             eyeMagi = 0xef,
             
             alchemyTower = 0xf0,
             stables = 0xf1,
             arena = 0xf2,
             barrowMounds = 0xf3,
             randomArtifact1 = 0xf4,
             randomArtifact2 = 0xf5,
             randomArtifact3 = 0xf6,
             barrier = 0xf7,
             travellerTent = 0xf8,
             jail = 0xfb,
             fireAltar = 0xfc,
             airAltar = 0xfd,
             earthAltar = 0xfe,
             waterAltar = 0xff
    }
    
}

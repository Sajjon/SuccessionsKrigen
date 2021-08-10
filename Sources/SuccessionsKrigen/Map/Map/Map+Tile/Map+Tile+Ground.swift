//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map.Tile {
    
    enum Ground: UInt16, Equatable {
        case desert = 0x0001
        case snow = 0x0002
        case swamp = 0x0004
        case wasteland = 0x0008
        case sand = 0x0010
        case lava = 0x0020
        case dirt = 0x0040
        case grass = 0x0080
        case water = 0x0100
    }
}

public extension Map.Tile.Ground {
    static let beach: Self = .sand
}

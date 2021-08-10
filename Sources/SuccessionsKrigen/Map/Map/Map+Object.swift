//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    struct Object: Equatable {
        let objectType: Map.Tile.Info.MapObjectType
        let worldPosition: WorldPosition
    }
}

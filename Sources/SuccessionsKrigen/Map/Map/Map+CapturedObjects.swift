//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


public extension Map {
    struct CapturedObject: Equatable {
        let objectMapType: Map.Tile.Info.MapObjectType
        let color: Color
        let guardians: Troop?
    }
    
    struct CapturedObjects: Equatable {
        private let capturedObjects: [WorldPosition: CapturedObject]
        init(capturedObjects: [WorldPosition: CapturedObject] = [:]) {
            self.capturedObjects = capturedObjects
        }
    }
}

public extension Map.CapturedObjects {
    
    func capture(
        objectOfType: Map.Tile.Info.MapObjectType,
        at worldPosition: WorldPosition,
        by color: Map.Color
    ) -> Self {
        
        var mutableDictionary = self.capturedObjects
        
        mutableDictionary[worldPosition] = .init(objectMapType: objectOfType, color: color, guardians: nil)
        
        return .init(capturedObjects: mutableDictionary)
        
    }
}

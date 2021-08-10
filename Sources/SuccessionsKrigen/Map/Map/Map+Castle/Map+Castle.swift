//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation


public extension Map {
    struct Castle: Equatable {
        let race: Race
        let worldPosition: WorldPosition
        let color: Color
        
        // TODO replace Castle.Building enum with an OptionSet struct, and change type of this variable to said OptionSet struct.
        let buildingsBitMask: UInt32
    }
}

extension Map.Castle {
    
    mutating func setRandomSprite() {
        fatalError()
    }
}

public extension Map.Castle {
    struct Simple: Equatable {
        let race: Race
        let worldPosition: WorldPosition
    }
}

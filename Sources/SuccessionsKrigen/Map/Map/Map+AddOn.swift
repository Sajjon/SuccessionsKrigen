//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

// MARK: - AddOn
public extension Map {
    
    /// Not to be confused with `Map.Level.AddOn`
    struct AddOn: Equatable {
      
        /// level 1
        let level1: Level
        
        /// level 2
        let level2: Level
        
        /// Next add-on index. Zero value means it's the last addon chunk.
        let nextAddOnIndex: Int
        
        /// Bitfield containing metadata
        let quantityN: Int
    }
}


//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    
    struct Level: Equatable {
        
        /// Last bit indicates if object is animated. Second-last controls overlay (fheroes2: "objectName")
        let object: Int
        
        /// level N or 0xFF (fheroes2: "indexName")
        let index: Int
        
        /// ObjectUID, if level 1, then `Ground (bottom) level UID` if level 2, then `top level UID`.
        /// UID is used to find all pieces/addons which belong to the same object.
        /// In Editor first object will have UID as 0. Then second object placed on the map will have UID 0 + number of pieces / tiles per previous object and etc.
        let uid: Int
        
        let quantity: Int?
    }
}


public extension Map.Level {
    /// Not to be confused with `Map.AddOn`
    struct AddOn: Equatable {
        let level: Int
        let unique: Int
        let object: Int
        let index: Int
    }
}

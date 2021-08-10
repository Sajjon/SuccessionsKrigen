//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

extension Icon {
    static func fromObjectTileset(_ objectTileset: Int) -> Icon? {
        let tilesetValue = objectTileset >> 2
           
        switch tilesetValue {
        case 38: return .randomCastle
        case 36: return .castleBase
        default: fatalError("not done yet: tilesetValue \(objectTileset), tilesetValue: \(tilesetValue)")
        }
    }
}


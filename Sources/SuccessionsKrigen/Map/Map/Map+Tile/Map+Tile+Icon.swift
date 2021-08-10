//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation



extension Map.Tile {
    func getIconObject(tileset: Int) -> Icon? {
        let tilesetValue = tileset >> 2
           
        switch tilesetValue {
        case 38: return .randomCastle
        default: fatalError("not done yet: tilesetValue \(tileset), tilesetValue: \(tilesetValue)")
        }
    }
}

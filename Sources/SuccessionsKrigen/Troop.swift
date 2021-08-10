//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public struct Troop: Equatable {
    let creatureType: Creature
    public typealias Quantity = UInt32
    let quantity: Quantity
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation
public struct Resources: Equatable {
    public typealias Quantity = Resource.Quantity
    let wood: Quantity
    let mercury: Quantity
    let ore: Quantity
    let sulfur: Quantity
    let crystal: Quantity
    let gems: Quantity
    let gold: Quantity
}

public extension Resources {
    static let zero = Self(wood: 0, mercury: 0, ore: 0, sulfur: 0, crystal: 0, gems: 0, gold: 0)
}

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

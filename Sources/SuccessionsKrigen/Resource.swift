//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation
public struct Resource: Equatable {
    let resourceType: ResourceType
    public typealias Quantity = Int
    let quantity: Quantity
}
public extension Resource {
    enum ResourceType: Equatable {
        case wood, mercury, ore, sulfur, crystal, gems, gold
    }
}

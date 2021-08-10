//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation
public struct ExpansionPack: Equatable {
    let name: String
    let mapFileExtension: String
}
public extension ExpansionPack {
    static let princeOfLoyalty = Self(name: "Price of loyalty", mapFileExtension: "MX2")
}

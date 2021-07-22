//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation

public struct CreatureInfo {
    public let indexInAggFile: Int
    public let binFileName: String
}
public extension CreatureInfo {
    static let peasant = Self(
        indexInAggFile: 0,
        binFileName: "PEAS_FRM.BIN"
    )
}

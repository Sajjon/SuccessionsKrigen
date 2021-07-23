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
        indexInAggFile: 1,
        binFileName: "PEAS_FRM.BIN"
    )
    
    static let archer = Self(
        indexInAggFile: 2,
        binFileName: "ARCHRFRM.BIN"
    )
    
    private static let elementalRecordName = "FELEMFRM.BIN"
    static let earthElement = Self(
        indexInAggFile: 63,
        binFileName: elementalRecordName
    )
    
    static let airElement = Self(
        indexInAggFile: 64,
        binFileName: elementalRecordName
    )
    
    static let fireElement = Self(
        indexInAggFile: 65,
        binFileName: elementalRecordName
    )
    
    static let waterElement = Self(
        indexInAggFile: 66,
        binFileName: elementalRecordName
    )
}

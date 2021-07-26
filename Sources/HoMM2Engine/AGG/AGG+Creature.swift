//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public extension AGGFile {
    func dataFor(creature: Creature) -> Data {
        do {
            let data = try read(fileName: creature.nameOfRecordInAggFile)
            return data
        } catch {
            fatalError("Unexpected error while reading creature data in AGG file for creature: \(creature), underlying error: \(error)")
        }
        
    }
}

private extension Creature {
    var nameOfRecordInAggFile: String {
        switch self {
        case .peasant: return "PEAS_FRM.BIN"
        case .archer: return "ARCHRFRM.BIN"
        case .airElemental: fallthrough
        case .earthElemental: fallthrough
        case .fireElemental: fallthrough
        case .waterElemental: return "FELEMFRM.BIN"
        }
    }
}

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
    
    func Info(creature: Creature) -> Creature.Info {
        let parser = CreatureInfoParser()
        let data = dataFor(creature: creature)
        do {
            let info = try parser.parse(data: data, creatureType: creature)
            return info
        } catch {
            fatalError("Unexpected error while reading and parsing creature info for creature: \(creature), underlying error: \(error)")
        }
    }
    
    func animationReference(creature: Creature) -> AnimationReference {
        let creatureInfo = Info(creature: creature)
        let builder = AnimationReference.Builder()
        
        do {
          let animationReference = try builder.build(creatureInfo: creatureInfo)
            return animationReference
        } catch {
            fatalError("Unexpected error while reading and parsing animation reference for creature: \(creature), underlying error: \(error)")
        }
        
        
    }
}


public enum GUI {
    public enum BattleField {
        public enum Cell {
            public static let width = 44
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
        default: fatalError("Creature not supported yet")
        }
    }
}


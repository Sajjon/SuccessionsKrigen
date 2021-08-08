//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-27.
//

import Foundation

func speedOf(creature: Creature) -> Int {
    fatalError()
}

public struct CreatureInfoParser {}

private extension CreatureInfoParser {
    static let expectedAnimationDataByteCount = 821
    
    // fheroes2 code base comment: "When base unit and its upgrade use the same FRM file (e.g. Archer and Ranger) we modify animation speed value to make them go faster"
    static let moveSpeedUpgrade = 0.12
    static let shootSpeedUpgrade = 0.08
    static let rangerShootSpeed = 0.78
}

public extension CreatureInfoParser {
    enum Error: Swift.Error {
        case incorrectAnimationDataLength(expectedByteCountOf: Int, butGot: Int)
    }
    
    func parse(data: Data, creatureType creature: Creature) throws -> Creature.Info {
        guard data.count == Self.expectedAnimationDataByteCount else {
            throw Error.incorrectAnimationDataLength(expectedByteCountOf: Self.expectedAnimationDataByteCount, butGot: data.count)
        }
        let dataReader = DataReader(data: data)
        
        // unknown and unused
        let _ = try dataReader.read(byteCount: 1)
        
        let eyePositionX = try dataReader.readInt16()
        let eyePositionY = try dataReader.readInt16()
        let eyePosition = Point(x: .init(eyePositionX), y: .init(eyePositionY))
        
        // fheroes2 code base comment: "Frame X offsets for the future use"
        var offsetXForFrames = try (0..<7).map { _ in
            try (0..<16).map { _ in
                try dataReader.readInt8()
            }.map { Int($0) }
        }
        
        assert(dataReader.offset == 116)
        
        // fheroes2 code base comment: "here we need to reset our object"
        let idleAnimationCount: Int = min(try Int(dataReader.readUInt32()), 5)
        let probabilitiesForDifferentAnimationsOfIdleness = try (0..<idleAnimationCount).map { _ in
            try dataReader.readFloat()
        }
        assert(dataReader.offset == 137)
        let unusedIdleDelays = try (0..<idleAnimationCount).map { (_: Int) throws -> Int in
            try Int(dataReader.readUInt32())
        }
        assert(dataReader.offset == 157)
        let idleAnimationDelay = Int(try dataReader.readUInt32())
        
        var moveSpeed = Int(try dataReader.readUInt32())
        var shootSpeed = Int(try dataReader.readUInt32())
        let flightSpeed = Int(try dataReader.readUInt32())
        
        var projectileOffsets: [Point] = try (0..<3).map { _ in
            let x = try dataReader.readInt16()
            let y = try dataReader.readInt16()
            return Point(x: .init(x), y: .init(y))
        }
        // fheroes2 code base comment: "Elves and Grand Elves have incorrect start Y position for lower shooting attack"
        if creature == .elf || creature == .grandElf {
            let lowerShootingPositionIndex = 2
            let incorrectY = -1
            let correctY = -32
            if projectileOffsets[lowerShootingPositionIndex].y == incorrectY {
                projectileOffsets[lowerShootingPositionIndex] = .init(x: projectileOffsets[lowerShootingPositionIndex].x, y: correctY)
            }
        }
        assert(dataReader.offset == 185)
        
        // fheroes2 code base comment: "here we need to reset our object"
        let projectileCount = min(Int(try dataReader.readUInt8()), 12)
        let projectileAngles = try (0..<projectileCount).map { _ in
            try dataReader.readFloat()
        }
        assert(dataReader.offset == 234)
        // fheroes2 code base comment: "Positional offsets for sprites & drawing"
        let troopCountOffsetLeft = Int(try dataReader.readInt32())
        let troopCountOffsetRight = Int(try dataReader.readInt32())
        
        // fheroes2 code base comment: "Load animation sequences themselves"
        let byteOffsetAnimationDataStart = 277
        var animationFrames = try (AnimationType.MOVE_START.rawValue..<AnimationType.SHOOT3_END.rawValue).map { idx throws -> [Int] in
            let tmpDataReader = DataReader(data: data)
            try tmpDataReader.seek(to: 243)
            let count = try min(Int(tmpDataReader.readUInt8()), 16)
            return try (0..<count).map { frame throws -> Int in
                try tmpDataReader.seek(to: byteOffsetAnimationDataStart + idx * 16 + frame)
                return try tmpDataReader.readInt()
            }
        }
        
        
        // fheroes2 code base comment: "Wolves have incorrect frame for lower attack animation"
        if creature == .wolf {
            func correctWolfAnimationFrames(type incorrectAnimationType: AnimationType, index: Int) {
                let incorrectAnimationIndex = incorrectAnimationType.rawValue
                let wolfAnimationFrameValueIncorrect = 16
                let wolfAnimationFrameValueCorrect = 2
                if animationFrames[incorrectAnimationIndex].count == 3 && animationFrames[incorrectAnimationIndex][index] == wolfAnimationFrameValueIncorrect {
                    var framesWithIncorrectFrame = animationFrames[incorrectAnimationIndex]
                    framesWithIncorrectFrame[index] = wolfAnimationFrameValueCorrect
                    animationFrames[incorrectAnimationIndex] = framesWithIncorrectFrame
                }
            }
            correctWolfAnimationFrames(type: .ATTACK3, index: 0)
            correctWolfAnimationFrames(type: .ATTACK3_END, index: 2)
        }
        
        
        // fheroes2 code base comment: "Modify AnimInfo for upgraded monsters without own FRM file"
        var speedDifference = 0
        
        switch creature {
        case .ranger: fallthrough
        case .veteranPikeman: fallthrough
        case .masterSwordsman: fallthrough
        case .champion: fallthrough
        case .crusader: fallthrough
        case .orcChief: fallthrough
        case .ogreLord: fallthrough
        case .warTroll: fallthrough
        case .battleDwarf: fallthrough
        case .grandElf: fallthrough
        case .greaterDruid: fallthrough
        case .minotaurKing: fallthrough
        case .steelGolem: fallthrough
        case .archmage: fallthrough
        case .mutantZombie: fallthrough
        case .royalMummy: fallthrough
        case .vampireLord: fallthrough
        case .powerLich:
            speedDifference = speedOf(creature: creature) - speedOf(creature: Creature(rawValue: creature.rawValue - 1)!)
        case .earthElemental: fallthrough
        case .airElemental: fallthrough
        case .waterElemental:
            speedDifference = speedOf(creature: creature) - speedOf(creature: .fireElemental)
        default:
            break
        }
        
        if abs(speedDifference) > 0 {
            moveSpeed = Int(Double(moveSpeed) * (1 - Self.moveSpeedUpgrade * Double(speedDifference)))
            
            // fheroes2 code base comment: "Ranger is special since he gets double attack on upgrade"
            if creature == .ranger {
                shootSpeed = Int(Double(shootSpeed) * Self.rangerShootSpeed)
            } else {
                shootSpeed = Int(Double(shootSpeed) * (1 - Self.shootSpeedUpgrade * Double(speedDifference)))
            }
        }
        
        if offsetXForFrames[AnimationType.MOVE_STOP.rawValue][0] == 0 && offsetXForFrames[AnimationType.MOVE_TILE_END.rawValue][0] != 0 {
            var correctedOffsets = offsetXForFrames[AnimationType.MOVE_STOP.rawValue]
            correctedOffsets[0] = offsetXForFrames[AnimationType.MOVE_TILE_END.rawValue][0]
            offsetXForFrames[AnimationType.MOVE_STOP.rawValue] = correctedOffsets
        }
        
        for idx in AnimationType.MOVE_START.rawValue..<AnimationType.MOVE_ONE.rawValue {
            let animationFrameCount = animationFrames[idx].count
            let offsetsXForFrame = offsetXForFrames[idx]
            if offsetsXForFrame.count < animationFrameCount {
                var extended: [Int] = []
                extended.append(contentsOf: offsetsXForFrame)
                let sizeDiff = animationFrameCount - offsetsXForFrame.count
                extended.append(contentsOf: [Int].init(repeating: 0, count: sizeDiff))
                assert(extended.count == animationFrameCount)
                offsetXForFrames[idx] = extended
            }
        }
        
        if offsetXForFrames[AnimationType.MOVE_STOP.rawValue].count == 1 && offsetXForFrames[AnimationType.MOVE_STOP.rawValue][0] == 0 {
            if offsetXForFrames[AnimationType.MOVE_TILE_END.rawValue].count == 1 && offsetXForFrames[AnimationType.MOVE_TILE_END.rawValue][0] != 0 {
                var corrected = offsetXForFrames[AnimationType.MOVE_STOP.rawValue]
                corrected[0] = offsetXForFrames[AnimationType.MOVE_TILE_END.rawValue][0]
                offsetXForFrames[AnimationType.MOVE_STOP.rawValue] = corrected
            } else if offsetXForFrames[AnimationType.MOVE_TILE_START.rawValue].count == 1 && offsetXForFrames[AnimationType.MOVE_TILE_START.rawValue][0] != 0 {
                var corrected = offsetXForFrames[AnimationType.MOVE_STOP.rawValue]
                // No idea where "fheroes2" got `44` from... is this maybe `UI.BattleField.Cell.width` ?
                corrected[0] = 44 + offsetXForFrames[AnimationType.MOVE_TILE_START.rawValue][0]
                offsetXForFrames[AnimationType.MOVE_STOP.rawValue] = corrected
            } else {
                var corrected = offsetXForFrames[AnimationType.MOVE_STOP.rawValue]
                corrected[0] = offsetXForFrames[AnimationType.MOVE_MAIN.rawValue].last!
                offsetXForFrames[AnimationType.MOVE_STOP.rawValue] = corrected
            }
        }
        
        if creature == .ironGolem || creature == .steelGolem {
            if offsetXForFrames[AnimationType.MOVE_START.rawValue].count == 4 {
                // fheroes2 code base comment: "the original golem info"
                var corrected = offsetXForFrames[AnimationType.MOVE_START.rawValue]
                corrected[0] = 0
                corrected[1] = GUI.BattleField.Cell.width * 1 / 8
                corrected[2] = GUI.BattleField.Cell.width * 2 / 8
                corrected[3] = GUI.BattleField.Cell.width * 3 / 8
                
                offsetXForFrames[AnimationType.MOVE_MAIN.rawValue] = (0..<4).map { offsetXForFrames[AnimationType.MOVE_MAIN.rawValue][$0] + GUI.BattleField.Cell.width / 2 }
            }
        }
        
        if creature == .swordsman || creature == .masterSwordsman {
            if offsetXForFrames[AnimationType.MOVE_START.rawValue].count == 2 && offsetXForFrames[AnimationType.MOVE_STOP.rawValue].count == 1 {
                // fheroes2 code base comment: "the original swordsman info"
                var correctedMoveStart = offsetXForFrames[AnimationType.MOVE_START.rawValue]
                correctedMoveStart[0] = 0
                correctedMoveStart[1] = GUI.BattleField.Cell.width * 1 / 8
                
                offsetXForFrames[AnimationType.MOVE_MAIN.rawValue] = (0..<4).map { offsetXForFrames[AnimationType.MOVE_MAIN.rawValue][$0] + GUI.BattleField.Cell.width / 4 }
                
                var correctedMoveStop = offsetXForFrames[AnimationType.MOVE_STOP.rawValue]
                correctedMoveStop[0] = GUI.BattleField.Cell.width
                offsetXForFrames[AnimationType.MOVE_STOP.rawValue] = correctedMoveStop
            }
        }
        
        
        return Creature.Info(
            creature: creature,
            offsetXForFrames: offsetXForFrames,
            moveSpeed: moveSpeed,
            eyePosition: eyePosition,
            troopCountOffsetLeft: troopCountOffsetLeft,
            troopCountOffsetRight: troopCountOffsetRight,
            probabilitiesForDifferentAnimationsOfIdleness: probabilitiesForDifferentAnimationsOfIdleness,
            unusedIdleDelays: unusedIdleDelays,
            idleAnimationDelay: idleAnimationDelay,
            animationFrames: animationFrames,
            
            shooter: projectileCount > 0 ? .init(
                shootSpeed: shootSpeed,
                projectileOffsets: projectileOffsets,
                projectileAngles: projectileAngles
            ) : nil,
            
            flyer: flightSpeed > 0 ? .init(flightSpeed: flightSpeed) : nil
        )
    }
}

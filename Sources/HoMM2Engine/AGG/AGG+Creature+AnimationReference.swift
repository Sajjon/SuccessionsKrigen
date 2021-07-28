//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-27.
//

import Foundation


public enum AnimationType: Int {
    case  MOVE_START = 0, // Start of the moving sequence on 1st animation cycle: flyers will fly up
          MOVE_TILE_START, // Supposed to be played at the beginning of 2nd+ move.
          MOVE_MAIN, // Core animation. Most units only have this one.
          MOVE_TILE_END, // Cavalry & wolf. Played at the end of the cycle (2nd tile to 3rd), but not at the last one
          MOVE_STOP, // End of the moving sequence when arrived: landing for example
          MOVE_ONE, // Used when moving 1 tile. LICH and POWER_LICH doesn't have this, use MOVE_MAIN
          TEMPORARY, // This is an empty placeholder for combined animation built from previous parts
          STATIC, // Frame 1
          IDLE1,
          IDLE2, // Idle animations: picked at random with different probablities, rarely all 5 present
          IDLE3,
          IDLE4,
          IDLE5,
          DEATH,
          WINCE_UP,
          WINCE_END,
          ATTACK1, // Attacks, number represents the angle: 1 is TOP, 2 is CENTER, 3 is BOTTOM
          ATTACK1_END,
          DOUBLEHEX1,
          DOUBLEHEX1_END,
          ATTACK2,
          ATTACK2_END,
          DOUBLEHEX2,
          DOUBLEHEX2_END,
          ATTACK3,
          ATTACK3_END,
          DOUBLEHEX3,
          DOUBLEHEX3_END,
          SHOOT1,
          SHOOT1_END,
          SHOOT2,
          SHOOT2_END,
          SHOOT3,
          SHOOT3_END
    
}

public struct AnimationReference {
    
    public let creatureInfo: Creature.Info
    
    public let staticFrames: AnimationFrames
    public let winceFrames: AnimationFrames
    public let deathFrames: AnimationFrames
    public let idleFrames: AnimationFrames
    public let movingFrames: AnimationFrames
    public let moveOneTileFrames: AnimationFrames
    public let moveFirstTileFrames: AnimationFrames
    public let moveLastTileFrames: AnimationFrames

    public let melee: MonsterReturnAnimations

    // TODO what? are all creatures flyers..? :S
    public let flying: MonsterReturnAnimation
    
    public let ranged: MonsterReturnAnimations?

}


public extension AnimationReference {
    struct Builder {}
}


public typealias AnimationFrames = [Int]
public struct MonsterReturnAnimation {
    
    public let start: AnimationFrames
    public let end: AnimationFrames
}

public struct MonsterReturnAnimations {
    public let top: MonsterReturnAnimation
    public let front: MonsterReturnAnimation
    public let bottom: MonsterReturnAnimation
}

public extension AnimationReference.Builder {
    
    

    func build(creatureInfo: Creature.Info) throws -> AnimationReference {
        @discardableResult
        func appendFrames(to target: inout [Int], animationType: AnimationType) -> Bool {
            guard creatureInfo.hasAnimation(animationType: animationType) else {
                return false
            }
            target.append(contentsOf: creatureInfo.animationFrames[animationType.rawValue])
            return true
        }
        
        // STATIC is our default
        var staticFrames: AnimationFrames = []
        var winceFrames: AnimationFrames = []
        var deathFrames: AnimationFrames = []
        var idleFrames: AnimationFrames = []
        var movingFrames: AnimationFrames = []
        var moveOneTileFrames: AnimationFrames = []
        var moveFirstTileFrames: AnimationFrames = []
        var moveLastTileFrames: AnimationFrames = []
        
        
        if !appendFrames(to: &staticFrames, animationType: AnimationType.STATIC) {
            // fall back to this, to avoid crashes
            staticFrames.append(1)
        }
        
        // Taking damage
        appendFrames(to: &winceFrames, animationType: .WINCE_UP)
        appendFrames(to: &winceFrames, animationType: .WINCE_END) // TODO: play it back together for now

        appendFrames(to: &deathFrames, animationType: .DEATH)
        
        // Idle animations
        for idx in AnimationType.IDLE1.rawValue..<creatureInfo.idleAnimationCount + AnimationType.IDLE1.rawValue {
            var idleFramesPartial: [Int] = []
            if appendFrames(to: &idleFramesPartial, animationType: AnimationType(rawValue: idx)!) {
                idleFrames.append(contentsOf: idleFramesPartial)
            }
        }
        
        // Every unit has MOVE_MAIN anim, use it as a base
        appendFrames(to: &movingFrames, animationType: .MOVE_TILE_START)
        appendFrames(to: &movingFrames, animationType: .MOVE_MAIN)
        appendFrames(to: &movingFrames, animationType: .MOVE_TILE_END)

        if creatureInfo.hasAnimation(animationType: .MOVE_ONE) {
            appendFrames(to: &moveOneTileFrames, animationType: .MOVE_ONE)
        } else if creatureInfo.creature == .lich || creatureInfo.creature == .powerLich {
            moveOneTileFrames = movingFrames
        } else {
            fatalError("what to do...")
        }
        
        // First tile move: 1 + 3 + 4
        appendFrames(to: &moveFirstTileFrames, animationType: .MOVE_START)
        appendFrames(to: &moveFirstTileFrames, animationType: .MOVE_MAIN)
        appendFrames(to: &moveFirstTileFrames, animationType: .MOVE_TILE_END)
        
        // Last tile move: 2 + 3 + 5
        appendFrames(to: &moveLastTileFrames, animationType: .MOVE_TILE_START)
        appendFrames(to: &moveLastTileFrames, animationType: .MOVE_MAIN)
        appendFrames(to: &moveLastTileFrames, animationType: .MOVE_STOP)
        
        // Special for flyers
        var flyingFramesStart: AnimationFrames = []
        var flyingFramesEnd: AnimationFrames = []
        appendFrames(to: &flyingFramesStart, animationType: .MOVE_START)
        appendFrames(to: &flyingFramesEnd, animationType: .MOVE_STOP)
        let flying = MonsterReturnAnimation(start: flyingFramesStart, end: flyingFramesEnd)
        
        // Attack sequences
        var meleeFramesTopStart: AnimationFrames = []
        var meleeFramesTopEnd: AnimationFrames = []
        appendFrames(to: &meleeFramesTopStart, animationType: .ATTACK1)
        appendFrames(to: &meleeFramesTopEnd, animationType: .ATTACK1_END)
        let meleeTopFrames = MonsterReturnAnimation(start: meleeFramesTopStart, end: meleeFramesTopEnd)
        
        var meleeFramesFrontStart: AnimationFrames = []
        var meleeFramesFrontEnd: AnimationFrames = []
        appendFrames(to: &meleeFramesFrontStart, animationType: .ATTACK2)
        appendFrames(to: &meleeFramesFrontEnd, animationType: .ATTACK2_END)
        let meleeFrontFrames = MonsterReturnAnimation(start: meleeFramesFrontStart, end: meleeFramesFrontEnd)
        
        var meleeFramesBottomStart: AnimationFrames = []
        var meleeFramesBottomEnd: AnimationFrames = []
        appendFrames(to: &meleeFramesBottomStart, animationType: .ATTACK3)
        appendFrames(to: &meleeFramesBottomEnd, animationType: .ATTACK3_END)
        let meleeBottomFrames = MonsterReturnAnimation(start: meleeFramesBottomStart, end: meleeFramesBottomEnd)
        
        let melee = MonsterReturnAnimations(
            top: meleeTopFrames,
            front: meleeFrontFrames,
            bottom: meleeBottomFrames
        )
        
        var ranged: MonsterReturnAnimations?
        
        // Use either shooting or breath attack animation as ranged
        if creatureInfo.hasAnimation(animationType: .SHOOT2) {
            var rangedFramesTopStart: AnimationFrames = []
            var rangedFramesTopEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesTopStart, animationType: .SHOOT1)
            appendFrames(to: &rangedFramesTopEnd, animationType: .SHOOT1_END)
            let rangedTopFrames = MonsterReturnAnimation(start: rangedFramesTopStart, end: rangedFramesTopEnd)
            
            var rangedFramesFrontStart: AnimationFrames = []
            var rangedFramesFrontEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesFrontStart, animationType: .SHOOT2)
            appendFrames(to: &rangedFramesFrontEnd, animationType: .SHOOT2_END)
            let rangedFrontFrames = MonsterReturnAnimation(start: rangedFramesFrontStart, end: rangedFramesFrontEnd)
            
            var rangedFramesBottomStart: AnimationFrames = []
            var rangedFramesBottomEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesBottomStart, animationType: .SHOOT3)
            appendFrames(to: &rangedFramesBottomEnd, animationType: .SHOOT3_END)
            let rangedBottomFrames = MonsterReturnAnimation(start: rangedFramesBottomStart, end: rangedFramesBottomEnd)
            
            ranged = MonsterReturnAnimations(
                top: rangedTopFrames,
                front: rangedFrontFrames,
                bottom: rangedBottomFrames
            )
            
        } else if creatureInfo.hasAnimation(animationType: .DOUBLEHEX2) {
            // Only 6 units should have this (in the original game)
            
            var rangedFramesTopStart: AnimationFrames = []
            var rangedFramesTopEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesTopStart, animationType: .DOUBLEHEX1)
            appendFrames(to: &rangedFramesTopEnd, animationType: .DOUBLEHEX1_END)
            let rangedTopFrames = MonsterReturnAnimation(start: rangedFramesTopStart, end: rangedFramesTopEnd)
            
            var rangedFramesFrontStart: AnimationFrames = []
            var rangedFramesFrontEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesFrontStart, animationType: .DOUBLEHEX2)
            appendFrames(to: &rangedFramesFrontEnd, animationType: .DOUBLEHEX2_END)
            let rangedFrontFrames = MonsterReturnAnimation(start: rangedFramesFrontStart, end: rangedFramesFrontEnd)
            
            var rangedFramesBottomStart: AnimationFrames = []
            var rangedFramesBottomEnd: AnimationFrames = []
            appendFrames(to: &rangedFramesBottomStart, animationType: .DOUBLEHEX3)
            appendFrames(to: &rangedFramesBottomEnd, animationType: .DOUBLEHEX3_END)
            let rangedBottomFrames = MonsterReturnAnimation(start: rangedFramesBottomStart, end: rangedFramesBottomEnd)
            
            ranged = MonsterReturnAnimations(
                top: rangedTopFrames,
                front: rangedFrontFrames,
                bottom: rangedBottomFrames
            )
        }
        
        return AnimationReference(
            creatureInfo: creatureInfo,
            staticFrames: staticFrames,
            winceFrames: winceFrames,
            deathFrames: deathFrames,
            idleFrames: idleFrames,
            movingFrames: movingFrames,
            moveOneTileFrames: moveOneTileFrames,
            moveFirstTileFrames: moveFirstTileFrames,
            moveLastTileFrames: moveLastTileFrames,
            melee: melee,
            flying: flying,
            ranged: ranged
        )
    }
}



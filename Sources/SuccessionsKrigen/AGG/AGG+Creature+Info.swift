//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-27.
//

import Foundation


public extension Creature {
    
    struct Info: Equatable {
        let creature: Creature
        public let offsetXForFrames: [[Int]]
        public let moveSpeed: Int
        
        public let eyePosition: Point
        public let troopCountOffsetLeft: Int
        public let troopCountOffsetRight: Int
        
        /// "idlePriority"
        public let probabilitiesForDifferentAnimationsOfIdleness: [Float]
        
        /// Unused as in "this variable is not used" or something else?
        public let unusedIdleDelays: [Int]
        
        public let idleAnimationDelay: Int
        
        ///  "std::vector<std::vector<int> > animationFrames;"
        public let animationFrames: [[Int]]
        
        public let shooter: Shooter?
        public let flyer: Flyer?
    }
}

public extension Creature.Info {
    
    var idleAnimationCount: Int { probabilitiesForDifferentAnimationsOfIdleness.count }
    
    func hasAnimation(animationType: AnimationType) -> Bool {
        guard !animationFrames[animationType.rawValue].isEmpty else { return false }
        return animationFrames.count == AnimationType.SHOOT3_END.rawValue + 1
    }
}

public extension Creature.Info {
    
    struct Shooter: Equatable {
        public let shootSpeed: Int
        public let projectileOffsets: [Point]
        public let projectileAngles: [Float]
    }
    
    struct Flyer: Equatable {
        public let flightSpeed: Int
    }
    
}

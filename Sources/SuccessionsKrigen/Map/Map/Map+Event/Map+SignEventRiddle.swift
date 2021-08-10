//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    enum SignEventRiddle: Equatable {
        case sign(Sign)
        case event(Event)
        case riddle(Riddle)
    }
}

public extension Map.SignEventRiddle {
    
    struct Sign: Equatable {
        let worldPosition: WorldPosition
        let message: String
    }
    
    struct Event: Equatable {
        let worldPosition: WorldPosition
        let resources: Resources
        let artifact: Artifact?
        let allowComputer: Bool
        let shouldCancelEventAfterFirstvisit: Bool
        let visitableByColors: [Map.Color]
        let message: String?
    }
    
    struct Riddle: Equatable {
        let worldPosition: WorldPosition
        let question: String
        let validAnswers: [String]
        let bounty: Bounty
    }
}


public extension Map.SignEventRiddle.Riddle {
    struct Bounty: Equatable {
        let artifact: Artifact?
        let resources: Resources
    }
}

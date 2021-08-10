//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    struct EventDate: Equatable {
        
        let resources: Resources
        let allowComputer: Bool
        let dayOfFirstOccurent: Int
        let subsequentOccurrences: Int
        let visitableByColors: [Map.Color]
        let message: String?
    }
}

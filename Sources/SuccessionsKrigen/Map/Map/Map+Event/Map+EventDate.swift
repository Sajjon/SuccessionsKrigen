//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    struct EventDate: Equatable {
        
        let resources: Resources?
        let allowComputer: Bool
        let dayOfFirstOccurent: Date
        let subsequentOccurrences: Int
        let visitableByColors: [Map.Color]
        let message: String?
        
        public init(
            resources: Resources,
            allowComputer: Bool,
            dayOfFirstOccurent daysUntilFirstOccurenc: Int,
            subsequentOccurrences: Int,
            visitableByColors: [Map.Color],
            message: String?
        ) {
            self.resources = resources == .zero ? nil : resources
            self.allowComputer = allowComputer
            self.dayOfFirstOccurent = .in(daysUntilFirstOccurenc, .days)
            self.subsequentOccurrences = subsequentOccurrences
            self.visitableByColors = visitableByColors
            self.message = message
        }
    }
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public extension Icon {
    
    var iconFileName: String {
        raw.rawValue + ".ICN"
    }
    
    var raw: Raw {
        guard let raw = Raw.allCases.first(where: { $0.icon == self }) else {
            fatalError("failed to find raw for icon: \(self)")
        }
        return raw
    }
    
    var rawValue: Raw.RawValue { raw.rawValue }
}

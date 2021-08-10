//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension CaseIterable {
    static func random() -> Self {
        allCases.randomElement()!
    }
}

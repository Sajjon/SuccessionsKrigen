//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public enum Artifact: UInt8, Equatable, CaseIterable {
    case ultimateBook = 0
    case spaceNecromancy = 102
}

public extension Artifact {
    static func randomUltimate() -> Self {
        return .ultimateBook
    }
}

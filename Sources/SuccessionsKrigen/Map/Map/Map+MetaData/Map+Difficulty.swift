//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {

    enum Difficulty: Int, Equatable, CaseIterable {
        case easy = 0, normal, hard, expert, impossible
    }
}

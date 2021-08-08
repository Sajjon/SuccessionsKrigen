//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation

public extension FixedWidthInteger {
    static var byteCount: Int { bitWidth / 8 }
}

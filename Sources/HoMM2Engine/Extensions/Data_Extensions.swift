//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation

public extension Data {
    /// Mutates current data and returns the first `byteCount` bytes that was dropped
    mutating func droppedFirst(_ byteCount: Int) -> Data {
        let dropped = prefix(byteCount)
        self = dropFirst(byteCount)
        return Data(dropped)
    }
}

public extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

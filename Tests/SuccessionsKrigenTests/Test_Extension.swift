//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func XCTAssertAllEqual<Item>(_ items: Item...) where Item: Equatable {
        forAll(items) {
            XCTAssertEqual($0, $1)
        }
    }
    
    func XCTAssertAllInequal<Item>(_ items: Item...) where Item: Equatable {
        forAll(items) {
            XCTAssertNotEqual($0, $1)
        }
    }
    
    func XCTAssertEqualDictionaries<Key, Value>(
        _ lhs: [Key: Value], _ rhs: [Key: Value],
        line: UInt = #line,
        file: StaticString = #file
    ) where Key: Hashable, Value: Equatable {
        XCTAssertEqual(Set(lhs.keys), Set(rhs.keys), "Different keys found in dictionaries", file: file, line: line)
        lhs.keys.forEach { key in
            XCTAssertEqual(lhs[key], rhs[key], "Values for key: '\(key)' differs, `\(lhs[key]!)` != `\(rhs[key]!)`", file: file, line: line)
        }
    }
    
    private func forAll<Item>(_ items: [Item], compareElemenets: (Item, Item) -> Void) where Item: Equatable {
        var lastIndex: Array<Item>.Index?
        for index in items.indices {
            defer { lastIndex = index }
            guard let last = lastIndex else { continue }
            let fooElement: Item = items[last]
            let barElement: Item = items[index]
            compareElemenets(fooElement, barElement)
        }
    }
    
}

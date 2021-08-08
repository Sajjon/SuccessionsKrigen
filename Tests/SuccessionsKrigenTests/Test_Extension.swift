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

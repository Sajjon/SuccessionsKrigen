//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    struct Date: Equatable, ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = Int
        let day: IntegerLiteralType
        let week: IntegerLiteralType
        let month: IntegerLiteralType
        
        public init(day: IntegerLiteralType, week: IntegerLiteralType, month: IntegerLiteralType) {
            self.day = day
            self.week = week
            self.month = month
        }
    }
}

// MARK: ExpressibleByIntegerLiteral
public extension Map.Date {
    init(integerLiteral daysUntilDeadline: IntegerLiteralType) {
        self = Self.in(daysUntilDeadline, .days)
    }
}

// MARK: DaysUntilDeadline
public extension Map.Date {
    enum Deadline {
        case days
    }
    
    static let daysPerWeek = 7
    static let weeksPerMonth = 4
    static let daysPerMonth = Self.daysPerWeek * Self.weeksPerMonth
    
    static func `in`(_ daysUntilDeadline: Int, _: Deadline) -> Self {
        
        let month = daysUntilDeadline.quotientAndRemainder(dividingBy: daysPerMonth).quotient + 1
        let week = daysUntilDeadline.quotientAndRemainder(dividingBy: weeksPerMonth).quotient + 1
        let day = daysUntilDeadline.quotientAndRemainder(dividingBy: month * daysPerMonth + week * daysPerWeek).remainder + 1
        
        return .init(day: day, week: week, month: month)
    }
    
}


//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public extension AGGFile {
    func dataFor(icon: Icon) -> Data {
        do {
            let data = try read(fileName: icon.rawValue)
            return data
        } catch {
            fatalError("Unexpected error while reading icon data in AGG file for icon: \(icon), underlying error: \(error)")
        }
        
    }
}

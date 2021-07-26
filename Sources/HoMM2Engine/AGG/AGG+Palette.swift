//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

private let paletteFileName = "KB.PAL"

public extension AGGFile {
    func dataForPalette() -> Data {
        do {
            let data = try read(fileName: paletteFileName)
            return data
        } catch {
            fatalError("Unexpected error while reading palette data in AGG file, underlying error: \(error)")
        }
        
    }
}

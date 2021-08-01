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
            let rawPalette = try read(fileName: paletteFileName)
            
            // There is only one file of this type in the archive : the file "kb.pal". This file is the palette. It contains the colors to use to interpret the images in ICN files. It is a 3*256 bytes file. All group of 3 bytes represent a RGB color. You may notice that this palette is very dark (each byte is letter or equal than 0x3F). You must multiplicate all the bytes by 4 to obtain the real game's colors.
            // Ref: https://thaddeus002.github.io/fheroes2-WoT/infos/informations.html
            let correctedPalette = rawPalette.map { 4 * $0 }
            return Data(correctedPalette)
        } catch {
            fatalError("Unexpected error while reading palette data in AGG file, underlying error: \(error)")
        }
        
    }
}

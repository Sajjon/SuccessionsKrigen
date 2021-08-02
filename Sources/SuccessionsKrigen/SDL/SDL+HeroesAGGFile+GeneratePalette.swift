//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation

import HoMM2Engine

import CSDL2


func generatePalette(
    colorIds: [UInt8] = (0..<256).map( UInt8.init ),
    surfaceSupportsAlpha: Bool = true
) -> [UInt32] {
    var palette32Bit = [UInt32](repeating: 0xff, count: colorIds.count)

    let aggFile = try! AGGFile(path: AGGFile.defaultFilePathHeroes2)
    let palette = aggFile.dataForPalette()
    
    
    for i in 0..<palette32Bit.count {
        var offset = 0
        func getValue() -> UInt8 {
            defer { offset += 1 }
            let index = Int(colorIds[i]) * 3 + offset
            let paletteValue = palette[index]
            return paletteValue
        }
        let red = getValue()
        let green = getValue()
        let blue = getValue()
        let format = SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888.rawValue)
        let color = surfaceSupportsAlpha ? SDL_MapRGBA(format, red, green, blue, 255 /* Palette does not contain alpha info. Always use 255 */) : SDL_MapRGB(format, red, green, blue)
        SDL_FreeFormat(format)
        palette32Bit[i] = color
    }
    
    return palette32Bit
}

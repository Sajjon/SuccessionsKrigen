//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation
import HoMM2Engine

import CSDL2


func draw(sprite: Sprite, inRect canvasRect: Rect, pitch: Int32, renderer targetRenderer: OpaquePointer) {
    // See fheroes2 method `copyImageToSurface` in `screen.cpp` (32 bit version...)
    
    // If the image has size as the displayed window/renderer
    let isFullFrame = sprite.size.width == canvasRect.size.width
    
    let palette: [UInt32] = generatePalette()
    let whiteColor: UInt32 =  0xffffffff
    let pixelCount = Int(canvasRect.size.width * canvasRect.size.height)
    var pixels: [UInt32] = .init(repeating: whiteColor, count: pixelCount)
    
    let imageData = sprite.data()
    
    if isFullFrame {
        var offset = 0
        while offset < imageData.count {
            defer {
                offset += 1
            }
            let paletteId = Int(imageData[offset])
            let colorValue = palette[paletteId]
            pixels[offset] = colorValue
        }
    } else {
        var offset = 0
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                defer { offset += 1 }
                let paletteId = Int(imageData[offset])
                let colorValue = palette[paletteId]
                let index = y * ( Int(canvasRect.size.width) ) + x
                pixels[index] = colorValue
            }
        }
    }
    
    draw(
        pixels: &pixels,
        inRect: canvasRect,
        pitch: pitch,
        renderer: targetRenderer
    )
}


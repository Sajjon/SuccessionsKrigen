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
    
    // If the image has size as the displayed window/renderer
    
    let isFullFrame = sprite.size.width == canvasRect.size.width
    
    let palett32Bit: [UInt32] = generatePalette()
    let whiteColor: UInt32 =  0xffffffff
    let pixelCount = Int(canvasRect.size.width * canvasRect.size.height)
    var pixels: [UInt32] = .init(repeating: whiteColor, count: pixelCount)
    
    
    let transform: [UInt32] = palett32Bit
    
    let imageData = sprite.data()
    
    if isFullFrame {
        var offset = 0
        while offset < imageData.count {
            defer {
                offset += 1
            }
            let transformIndex = Int(imageData[offset])
            let transformedValue: UInt32 = transform[transformIndex]
            pixels[offset] = transformedValue
        }
    } else {
        var offset = 0
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                defer { offset += 1 }
                let blackWhitePixelInfo = Int(imageData[offset])
                let transformedValue: UInt32 = transform[blackWhitePixelInfo]
                let index = y * ( Int(canvasRect.size.width) ) + x
                pixels[index] = transformedValue
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


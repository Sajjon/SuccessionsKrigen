//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation
import HoMM2Engine
import CSDL2

func draw(pixels: inout [UInt32], inRect canvasRect: Rect, pitch: Int32, renderer targetRenderer: OpaquePointer) {
    let height = Int32(canvasRect.size.height)
    let width = Int32(canvasRect.size.width)
    precondition(pixels.count == height * width)
    pixels.withUnsafeMutableBytes {
        let pixelPointer: UnsafeMutableRawPointer = $0.baseAddress!
        guard let rgbSurface = SDL_CreateRGBSurfaceWithFormatFrom(pixelPointer, width, height, 32, pitch, SDL_PIXELFORMAT_RGBA8888.rawValue) else {
            sdlFatalError(reason: "SDL_CreateRGBSurfaceWithFormatFrom failed")
        }
        
        guard let textureWithPixels = SDL_CreateTextureFromSurface(targetRenderer, rgbSurface) else {
            sdlFatalError(reason: "SDL_CreateTextureFromSurface failed")
        }
        SDL_RenderCopy(targetRenderer, textureWithPixels, nil, nil)
        SDL_DestroyTexture(textureWithPixels)
        SDL_FreeSurface(rgbSurface)
    }
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation
import HoMM2Engine
import CSDL2

struct ColorRGB {
    typealias Value = UInt8
    let red: Value
    let blue: Value
    let green: Value
    let alpha: Value
}

func mutateTexturePixels(texture: OpaquePointer, pixelColor: ColorRGB, position: Point) {
    // Get the size of the texture.
    var format: UInt32 = 0
    var pitch: Int32 = 0
    var width: Int32 = 0
    var height: Int32 = 0
    var access: Int32 = 0
    SDL_QueryTexture(texture, &format, &access, &width, &height)
    guard access == SDL_TEXTUREACCESS_STREAMING.rawValue else {
        fatalError("Must be SDL_TEXTUREACCESS_STREAMING")
    }
    
    // Now let's make our "pixels" pointer point to the texture data.
    var pixelFormat = SDL_PixelFormat()
    pixelFormat.format = format
    //    print("pixelFormat.BytesPerPixel: \(pixelFormat.BytesPerPixel)")
    // Now you want to format the color to a correct format that SDL can use.
    // Basically we convert our RGB color to a hex-like BGR color.
    var color = SDL_MapRGB(&pixelFormat, pixelColor.red, pixelColor.green, pixelColor.blue)
    // Before setting the color, we need to know where we have to place it.
    let pixelOffset = position.y * (Int(pitch)) + (position.x + MemoryLayout<UInt32>.size)
    let pixelCount = Int(width * height)
    
    var pixels = [UInt32](repeating: 0, count: pixelCount)
    let rawPointer: UnsafeMutableRawPointer = pixels.withUnsafeMutableBytes { $0.baseAddress! }
    let opaquePointer = OpaquePointer(rawPointer)
    
    let pixelPointer = UnsafeMutablePointer<UnsafeMutableRawPointer?>(opaquePointer)
    
    guard SDL_LockTexture(texture, nil /* rect */, pixelPointer, &pitch) == 0 else {
        fatalError(sdlError(prefix: "SDL_LockTexture failed"))
    }
    defer {
        // Also don't forget to unlock your texture once you're done.
        SDL_UnlockTexture(texture)
    }
    
    // Now we can set the pixel(s) we want.
    let pixelPointerOffsetted = pixelPointer + pixelOffset
    //    let colorPointer = UnsafePointer(&color)
    pixelPointerOffsetted.withMemoryRebound(to: UInt32.self, capacity: 1) {
        $0.assign(from: &color, count: 1)
    }
}

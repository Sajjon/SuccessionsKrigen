//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation
import HoMM2Engine
import CSDL2
import Metal
import class QuartzCore.CAMetalLayer


extension UInt8 {
    static func random() -> Self {
        random(in: 0..<255)
    }
}


private func drawMainMenuScreen(aggFile: AGGFile) {
//    let paletteData = aggFile.dataForPalette()
//    let palette = Palette(rawData: paletteData)
//    let backgroundImageData = aggFile.dataFor(icon: .mainMenuBackground)
    
    SDL_Init(
        SDL_INIT_TIMER | //  timer subsystem
            SDL_INIT_AUDIO | // audio subsystem
            SDL_INIT_VIDEO |  // video subsystem; automatically initializes the events subsystem
            SDL_INIT_JOYSTICK | // joystick subsystem; automatically initializes the events subsystem
            SDL_INIT_EVENTS // events subsystem
    )
    
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "metal")
    SDL_InitSubSystem(SDL_INIT_VIDEO)
    
    //    let window: SDL_Window = SDL_CreateWindow("HoMM2 Swift SDL", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 1600, 900, 0);
    
    let width: Int32 = 640
    let height: Int32 = 480
    let window: OpaquePointer! = SDL_CreateWindow(
        "HoMM2", // title
        0, // x
        0, // y
        width,
        height,
        SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_ALLOW_HIGHDPI.rawValue // flags
    )
    
    let windowSurface = SDL_GetWindowSurface(window)
    
    
    let canvas: UnsafeMutablePointer<SDL_Surface>! = SDL_CreateRGBSurfaceWithFormat(0/*Uint32(SDL_SWSURFACE)*/ /* flags */, width, height, 32 /* depth */, SDL_PIXELFORMAT_RGBA8888.rawValue)
    

    SDL_UnlockSurface(canvas)

    let maxIdx = 3
    func dbgPrintPixels() {
        let values = [UInt32](
            UnsafeBufferPointer(
                start: canvas.pointee.pixels.assumingMemoryBound(to: UInt32.self),
                count: Int(width * height)
            )
        )
        for i in 0..<maxIdx {
            let value = values[i]
            print("canvas.pointee.pixels[i = \(i)]: \(value)")
        }
    }
    
    dbgPrintPixels()
    
    var counter = 0
    
    for y in 0..<height {
        for x in 0..<width {
            defer { counter += 1 }
            // TEAL
            let red: UInt8 = 168 // .random()
            let green: UInt8 = 196 //.random()
            let blue: UInt8 = 188 // .random()
            let alpha: UInt8 = 128 // .random()

            let targetPixelOffset = Int(y * canvas.pointee.pitch + x * Int32(canvas.pointee.format.pointee.BytesPerPixel))
           
            let pixelValue: UInt32 = SDL_MapRGBA(canvas.pointee.format, red, green, blue, alpha)
            if counter < maxIdx {
                print("targetPixelOffset: \(targetPixelOffset) = \(pixelValue)")
            }
            
            canvas.pointee.pixels.storeBytes(of: pixelValue, toByteOffset: targetPixelOffset, as: UInt32.self)
            
        }
       
    }
    
    dbgPrintPixels()
 
    
    SDL_LockSurface(canvas)
    
    
    var quit = false
    var event: SDL_Event = SDL_Event()
    while !quit {
        // === CHECK IF QUIT start
        while SDL_PollEvent(&event) != 0 {
            switch SDL_EventType(event.type) {
            case SDL_KEYUP:
                if event.key.keysym.sym == SDLK_ESCAPE.rawValue {
                    quit = true
                }
            case SDL_QUIT:
                quit = true
            default:
                break
            }
        }
        // === CHECK IF QUIT end
        var sourceRect = SDL_Rect(x: 0, y: 0, w: width, h: height)
        var destinationRect = SDL_Rect(x: 0, y: 0, w: width, h: height)
//        SDL_UpperBlitScaled(canvas, nil, windowSurface,
//        SDL_UpperBlit(canvas, &sourceRect, windowSurface, (&)
        
//        SDL_LowerBlit(canvas, nil, windowSurface, &rect)
//        SDL_UpdateWindowSurface(window)

        // $$$ METAL start
//        let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC.rawValue)
//
//        guard let layerPointer = SDL_RenderGetMetalLayer(renderer) else {
//            fatalError("could not get metal layer from renderer")
//        }
//
//        let layer: CAMetalLayer = unsafeBitCast(layerPointer, to: CAMetalLayer.self)

        // $$$ METAL end
        
        
        SDL_Delay(100)
        print(".", separator: "", terminator: "")
    }
    
    
    SDL_Quit()
}


func drawMainMenu() throws {
    let heroes2AggFile = AGGFile.heroes2
    drawMainMenuScreen(aggFile: heroes2AggFile)
}

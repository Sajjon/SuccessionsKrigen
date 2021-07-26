import Foundation


//print("HEJ ALEX, trying to draw main menu...")
//try! drawMainMenu()


import Foundation
import CSDL2
import SwiftSDL2
//
//func runSDL2Example() throws {
//
//    let width: Int32 = 640
//    let height: Int32 = 480
//    try SDL.Run { engine in
//        // Start engine ------------------------------------------------------------
//        try engine.start(subsystems: .video)
//
//        // Create renderer ---------------------------------------------------------
//        let (window, renderer) = try engine.addWindow(width: width, height: height)
//
//        // Handle input ------------------------------------------------------------
//        engine.handleInput = { [weak engine] in
//            var event = SDL_Event()
//            while(SDL_PollEvent(&event) != 0) {
//                if event.type == SDL_QUIT.rawValue {
//                    engine?.removeWindow(window)
//                    engine?.stop()
//                }
//            }
//        }
//
//        // Render ------------------------------------------------------------------
//        engine.render = {
//            renderer.result(of: SDL_SetRenderDrawColor, 255, 0, 0, 255)
//            renderer.result(of: SDL_RenderClear)
//
//            let depth: Int32 = 32
//            let rgbFormat: UInt32 = SDL_PIXELFORMAT_RGBA8888.rawValue
//            var flags: UInt32 = 0
////            renderer.result(of: SDL_CreateRGBSurfaceWithFormat, flags, width, height, depth, rgbFormat)
////            renderer.result(of: )
////            renderer.pass(to: SDL_CreateRGBSurfaceWithFormat, flags, width, height, depth, rgbFormat)
//            renderer.
//            /* Draw your stuff */
//
//            renderer.pass(to: SDL_RenderPresent)
//        }
//    }
//
//}
//
//try! runSDL2Example()

import HoMM2Engine
import CSDL2_Image


func testSDL() {
    let heroes2AggFile = AGGFile.heroes2
    //            let backgroundImageDataFull = heroes2AggFile.dataFor(icon: .mainMenuBackground)
    //        let backgroundImageData = Data(backgroundImageDataFull.suffix(from: 6))
    let hommSpellBMPFull = try! heroes2AggFile.read(fileName: "SPELBW04.BMP")
    let hommSpellBMP = Data(hommSpellBMPFull.suffix(from: 6))
    
    
    
    /* Starting SDL */
    func panic(reason: String, _ line: UInt = #line) -> Never {
        let maxLen: Int32 = 1000
        var errMessage = Array<CChar>.init(repeating: 0, count: Int(maxLen))
        SDL_GetErrorMsg(&errMessage, maxLen)
        let errorMessage = String(bytes: errMessage.prefix(while: { $0 > 0 }).map(UInt8.init), encoding: String.Encoding.ascii)!
        fatalError("\(reason), error message: \(errorMessage) (code: \(SDL_GetError()!.pointee))", line: line)
    }
    
    guard SDL_Init(SDL_INIT_VIDEO) == 0 else  {
        panic(reason: "SDL_INIT_VIDEO failed")
    }
    
    /* Create a Window */
    guard let window = SDL_CreateWindow("Hello World", 0, 0, 640, 480, SDL_WINDOW_SHOWN.rawValue) else {
        panic(reason: "Create Window failed")
    }
    
    /* Create a renderer */
    guard let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue) else {
        panic(reason: "Create Renderer failed")
    }
    
//    guard let pngSurface: UnsafeMutablePointer<SDL_Surface> = IMG_Load(pngImagePath) else {
//        panic(reason: "`IMG_Load` failed")
//    }
//    print("Successfully loaded pngSurface 🚀, height: \(pngSurface.pointee.h), width: \(pngSurface.pointee.w)")
    
    guard let pngData = FileManager.default.contents(atPath: "/Users/sajjon/Developer/Fun/Games/HoMM/SuccessionsKrigen/Sources/SuccessionsKrigen/homm2_battle.png") else {
        panic(reason: "Failed to load png image as data using Swift FileManager")
    }
    let rwPng: UnsafeMutablePointer<SDL_RWops> = pngData.withUnsafeBytes {
        guard let rwFromMem = SDL_RWFromConstMem($0.baseAddress!, Int32(pngData.count)) else {
            panic(reason: "PNG SDL_RWFromConstMem failed")
        }
        return rwFromMem
    }
    print("✅ rwPng")
    guard
        let pngImageSurfaceFromRW = IMG_Load_RW(rwPng, 1 /* `1` indicates that the stream will be closed after read */)
        else {
        panic(reason: "SDL_LoadFile_RW failed")
    }
    print("🙌 Successfully SDL_LoadFile_RW and size")
    
//    /* Load bitmap image */
//    let rw: UnsafeMutablePointer<SDL_RWops> = hommSpellBMP.withUnsafeBytes {
//        guard let rwFromMem = SDL_RWFromConstMem($0.baseAddress!, Int32(hommSpellBMP.count)) else {
//            panic(reason: "SDL_RWFromConstMem failed")
//        }
//        return rwFromMem
//    }
//    guard let imageSurface = SDL_LoadBMP_RW(rw, 1 /* `1` indicates that the stream will be closed after read */) else {
//        panic(reason: "SDL_LoadBMP_RW failed")
//    }
    
    
    /* Upload surface to renderer, and then, free the surface */
    guard let texture = SDL_CreateTextureFromSurface(renderer, pngImageSurfaceFromRW) else {
        panic(reason: "SDL_CreateTextureFromSurface failed")
    }
    SDL_FreeSurface(pngImageSurfaceFromRW)
    
    /* Draw the renderer on window */
    SDL_RenderClear(renderer) // Fill renderer with color
    SDL_RenderCopy(renderer, texture, nil, nil) // Copy the texture into renderer
    SDL_RenderPresent(renderer) // Show renderer on window
    
    /* Wait some seconds */
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    while !quit {
        while SDL_PollEvent(&e) != 0 {
            if e.type == SDL_QUIT.rawValue {
                quit = true
            }
            
            if e.type == SDL_KEYDOWN.rawValue {
                quit = true
            }
            
            if e.type == SDL_MOUSEBUTTONDOWN.rawValue {
                quit = true
            }
        }
    }
    
    /* Free all objects*/
    SDL_DestroyTexture(texture)
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    
    /* Quit program */
    SDL_Quit()
    
}

testSDL()

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation
import SuccessionsKrigen
import CSDL2

func animatePhoenixWithSDL() {
    
    /* Starting SDL */
    guard SDL_Init(SDL_INIT_VIDEO) == 0 else  {
        sdlFatalError(reason: "SDL_INIT_VIDEO failed")
    }
    
    /* Create a Window */
    let width: Int32 = 640
    let height: Int32 = 480
    guard let window = SDL_CreateWindow("Hello World", 0, 0, width, height, SDL_WINDOW_SHOWN.rawValue) else {
        sdlFatalError(reason: "Create Window failed")
    }
    
    /* Create a renderer */
    let flags = SDL_RENDERER_SOFTWARE.rawValue // SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue
    guard let renderer = SDL_CreateRenderer(window, -1, flags) else {
        sdlFatalError(reason: "Create Renderer failed")
    }
    
    var rendererInfo = SDL_RendererInfo()
    guard SDL_GetRendererInfo(renderer, &rendererInfo) == 0 else {
        sdlFatalError(reason: "GetRendererInfo failed")
    }
    
    guard let windowSurfaceBase = SDL_GetWindowSurface(window) else {
        sdlFatalError(reason: "SDL_GetWindowSurface failed")
    }
    let pitch = windowSurfaceBase.pointee.pitch
    SDL_FreeSurface(windowSurfaceBase)
    
    var nextSpriteIndex = 0
    func animatePhoenix(index: Int? = nil) {
        let aggFile = try! AGGFile(path: AGGFile.defaultFilePathHeroes2)
        let sprites = aggFile.spritesForCreature(.PHOENIX)
        let index = min(nextSpriteIndex, sprites.count - 1)
        let sprite = sprites[index]
        draw(sprite: sprite, inRect: .init(width: width, height: height), pitch: pitch, renderer: renderer)
        nextSpriteIndex = index == sprites.count - 1 ? 0 : index + 1
    }
    
    func doAnimatePhoenix() {
        SDL_RenderClear(renderer)
        animatePhoenix()
        SDL_RenderPresent(renderer)
    }
    
    
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    SDL_RenderClear(renderer)
    SDL_RenderPresent(renderer)
    
    
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    
    doAnimatePhoenix()
    
    while !quit {
        doAnimatePhoenix()
        SDL_Delay(20)
        while SDL_PollEvent(&e) != 0 {
            if e.type == SDL_QUIT.rawValue {
                quit = true
            }
            
            if e.type == SDL_KEYDOWN.rawValue {
                SDL_RenderClear(renderer)
                defer { SDL_RenderPresent(renderer) } // Show renderer on window
                if e.key.keysym.sym == SDLK_q.rawValue {
                    print("Did press Quit ('Q' key)")
                    quit = true
                }
            }
            
            
        }
    }
    
    /* Free all objects*/
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    
    /* Quit program */
    SDL_Quit()
    
}


import Foundation
import CSDL2
import SwiftSDL2

try SDL.Run { engine in
    // Start engine ------------------------------------------------------------
    try engine.start(subsystems: .video)
    
    // Create renderer ---------------------------------------------------------
    let (window, renderer) = try engine.addWindow(width: 640, height: 480)
    
    // Handle input ------------------------------------------------------------
    engine.handleInput = { [weak engine] in
        var event = SDL_Event()
        while(SDL_PollEvent(&event) != 0) {
            if event.type == SDL_QUIT.rawValue {
                engine?.removeWindow(window)
                engine?.stop()
            }
        }
    }
    
    // Render ------------------------------------------------------------------
    engine.render = {
        renderer.result(of: SDL_SetRenderDrawColor, 255, 0, 0, 255)
        renderer.result(of: SDL_RenderClear)
        
        /* Draw your stuff */
        
        renderer.pass(to: SDL_RenderPresent)
    }
}

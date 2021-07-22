//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-18.
//

import Foundation


public struct Rect {
    let x: Float
    let y: Float
}

public struct Image {
    public let size: Rect
    public let layerOneData: Data
    public let layerTwoData: Data?
}

public typealias Display = Image
public typealias Sprite = Image
enum Icon {}

func spriteForIcon(_ icon: Icon, index: Int) -> Sprite? {
    return nil
}


func drawSprite(display: inout Display, icon: Icon, index: Int) {
    guard let sprite = spriteForIcon(icon, index: index) else {
        fatalError("sprite not found")
    }
    let inlayed = inlay(image: sprite, in: display)
    display = inlayed
}

/*
 void drawSprite( Display & display, const int icnId, const uint32_t index )
 {
     const Sprite & sprite = AGG::GetICN( icnId, index );
     Blit( sprite, 0, 0, display, sprite.x(), sprite.y(), sprite.width(), sprite.height() );
 }
 */

/*
 
 void drawMainMenuScreen()
 {
     Display & display = Display::instance();

     Copy( AGG::GetICN( ICN::HEROES, 0 ), display );

     drawSprite( display, ICN::BTNSHNGL, 1 );
     drawSprite( display, ICN::BTNSHNGL, 5 );
     drawSprite( display, ICN::BTNSHNGL, 9 );
     drawSprite( display, ICN::BTNSHNGL, 13 );
     drawSprite( display, ICN::BTNSHNGL, 17 );
 }
 */

/*
 // draw one image onto another
 void Blit( const Image & in, Image & out, bool flip = false );
 void Blit( const Image & in, Image & out, int32_t outX, int32_t outY, bool flip = false );
 void Blit( const Image & in, int32_t inX, int32_t inY, Image & out, int32_t outX, int32_t outY, int32_t width, int32_t height, bool flip = false );

 // inPos must contain non-negative values
 void Blit( const Image & in, const Point & inPos, Image & out, const Point & outPos, const Size & size, bool flip = false );

 */



//      Blit( sprite, 0, 0, display, sprite.x(), sprite.y(), sprite.width(), sprite.height() );
// draw(image: sprite, in: display, at:
func inlay(
    image imageToInlay: Image,
    offset offsetOfImageToInlay: Rect? = nil,
    
    in canvas: Image,
    at canvasOffset: Rect? = nil,
    
    flip: Bool = false
) -> Image {
    return imageToInlay
}

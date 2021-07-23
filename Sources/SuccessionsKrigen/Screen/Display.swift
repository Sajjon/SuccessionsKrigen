//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public final class Display: Image {

    private var renderSurface: Data? = nil
    
    public init(size: Size = Display.defaultSize) {
        super.init(size: size, isSingleLayerOnly: true)
    }
}

public extension Display {
    static let defaultSize = Size(width: 640, height: 480)
    static let instance = Display()
}

/*
 class Display : public Image
     {
         void render(); // render full image on screen
         void render( const Size & roi ); // render a part of image on screen. Prefer this method over full image if you don't draw full screen.

         void resize( int32_t width_, int32_t height_ ) override;
         bool isDefaultSize() const;

         // this function must return true if new palette has been generated
         using PreRenderProcessing = bool ( * )( std::vector<uint8_t> & palette );
         using PostRenderProcessing = void ( * )();
         void subscribe( PreRenderProcessing preprocessing, PostRenderProcessing postprocessing );

         // For 8-bit mode we return a pointer to direct surface which we draw on screen
         uint8_t * image() override;
         const uint8_t * image() const override;

         void release(); // to release all allocated resources. Should be used at the end of the application

         // Change whole color representation on the screen. Make sure that palette exists all the time!!!
         // nullptr input parameters means to set to default value
         void changePalette( const uint8_t * palette = nullptr ) const;

         friend BaseRenderEngine & engine();
         friend Cursor & cursor();

         void setEngine( std::unique_ptr<BaseRenderEngine> & engine );
         void setCursor( std::unique_ptr<Cursor> & cursor );

     private:
         std::unique_ptr<BaseRenderEngine> _engine;
         std::unique_ptr<Cursor> _cursor;
         PreRenderProcessing _preprocessing;
         PostRenderProcessing _postprocessing;

         uint8_t * _renderSurface;

         // Previous area drawn on the screen.
         Size _prevRoi;

         void linkRenderSurface( uint8_t * surface ); // only for cases of direct drawing on rendered 8-bit image

         Display();

         void _renderFrame( const Size & roi ) const; // prepare and render a frame
     };

 */

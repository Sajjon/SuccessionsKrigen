//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

private func drawMainMenuScreen() {
    let display = Display.instance
    

    /*
     Copy( AGG::GetICN( ICN::HEROES, 0 ), display );

     drawSprite( display, ICN::BTNSHNGL, 1 );
     drawSprite( display, ICN::BTNSHNGL, 5 );
     drawSprite( display, ICN::BTNSHNGL, 9 );
     drawSprite( display, ICN::BTNSHNGL, 13 );
     drawSprite( display, ICN::BTNSHNGL, 17 );
     */
}

func drawMainMenu() {
    drawMainMenuScreen()
}

/*
 
 fheroes2::GameMode Game::MainMenu( bool isFirstGameRun )
 {
     std::cout << "\n\nGame::MainMenu => PlayMusic id: " << MUS::MAINMENU << "\n\n";
     Mixer::Pause();
     AGG::PlayMusic( MUS::MAINMENU, true, true );

     Settings & conf = Settings::Get();

     conf.SetGameType( TYPE_MENU );

     // setup cursor
     const CursorRestorer cursorRestorer( true, Cursor::POINTER );

     fheroes2::Display & display = fheroes2::Display::instance();

     // image background
     fheroes2::drawMainMenuScreen();
     if ( isFirstGameRun ) {
         Dialog::Message( _( "Greetings!" ), _( "Welcome to Free Heroes of Might and Magic II! Before starting the game please choose game resolution." ), Font::BIG,
                          Dialog::OK );

         bool isResolutionChanged = Dialog::SelectResolution();
         if ( isResolutionChanged ) {
             fheroes2::drawMainMenuScreen();
         }

         fheroes2::Text header( _( "Please Remember" ), { fheroes2::FontSize::NORMAL, fheroes2::FontColor::YELLOW } );

         fheroes2::MultiFontText body;
         body.add( { _( "You can always change game resolution by clicking on the " ), { fheroes2::FontSize::NORMAL, fheroes2::FontColor::WHITE } } );
         body.add( { _( "door" ), { fheroes2::FontSize::NORMAL, fheroes2::FontColor::YELLOW } } );
         body.add( { _( " on the left side of main menu.\n\nTo switch between windowed and full screen modes\npress " ),
                     { fheroes2::FontSize::NORMAL, fheroes2::FontColor::WHITE } } );
         body.add( { _( "F4" ), { fheroes2::FontSize::NORMAL, fheroes2::FontColor::YELLOW } } );
         body.add( { _( " key on the keyboard.\n\nEnjoy the game!" ), { fheroes2::FontSize::NORMAL, fheroes2::FontColor::WHITE } } );

         fheroes2::showMessage( header, body, Dialog::OK );

         conf.resetFirstGameRun();
         conf.Save( "fheroes2.cfg" );
     }

     LocalEvent & le = LocalEvent::Get();

     fheroes2::Button buttonNewGame( 0, 0, ICN::BTNSHNGL, NEWGAME_DEFAULT, NEWGAME_DEFAULT + 2 );
     fheroes2::Button buttonLoadGame( 0, 0, ICN::BTNSHNGL, LOADGAME_DEFAULT, LOADGAME_DEFAULT + 2 );
     fheroes2::Button buttonHighScores( 0, 0, ICN::BTNSHNGL, HIGHSCORES_DEFAULT, HIGHSCORES_DEFAULT + 2 );
     fheroes2::Button buttonCredits( 0, 0, ICN::BTNSHNGL, CREDITS_DEFAULT, CREDITS_DEFAULT + 2 );
     fheroes2::Button buttonQuit( 0, 0, ICN::BTNSHNGL, QUIT_DEFAULT, QUIT_DEFAULT + 2 );

     const fheroes2::Sprite & lantern10 = fheroes2::AGG::GetICN( ICN::SHNGANIM, 0 );
     fheroes2::Blit( lantern10, display, lantern10.x(), lantern10.y() );

     const fheroes2::Sprite & lantern11 = fheroes2::AGG::GetICN( ICN::SHNGANIM, ICN::AnimationFrame( ICN::SHNGANIM, 0, 0 ) );
     fheroes2::Blit( lantern11, display, lantern11.x(), lantern11.y() );

     buttonNewGame.draw();
     buttonLoadGame.draw();
     buttonHighScores.draw();
     buttonCredits.draw();
     buttonQuit.draw();

     display.render();

     const double scaleX = static_cast<double>( display.width() ) / fheroes2::Display::DEFAULT_WIDTH;
     const double scaleY = static_cast<double>( display.height() ) / fheroes2::Display::DEFAULT_HEIGHT;
     const fheroes2::Size resolutionArea( static_cast<int32_t>( 63 * scaleX ), static_cast<int32_t>( 202 * scaleY ), static_cast<int32_t>( 90 * scaleX ),
                                          static_cast<int32_t>( 160 * scaleY ) );

     u32 lantern_frame = 0;

     std::vector<ButtonInfo> buttons{ { NEWGAME_DEFAULT, buttonNewGame, false, false },
                                      { LOADGAME_DEFAULT, buttonLoadGame, false, false },
                                      { HIGHSCORES_DEFAULT, buttonHighScores, false, false },
                                      { CREDITS_DEFAULT, buttonCredits, false, false },
                                      { QUIT_DEFAULT, buttonQuit, false, false } };

     for ( size_t i = 0; le.MouseMotion() && i < buttons.size(); ++i ) {
         const fheroes2::Sprite & sprite = fheroes2::AGG::GetICN( ICN::BTNSHNGL, buttons[i].frame );
         fheroes2::Blit( sprite, display, sprite.x(), sprite.y() );
     }

     fheroes2::Sprite highlightDoor = fheroes2::AGG::GetICN( ICN::SHNGANIM, 18 );
     fheroes2::ApplyPalette( highlightDoor, 8 );

     // mainmenu loop
     while ( 1 ) {
         if ( !le.HandleEvents( true, true ) ) {
             if ( Interface::Basic::EventExit() == fheroes2::GameMode::QUIT_GAME ) {
                 // if ( conf.ExtGameUseFade() )
                 //    display.Fade();
                 break;
             }
             else {
                 continue;
             }
         }

         bool redrawScreen = false;

         for ( size_t i = 0; i < buttons.size(); ++i ) {
             buttons[i].wasOver = buttons[i].isOver;

             if ( le.MousePressLeft( buttons[i].button.area() ) ) {
                 buttons[i].button.drawOnPress();
             }
             else {
                 buttons[i].button.drawOnRelease();
             }

             buttons[i].isOver = le.MouseCursor( buttons[i].button.area() );

             if ( buttons[i].isOver != buttons[i].wasOver ) {
                 u32 frame = buttons[i].frame;

                 if ( buttons[i].isOver && !buttons[i].wasOver )
                     ++frame;

                 if ( !redrawScreen ) {
                     redrawScreen = true;
                 }
                 const fheroes2::Sprite & sprite = fheroes2::AGG::GetICN( ICN::BTNSHNGL, frame );
                 fheroes2::Blit( sprite, display, sprite.x(), sprite.y() );
             }
         }

         if ( redrawScreen ) {
             display.render();
         }

         if ( HotKeyPressEvent( EVENT_BUTTON_NEWGAME ) || le.MouseClickLeft( buttonNewGame.area() ) )
             return fheroes2::GameMode::NEW_GAME;
         else if ( HotKeyPressEvent( EVENT_BUTTON_LOADGAME ) || le.MouseClickLeft( buttonLoadGame.area() ) )
             return fheroes2::GameMode::LOAD_GAME;
         else if ( HotKeyPressEvent( EVENT_BUTTON_HIGHSCORES ) || le.MouseClickLeft( buttonHighScores.area() ) )
             return fheroes2::GameMode::HIGHSCORES;
         else if ( HotKeyPressEvent( EVENT_BUTTON_CREDITS ) || le.MouseClickLeft( buttonCredits.area() ) )
             return fheroes2::GameMode::CREDITS;
         else if ( HotKeyPressEvent( EVENT_DEFAULT_EXIT ) || le.MouseClickLeft( buttonQuit.area() ) ) {
             if ( Interface::Basic::EventExit() == fheroes2::GameMode::QUIT_GAME ) {
                 // if ( conf.ExtGameUseFade() )
                 //     display.Fade();
                 return fheroes2::GameMode::QUIT_GAME;
             }
         }
         else if ( le.MouseClickLeft( resolutionArea ) ) {
             if ( Dialog::SelectResolution() ) {
                 conf.Save( "fheroes2.cfg" );
                 // force interface to reset area and positions
                 Interface::Basic::Get().Reset();
                 return fheroes2::GameMode::MAIN_MENU;
             }
         }

         // right info
         if ( le.MousePressRight( buttonQuit.area() ) )
             Dialog::Message( _( "Quit" ), _( "Quit Heroes of Might and Magic and return to the operating system." ), Font::BIG );
         else if ( le.MousePressRight( buttonLoadGame.area() ) )
             Dialog::Message( _( "Load Game" ), _( "Load a previously saved game." ), Font::BIG );
         else if ( le.MousePressRight( buttonCredits.area() ) )
             Dialog::Message( _( "Credits" ), _( "View the credits screen." ), Font::BIG );
         else if ( le.MousePressRight( buttonHighScores.area() ) )
             Dialog::Message( _( "High Scores" ), _( "View the high score screen." ), Font::BIG );
         else if ( le.MousePressRight( buttonNewGame.area() ) )
             Dialog::Message( _( "New Game" ), _( "Start a single or multi-player game." ), Font::BIG );
         else if ( le.MousePressRight( resolutionArea ) )
             Dialog::Message( _( "Select Game Resolution" ), _( "Change resolution of the game." ), Font::BIG );

         if ( validateAnimationDelay( MAIN_MENU_DELAY ) ) {
             const fheroes2::Sprite & lantern12 = fheroes2::AGG::GetICN( ICN::SHNGANIM, ICN::AnimationFrame( ICN::SHNGANIM, 0, lantern_frame ) );
             ++lantern_frame;
             fheroes2::Blit( lantern12, display, lantern12.x(), lantern12.y() );
             if ( le.MouseCursor( resolutionArea ) ) {
                 const int32_t offsetY = static_cast<int32_t>( 55 * scaleY );
                 fheroes2::Blit( highlightDoor, 0, offsetY, display, highlightDoor.x(), highlightDoor.y() + offsetY, highlightDoor.width(), highlightDoor.height() );
             }

             display.render();
         }
     }

     return fheroes2::GameMode::QUIT_GAME;
 }

 */

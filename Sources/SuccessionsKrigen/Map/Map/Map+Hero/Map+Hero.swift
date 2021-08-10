//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public extension Map {
    struct Hero: Equatable {
        let hero: SuccessionsKrigen.Hero
        let color: Map.Color
        let worldPosition: WorldPosition
        let army: Army
        let portraitRawId: Int
        let experiencePoints: Int
        let artifacts: [Artifact]
        let secondarySkills: [Map.Hero.SecondarySkill]
        let customName: String?
        let patrols: Bool
        let patrolSquare: Int
    }
}


public extension Map.Hero {
    
    static func randomStartingExperiencePointCount() -> Int {
        .random(in: 40...90)
    }
    
    struct Army: Equatable {
        let troops: [Troop]
    }
    
    enum PortraitSize: Equatable {
        case big, medium, small
    }
    
    func portraitSprite(size: PortraitSize, aggFile: AGGFile) throws -> Sprite {
        /*
         const fheroes2::Sprite & Heroes::GetPortrait( int id, int type )
         {
         if ( Heroes::UNKNOWN != id )
         switch ( type ) {
         case PORT_BIG:
         return fheroes2::AGG::GetICN( ICN::PORTxxxx( id ), 0 );
         case PORT_MEDIUM:
         return Heroes::DEBUG_HERO > id ? fheroes2::AGG::GetICN( ICN::PORTMEDI, id + 1 ) : fheroes2::AGG::GetICN( ICN::PORTMEDI, BAX + 1 );
         case PORT_SMALL:
         return Heroes::DEBUG_HERO > id ? fheroes2::AGG::GetICN( ICN::MINIPORT, id ) : fheroes2::AGG::GetICN( ICN::MINIPORT, BAX );
         default:
         break;
         }
         
         return fheroes2::AGG::GetICN( -1, 0 );
         }
         */
        fatalError()
    }
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public struct Map: Equatable {
    let metaData: MetaData
    let unique: Int
    let tiles: Tiles
    let heroes: Heroes
    let castles: Castles
    let kingdoms: Kingdoms
    let rumors: Rumors
    let eventsDay: EventDates
    let capturedObjects: CapturedObjects
    let signEventRiddles: SignEventRiddles
    
    let date: Date
    
    let weekOfCurrent: WeekOf
    let weekOfNext: WeekOf
    let ultimateArtifact: UltimateArtifact?
    
    internal init(
        metaData: MetaData,
        unique: Int,
        
        tiles tileList: [Tile],
        heroes heroList: [Hero],
        castles castleList: [Castle],
        kingdoms kingdomList: [Kingdom],
        rumors rumorList: [Rumor],
        eventsDay eventsDayList: [EventDate],
        capturedObjects: CapturedObjects,
        signEventRiddles signEventRiddlesList: [Map.SignEventRiddle]
    ) throws {
        self.metaData = metaData
        precondition(tileList.count == metaData.size.rawValue * metaData.size.rawValue, "Disrepancy between size and number of tiles")
        self.unique = unique
        self.tiles = Tiles(tileList)
        self.heroes = Heroes(heroList)
        self.castles = Castles(castleList)
        self.kingdoms = Kingdoms(kingdomList)
        self.rumors = Rumors(rumorList)
        self.eventsDay = EventDates(eventsDayList)
        self.capturedObjects = capturedObjects
        self.signEventRiddles = SignEventRiddles(signEventRiddlesList)
        
        self.date = .init(day: 1, week: 1, month: 1)
        self.weekOfCurrent = .random()
        self.weekOfNext = .random()
        
        if let tileForUltimateArtifact = tileList.first(where: { $0.info.mapObjectType == .randomUltimateArtifact }) {
            self.ultimateArtifact = .init(artifact: .randomUltimate(), worldPosition: tileForUltimateArtifact.worldPosition, isFound: false)
        } else {
            self.ultimateArtifact = .init(artifact: .randomUltimate(), worldPosition: WorldPosition(x: 1, y: 1), isFound: false)
        }
    }
}

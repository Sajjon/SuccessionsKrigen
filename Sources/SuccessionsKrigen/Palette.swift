//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-25.
//

import Foundation



/// There is only one file of this type in the archive : the file "kb.pal". This file is the palette. It contains the colors to use to interpret the images in ICN files. It is a 3*256 bytes file. All group of 3 bytes represent a RGB color. You may notice that this palette is very dark (each byte is letter or equal than 0x3F). You must multiplicate all the bytes by 4 to  obtain the real game's colors.
///
/// Some palette ranges are for color animation (cycling colors) for phoenix, fire elementaries, lava, water:
///     * 214-217 (red)
///     * 218-221 (yellow)
///     * 231-237 (ocean/river/lake colors)
///     * 238-241 (blue)
///
/// The color cycling is an in-game feature. Simply put, if you place color 214, it will be put in a cycle automatically: 214-215-216-217-214-... etc. If you start from color 215, it will go in the game like 215-216-217-214-215-... etc.
///
/// Note: in Heroes II, the ten first and the ten last palette's colors are black, as the color of index 36. So twenty colors are lost. Counting others nineteen for cycling, only 217 colors are available for the artwork.
///
///
public struct Palette {
    
    public struct Color: Equatable {
        public typealias Value = UInt8
        public let red: Value
        public let green: Value
        public let blue: Value
    }
    
    private let colors: [Color]
    
    public init(rawData: Data) {
        assert(rawData.count == Self.expectedSize, "Expected palette data to be #\(Self.expectedSize) bytes, but was: #\(rawData.count) bytes.")
        let dataReader = DataReader(data: rawData)
        func nextValue() -> UInt8 {
            try! dataReader.readUInt8() * UInt8(Self.multiplier)
        }
        self.colors = (0..<Self.entires).map { _ in
            Color(red: nextValue(), green: nextValue(), blue: nextValue())
        }
    }
    
}
private extension Palette {
    /// Must multiplicate all the bytes by `4` to obtain the real game's colors (source: https://thaddeus002.github.io/fheroes2-WoT/infos/informations.html)
    static let multiplier = 4
    static let entires = 256
    
    /// Three bytes per color (R, G, B) each represented as a single byte.
    static let entrySize = 3
    
    static let expectedSize = Self.entires * Self.entrySize
}

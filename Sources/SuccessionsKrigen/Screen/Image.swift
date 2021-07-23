//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-23.
//

import Foundation

public class Image {
    private var size: Size
    private var origin: Point
    
    private var layerOneData: Data?
    private var _layerTwoData: Data?
    
    
    public let isSingleLayerOnly: Bool
    public init(size: Size, origin: Point = .zero, isSingleLayerOnly: Bool) {
        self.size = size
        self.origin = origin
        self.isSingleLayerOnly = isSingleLayerOnly
    }
}


private extension Image {
    
    var layerTwoData: Data? {
        guard !isSingleLayerOnly else {
            if _layerTwoData != nil {
                fatalError("Expected layer two data to be nil since `isSingleLayerOnly` is true.")
            }
            return nil
        }
        return _layerTwoData
    }
    
    func resize(_ newSize: Size) {
        self.size = newSize
    }
    
    
    //    func copy( Image & out, int32_t outX, int32_t outY, int32_t width, int32_t height )
    func _copy(to out: Image, size targetSize: Size? = nil) {
        //        if ( !Verify( in, inX, inY, out, outX, outY, width, height ) ) {
        //            return;
        //        }
        
        let height = targetSize?.height ?? self.size.height
        let width = targetSize?.width ?? self.size.width
        
//        let widthIn = size.width
//        let widthOut = out.size.width
//
//        let inY = origin.y
//        let inX = origin.x
//
//        let offsetInY = inY * widthIn + inX
//        let imageInY = self.image().suffix(from: offsetInY)
//        let outY = out.origin.y
//        let outX = out.origin.x
//
//        let offsetOutY = outY * widthOut + outX
//        let imageOutY = out.image().suffix(from: offsetOutY)
//
//        let imageInYEnd = imageInY.suffix(from: height * widthIn)
        
        if out.isSingleLayerOnly {
            out.image = image
        } else {
            fatalError("not impl")
        }
//
//        if ( out.singleLayer() ) {
//            std::cout << "Is single layer only\n";
//            for ( ; imageInY != imageInYEnd; imageInY += widthIn, imageOutY += widthOut ) {
//                memcpy( imageOutY, imageInY, static_cast<size_t>( width ) );
//            }
//        }
//        else {
//            std::cout << "Is NOT single layer only\n";
//            const uint8_t * transformInY = in.transform() + offsetInY;
//            uint8_t * transformOutY = out.transform() + offsetOutY;
//
//            for ( ; imageInY != imageInYEnd; imageInY += widthIn, transformInY += widthIn, imageOutY += widthOut, transformOutY += widthOut ) {
//                memcpy( imageOutY, imageInY, static_cast<size_t>( width ) );
//                memcpy( transformOutY, transformInY, static_cast<size_t>( width ) );
//            }
//        }
    }
}

public extension Image {
    
    var image: Data {
        get {
            layerOneData ?? Data()
        }
        set {
            layerOneData = newValue
        }
    }
    
    func copy(to out: Image) {
        out.resize(self.size)
        _copy(to: out)
    }
}

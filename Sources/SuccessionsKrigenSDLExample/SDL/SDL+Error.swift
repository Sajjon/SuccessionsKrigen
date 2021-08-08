//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-02.
//

import Foundation
import CSDL2

func sdlError(prefix: String) -> String {
    let maxLen: Int32 = 1000
    var errMessage = Array<CChar>.init(repeating: 0, count: Int(maxLen))
    SDL_GetErrorMsg(&errMessage, maxLen)
    let errorMessage = String(bytes: errMessage.prefix(while: { $0 > 0 }).map(UInt8.init), encoding: String.Encoding.ascii)!
    return "\(prefix), error message: \(errorMessage) (code: \(SDL_GetError()!.pointee))"
}

func printSDLError(prefix: String) {
    let errorMessage = sdlError(prefix: prefix)
    print(errorMessage)
}

func sdlFatalError(reason: String, _ line: UInt = #line) -> Never {
    let errorMessage = sdlError(prefix: reason)
    fatalError(errorMessage, line: line)
}

//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation


public struct AGGFile {
    public typealias FileMetadata = (fileSize: Int, fileOffset: Int)
    private let files: [String: FileMetadata]
    private let rawData: Data
    
    /// Byte count of the raw agg file.
    public var size: Int { rawData.count }
    
    /// Number of records (files) found in this agg file.
    public var numberOfRecords: Int { files.count }
    
    public init(path: String) throws {
        guard let contentsRaw = FileManager.default.contents(atPath: path) else {
            throw Error.fileNotFound
        }
        self.rawData = contentsRaw
        var files: [String: FileMetadata] = [:]

        let size = contentsRaw.count
        let dataReader = DataReader(data: contentsRaw)
        let sizePerRecord = UInt32.byteCount * 3
        let numberOfRecordsRaw = try dataReader.readUInt16(endianess: .little)
        let numberOfRecords = Int(numberOfRecordsRaw)

        precondition(numberOfRecords * (sizePerRecord + Self.maxFilenameSize) < size)

        let nameEntriesSize = Self.maxFilenameSize * numberOfRecords

        let fileEntriesData = try dataReader.read(byteCount: numberOfRecords * sizePerRecord)
        let fileEntries = DataReader(data: fileEntriesData)
        try dataReader.seek(to: size - nameEntriesSize)
        let nameEntriesData = try dataReader.read(byteCount: nameEntriesSize)
        let nameEntries = DataReader(data: nameEntriesData)

        for _ in 0..<numberOfRecords {
            let nameData = try nameEntries.read(byteCount: Self.maxFilenameSize)
            guard let namePadded = String(data: nameData, encoding: .ascii) else { throw Error.failedToParseFileName }
            let name = String(namePadded.prefix(while: { guard let asciiValue = $0.asciiValue, asciiValue > 0 else { return false }; return true }))

            // CRC part skipped
            let _ = try fileEntries.readUInt32()

            let fileOffset = try fileEntries.readUInt32()
            let fileSize = try fileEntries.readUInt32()
            files[name] = (fileSize: Int(fileSize), fileOffset: Int(fileOffset))
        }

        self.files = files
    }
}


public extension AGGFile {
    /// 8.3 ASCIIZ file name + 2-bytes padding
    static let maxFilenameSize =  15
    
    func read(fileName: String) throws -> Data {
        let dataReader = DataReader(data: rawData)
        guard let fileMetadata = files[fileName] else {
            throw Error.noSuchFile(named: fileName)
        }
        try dataReader.seek(to: fileMetadata.fileOffset)
        let data = try dataReader.read(byteCount: fileMetadata.fileSize)
        return data
    }
}

public extension AGGFile {
    enum Error: Swift.Error {
        case fileNotFound, failedToParseFileName, noSuchFile(named: String)
    }
}

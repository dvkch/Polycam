//
//  Bytes.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation

public typealias Bytes = [UInt8]

public extension Bytes {
    init?(string: String) {
        let bytes = string.components(separatedBy: " ").map { Byte($0, radix: 16) }
        guard !bytes.contains(nil) else { return nil }
        self.init(bytes.map({ $0! }))
    }
}

public extension Bytes {
    var hexString: String {
        map(\.hexString).joined(separator: " ")
    }
    
    var binString: String {
        map(\.binString).joined(separator: " ")
    }
}

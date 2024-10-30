//
//  PTZArgument.swift
//  
//
//  Created by syan on 04/07/2024.
//

import Foundation

struct PTZArgument {
    init(_ value: any PTZValue, _ position: Position) {
        self.value = value
        self.position = position
    }

    init(_ rawByte: Byte, index8: Int) {
        self.value = PTZUInt(rawValue: UInt16(rawByte))
        self.position = .raw8(index8)
    }
    
    let value: any PTZValue
    
    enum Position {
        case single
        case raw8(_ index: Int)
        case raw16(_ index: Int)
        case custom(hiIndex: Int, loIndex: Int, loRetainerIndex: Int, loRetainerMask: Byte)
    }
    let position: Position
}

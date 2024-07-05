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
    
    let value: any PTZValue
    
    enum Position {
        case single
        case index(Int)
        case custom(hiIndex: Int, loIndex: Int, loRetainerIndex: Int, loRetainerMask: Byte)
    }
    let position: Position
}

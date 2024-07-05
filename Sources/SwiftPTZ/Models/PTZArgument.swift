//
//  File.swift
//  
//
//  Created by syan on 04/07/2024.
//

import Foundation

struct PTZArgument {
    let value: any PTZValue
    
    enum Position {
        case single
        case index(Int)
        case custom(hiIndex: Int, loIndex: Int, loRetainerIndex: Int, loRetainerMask: UInt8)
    }
    let position: Position
}

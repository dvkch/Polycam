//
//  PTZRegister.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public struct PTZRegister<Variant: PTZVariant> {
    let category: Byte
    let register: Byte
    
    public init(_ category: Byte, _ register: Byte) {
        precondition(category < 0x40)
        self.category = category
        self.register = register
    }
    
    public func get(_ variant: Variant) -> (Byte, Byte) {
        return (category, register + variant.registerOffset)
    }
    
    public func `set`(_ variant: Variant, regOffset: Byte = 0) -> (Byte, Byte) {
        return (category + 0x40, register + variant.registerOffset + regOffset)
    }
}

extension PTZRegister where Variant == PTZNone {
    public func get() -> (Byte, Byte) {
        return get(.init())
    }
    
    public func `set`(regOffset: Byte = 0) -> (Byte, Byte) {
        return set(.init(), regOffset: regOffset)
    }
}

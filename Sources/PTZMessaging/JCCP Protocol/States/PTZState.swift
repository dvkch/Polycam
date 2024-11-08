//
//  PTZState.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZState<Variant, Value>: CustomStringConvertible {
    associatedtype Value: Equatable & CustomStringConvertible
    associatedtype Variant: PTZVariant
    static var name: String { get }
    var variant: Variant { get }
    var value: Value { get set }
}

public extension PTZState where Variant == PTZNone {
    var variant: Variant { .init() }
}

public extension PTZState {
    static var variants: [Variant] { Variant.allCases.map({ $0 }) }
    
    var description: String {
        if variant is PTZNone && value is PTZNone {
            Self.name
        }
        else if variant is PTZNone {
            "\(Self.name)(\(value))"
        }
        else {
            "\(Self.name)(\(variant): \(value))"
        }
    }
}

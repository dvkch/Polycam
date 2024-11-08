//
//  PTZReadable.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZReadable: PTZAddressable where Value: JSONEncodable {
    init?(message: PTZMessage)
    static func get(for variant: Variant) -> PTZRequest
}

public extension PTZReadable {
    static func get(for variant: Variant) -> PTZRequest {
        var descr = name
        if !(variant is PTZNone) {
            descr += "(\(variant.description))"
        }
        return .init(name: descr, message: .init(Self.register.get(variant)))
    }
}

public extension PTZReadable where Variant == PTZNone {
    static func get() -> PTZRequest {
        return get(for: .init())
    }
}

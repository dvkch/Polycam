//
//  PTZAddressable.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZAddressable: PTZState {
    static var register: PTZRegister<Variant> { get }
}

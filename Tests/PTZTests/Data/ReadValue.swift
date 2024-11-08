//
//  ReadValue.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

struct ReadValue<T: Codable>: Codable {
    let name: String
    let value: T
}

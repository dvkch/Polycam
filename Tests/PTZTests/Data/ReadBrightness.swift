//
//  ReadBrightness.swift
//  PTZ
//
//  Created by syan on 09/11/2024.
//

import Foundation

struct ReadBrightness: Codable {
    let device: String
    let brightness: ReadValue<Int>
}

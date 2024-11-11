//
//  ReadMoving.swift
//  PTZ
//
//  Created by syan on 11/11/2024.
//

import Foundation

struct ReadMoving: Codable {
    let device: String
    let moving: ReadValue<Bool>
}

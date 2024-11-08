//
//  ReadSleepTimeout.swift
//  PTZ
//
//  Created by syan on 09/11/2024.
//

import Foundation

struct ReadSleepTimeout: Codable {
    let device: String
    let sleepTimeout: ReadValue<Int>
}

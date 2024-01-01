//
//  GetPositionFixture.swift
//  
//
//  Created by syan on 02/01/2024.
//

import Foundation

struct GetPositionFixture: Codable {
    let pan: Int
    let tilt: Int
    let zoom: Int
    let focus: Int
    let response: String
    
    private enum CodingKeys: String, CodingKey {
        case pan = "pan"
        case tilt = "tilt"
        case zoom = "zoom"
        case focus = "focus"
        case response = "response"
    }
}

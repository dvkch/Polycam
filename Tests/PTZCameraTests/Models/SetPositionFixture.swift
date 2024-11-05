//
//  SetPositionFixture.swift
//
//
//  Created by syan on 31/12/2023.
//

import Foundation

struct SetPositionFixture: Codable {
    let pan: Int
    let tilt: Int
    let zoom: Int
    let query: String
    
    private enum CodingKeys: String, CodingKey {
        case pan = "pan"
        case tilt = "tilt"
        case zoom = "zoom"
        case query = "query"
    }
}

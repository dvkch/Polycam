//
//  Preset.swift
//  PTZ
//
//  Created by syan on 11/11/2024.
//

import Foundation
import PTZCamera

struct Preset: Codable {
    init(name: String, pan: Int, tilt: Int, zoom: Int) {
        self.name = name
        self.pan = pan
        self.tilt = tilt
        self.zoom = zoom
    }
    
    var name: String
    var pan: Int
    var tilt: Int
    var zoom: Int
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case pan = "pan"
        case tilt = "tilt"
        case zoom = "zoom"
    }
}

extension Preset {
    init(name: String, position: PTZPosition) {
        self.name = name
        self.pan = position.pan.rawValue
        self.tilt = position.tilt.rawValue
        self.zoom = position.zoom.rawValue
    }

    var position: PTZPosition {
        PTZPosition(pan: .init(rawValue: pan), tilt: .init(rawValue: tilt), zoom: .init(rawValue: zoom))
    }
}

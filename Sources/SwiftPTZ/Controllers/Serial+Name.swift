//
//  Serial+Name.swift
//
//
//  Created by syan on 11/06/2024.
//

import Foundation

extension Serial {
    struct Name: RawRepresentable {
        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Serial.Name {
    static var firstAvailable: Serial.Name? {
        let devices = allAvailables
        let names = devices.map(\.rawValue).joined(separator: ", ")
        print("Found \(devices.count) devices:", names)

        if let device = devices.first {
            print("Using \(device.rawValue)")
            return device
        }
        return nil
    }
    
    static var allAvailables: [Serial.Name] {
        let devices = try! FileManager.default.contentsOfDirectory(at: URL(string: "file:///dev")!, includingPropertiesForKeys: nil)
        return devices.filter { $0.lastPathComponent.hasPrefix("cu.usbserial-") }.map { Serial.Name(rawValue: $0.standardizedFileURL.path) }
    }
}

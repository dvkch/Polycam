//
//  SerialName.swift
//
//
//  Created by syan on 11/06/2024.
//

import Foundation

public struct SerialName: RawRepresentable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static func givenOrFirst(_ rawValue: String?) throws(DeviceError) -> Self {
        if let rawValue {
            return .init(rawValue: rawValue)
        }
        if let firstAvailable {
            return firstAvailable
        }
        throw DeviceError.noSerialDevice
    }
}

extension SerialName {
    public static var firstAvailable: SerialName? {
        return allAvailables.first
    }
    
    public static var allAvailables: [SerialName] {
        #warning("make it work on linux")
        let devices = try! FileManager.default.contentsOfDirectory(at: URL(string: "file:///dev")!, includingPropertiesForKeys: nil)
        return devices.filter { $0.lastPathComponent.hasPrefix("cu.usbserial-") }.map { SerialName(rawValue: $0.standardizedFileURL.path) }
    }
}

//
//  Hello.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

// 8f 30 46 77 06 30 31 30 30 30 30 35 37 30 31 30 31 30 30 35 32 30 31 30 30 30 30 32 31 30 31 30 30 30 30 30 36 32 39 35 30 30 31 30 31 30 30 34 38
// 8f 30 46 77 06 01000057 01010052 01000021 01000006 2950 01010048
// From logs: MPTZ_11, sysver = "01000057", camver = "01010052", lensver = "", promver = "", backver = "01000021", bootver = "01000006", splver = "2950", pkgver = "01010048"

public struct PTZHello: Equatable, CustomStringConvertible, JSONEncodable {
    public let sysVer: String
    public let camVer: String
    public let backVer: String
    public let bootVer: String
    public let splVer: String
    public let pkgVer: String
    
    public var description: String { "MPTZ 11 sysVer=\(sysVer) camVer=\(camVer) backVer=\(backVer) bootVer=\(bootVer) splVer=\(splVer) pkgVer=\(pkgVer)" }
    public var toJSON: JSONValue { return ["sysVer": sysVer, "camVer": camVer, "backVer": backVer, "bootVer": bootVer, "splVer": splVer, "pkgVer": pkgVer] }
}

/// Get a hello response to determine the camera type and its components versions
/// Discovered in the original application's log
public struct PTZHelloState: PTZReadable {
    public static let name: String = "Hello"
    public static let register: PTZRegister<PTZNone> = .init(0x06, 0x77)
    
    public var value: PTZHello
    
    public init?(message: PTZMessage) {
        // idk why sometimes it is 0x05, sometimes 0x06... i would have also expected to be waiting for 46 77, which
        // we do always have, but 46 is also the length of the whole reply... since we don't have any other devices
        // or commands with similar replies to test theories, let's wait for 8F 30 xx 77 06 or 8F 30 xx 77 05
        // and use 46 as the length indication
        guard message.isValidReply((0x06, 0x77)) || message.isValidReply((0x05, 0x77)) else { return nil }
        var packed = message.decodePackedData()
        guard packed.count >= 44 else { return nil }
        self.value = .init(
            sysVer:  packed.takeFirst(8).map { String($0) }.joined(),
            camVer:  packed.takeFirst(8).map { String($0) }.joined(),
            backVer: packed.takeFirst(8).map { String($0) }.joined(),
            bootVer: packed.takeFirst(8).map { String($0) }.joined(),
            splVer:  packed.takeFirst(4).map { String($0) }.joined(),
            pkgVer:  packed.takeFirst(8).map { String($0) }.joined()
        )
    }
}

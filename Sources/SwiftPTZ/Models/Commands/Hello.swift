//
//  Hello.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

#warning("Hello reply doesn't seem to be parsed anymore")

struct PTZRequestHelloMPTZ11: PTZGetRequest {
    typealias Reply = PTZReplyHelloMPTZ11
    var bytes: Bytes { return buildBytes([0x06, 0x77]) }
    var description: String { return "Hello MPTZ 11" }
}

// 8f 30 46 77 06 30 31 30 30 30 30 35 37 30 31 30 31 30 30 35 32 30 31 30 30 30 30 32 31 30 31 30 30 30 30 30 36 32 39 35 30 30 31 30 31 30 30 34 38
// 8f 30 46 77 06 01000057 01010052 01000021 01000006 2950 01010048
// From logs: MPTZ_11, sysver = "01000057", camver = "01010052", lensver = "", promver = "", backver = "01000021", bootver = "01000006", splver = "2950", pkgver = "01010048"

struct PTZReplyHelloMPTZ11: PTZReply {
    let sysVer: String
    let camVer: String
    let backVer: String
    let bootVer: String
    let splVer: String
    let pkgVer: String
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x06, 0x77]) else { return nil }
        var packed = message.decodePackedData()
        guard packed.count >= 44 else { return nil }
        sysVer  = packed.takeFirst(8).map { String($0) }.joined()
        camVer  = packed.takeFirst(8).map { String($0) }.joined()
        backVer = packed.takeFirst(8).map { String($0) }.joined()
        bootVer = packed.takeFirst(8).map { String($0) }.joined()
        splVer  = packed.takeFirst(4).map { String($0) }.joined()
        pkgVer  = packed.takeFirst(8).map { String($0) }.joined()
    }
    
    var description: String {
        return "MPTZ 11(sysVer=\(sysVer) camVer=\(camVer) backVer=\(backVer) bootVer=\(bootVer) splVer=\(splVer) pkgVer=\(pkgVer))"
    }
}

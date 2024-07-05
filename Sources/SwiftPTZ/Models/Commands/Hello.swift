//
//  Hello.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestHello: PTZRequest {
    var bytes: Bytes {
        // 82 06 77
        // 82 06 7e
        // 82 06 7f
        return buildBytes([0x06, 0x77])
    }

    var description: String {
        return "Hello"
    }
}

#warning("TODO: test multiple hello commands")
#warning("TODO: parse hello reply")

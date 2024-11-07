//
//  Speak.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation

func speak<T: CustomStringConvertible>(_ value: T) {
    speak(value.description)
}

func speak(_ string: String) {
    #if os(macOS)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["say", string]
    try? process.run()
    #endif
}


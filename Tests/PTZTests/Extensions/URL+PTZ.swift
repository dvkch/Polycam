//
//  URL+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

extension URL {
    static var productsDirectory: URL {
#if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
#else
        return Bundle.main.bundleURL
#endif
    }
}


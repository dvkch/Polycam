//
//  JSONEncodable.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

public protocol JSONEncodable {
    var toJSON: JSONValue { get }
}

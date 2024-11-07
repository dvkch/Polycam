//
//  JSONValue.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

public protocol JSONValue {}
extension Bool: JSONValue {}
extension UInt16: JSONValue {}
extension UInt32: JSONValue {}
extension Int: JSONValue {}
extension String: JSONValue {}
extension Array: JSONValue where Element == any JSONValue {}
extension Dictionary: JSONValue where Key: JSONValue, Value == any JSONValue {}

//
//  Interactive.swift
//  SwiftPTZ
//
//  Created by syan on 25/10/2024.
//

import Foundation
import SwiftCurses

struct Interactive {
    static func traverse(_ elements: [any Interactive.Element], closure: (any Element, Int, IndexPath) throws -> ()) rethrows {
        try traverse(elements, indexOffset: 0, parentPath: IndexPath(), closure: closure)
    }
    
    private static func traverse(_ elements: [any Element], indexOffset: Int, parentPath: IndexPath, closure: (any Element, Int, IndexPath) throws -> ()) rethrows {
        var compoundIndex = indexOffset
        for (i, el) in elements.enumerated() {
            try closure(el, compoundIndex, parentPath.appending(i))
            compoundIndex += 1
            
            try traverse(el.children, indexOffset: compoundIndex, parentPath: parentPath.appending(i)) {
                compoundIndex += 1
                try closure($0, $1, $2)
            }
        }
    }
}
    
extension Interactive {
    protocol Element: Identifiable {
        var id: String { get }
        var output: String { get }
        var selectable: Bool { get }
        var children: [any Interactive.Element] { get }
        func input(char: WideChar, camera: Camera) -> Bool
    }
    
    struct Line: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        init(_ name: String) {
            self.name = name
        }
        
        // InteractiveElement
        var output: String { name }
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    struct DynamicLine: Interactive.Element {
        let id = UUID().uuidString
        let name: () -> String
        
        // InteractiveElement
        var output: String { name() }
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    class Group: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let items: [any Interactive.Element]
        
        init(_ name: String, _ items: [any Interactive.Element]) {
            self.name = name
            self.items = items
        }

        // InteractiveElement
        var output: String { name + (opened ? "" : " (+)") }
        var selectable: Bool { true }
        private var opened = true
        var children: [any Interactive.Element] {
            opened ? items + [Interactive.Line("")] : []
        }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .char(" "): // space
                opened.toggle()
                
            default:
                return false
            }
            return true
        }
    }
    
    class Action<T: CustomStringConvertible>: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        var state: T
        let action: (T) -> T
        
        init(name: String, state: T, action: @escaping (T) -> T) {
            self.name = name
            self.state = state
            self.action = action
        }
        
        // InteractiveElement
        var output: String { "\(name) (\(state))" }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .char(" "): // space
                state = action(state)
            default:
                return false
            }
            return true
        }
    }
    
    class State: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let category: UInt8
        let register: UInt8
        private(set) var values: Array<UInt16>
        let `default`: UInt16
        private var currentValue: UInt16 = 0
        private var setError: String? = nil

        convenience init<T: PTZScaledValue>(_ name: String, cat category: UInt8, r register: UInt8, value: T.Type) {
            self.init(name, cat: category, r: register, values: T.min.ptzValue...T.max.ptzValue, default: T.default.ptzValue)
        }

        convenience init<T: PTZValue & CaseIterable>(_ name: String, cat category: UInt8, r register: UInt8, value: T.Type) {
            self.init(name, cat: category, r: register, values: T.allCases.map(\.ptzValue), default: T.default.ptzValue)
        }

        init(_ name: String, cat category: UInt8, r register: UInt8, values: any Collection<UInt16>, default: UInt16) {
            self.name = name
            self.category = category
            self.register = register
            self.values = values.map { $0 }
            self.default = `default`
            
            if values.count > 30 {
                self.values = stride(from: 0, to: self.values.count - 1, by: max(1, self.values.count / 30)).map { self.values[$0] }
            }
        }
        
        func refresh(for camera: Camera) {
            let (bytes, _) = try! camera.sendRequest2(PTZUnknownRequest(commandBytes: [category, register], arg: nil))
            let value = PTZMessage.messages(from: bytes).last!.parseArgument(type: PTZUInt.self, position: .single).ptzValue
            currentValue = values.closest(to: value) ?? value
        }
        
        func set(for camera: Camera, to value: UInt16) {
            let req = PTZUnknownRequest(commandBytes: [category + 0x40, register], arg: value)
            let reply = try! camera.sendRequest(req)
            currentValue = values.closest(to: value) ?? value
            setError = (reply is PTZReplyExecuted) ? nil : "\(req.bytes.stringRepresentation) => \(reply.description)"
        }
        
        // InteractiveElement
        var output: String {
            var string = "\(name) (\(currentValue))"
            if string.count < 30 {
                string = string.padding(toLength: 30, withPad: " ", startingAt: 0)
            }
            string += " <"
            for v in values {
                string += (currentValue == v) ? "O" : "·"
            }
            string += ">"
            if let setError {
                string += " \(setError)"
            }
            return string
        }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .code(260): // left
                let value = values.elementBefore(currentValue, or: values.first!)
                set(for: camera, to: value)
                
            case .code(261): // right
                let value = values.elementAfter(currentValue, or: values.last!)
                set(for: camera, to: value)

            case .char(" "): // space
                set(for: camera, to: `default`)
                
            default:
                return false
            }
            return true
        }
    }
}

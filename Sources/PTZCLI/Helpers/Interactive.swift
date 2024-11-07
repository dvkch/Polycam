//
//  Interactive.swift
//  PTZ
//
//  Created by syan on 25/10/2024.
//

import Foundation
import SwiftCurses
import PTZCamera
import PTZMessaging

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
    
    protocol RefreshableElement: Element {
        func refresh()
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
    
    class State<T: PTZReadable & PTZWriteable>: Interactive.RefreshableElement {
        let id = UUID().uuidString
        private let camera: Camera
        private let variant: T.Variant
        private var values: Array<T.Value>
        private let defaultValue: T.Value
        private var currentValue: T.Value
        private var lastError: String?

        convenience init(_ state: T.Type, for camera: Camera, values: any Collection<T.Value>, default: T.Value) where T.Variant == PTZNone {
            self.init(state, for: camera, variant: .init(), values: values, default: `default`)
        }

        convenience init(_ state: T.Type, for camera: Camera, default: T.Value) where T.Variant == PTZNone, T.Value: PTZValue {
            self.init(state, for: camera, variant: .init(), values: T.Value.testValues, default: `default`)
        }

        init(_ state: T.Type, for camera: Camera, variant: T.Variant, values: any Collection<T.Value>, default: T.Value) {
            self.camera = camera
            self.variant = variant
            self.values = values.map { $0 }
            self.currentValue = try! camera.get(T.self , for: variant)
            self.defaultValue = `default`
            
            if values.count > 30 {
                self.values = stride(from: 0, to: self.values.count - 1, by: max(1, self.values.count / 30)).map { self.values[$0] }
            }
        }
        
        #warning("doesn't seem to work")
        private func setCurrentValue(_ value: T.Value) where T.Value: RawRepresentable, T.Value.RawValue == UInt16 {
            let rawValue = values.map(\.rawValue).closest(to: value.rawValue) ?? value.rawValue
            currentValue = .init(rawValue: rawValue)!
        }

        private func setCurrentValue(_ value: T.Value) {
            currentValue = value
        }

        private func set(to value: T.Value) {
            do {
                try camera.set(T.init(value, for: variant))
                setCurrentValue(value)
                self.lastError = nil
            }
            catch {
                self.lastError = error.localizedDescription
            }
        }

        // RefreshableElement
        func refresh() {
            do {
                let value = try camera.get(T.self, for: variant)
                setCurrentValue(value)
                self.lastError = nil
            }
            catch {
                self.lastError = error.localizedDescription
            }
        }

        // InteractiveElement
        var output: String {
            var string = "\(T.name) (\(currentValue))"
            if string.count < 30 {
                string = string.padding(toLength: 30, withPad: " ", startingAt: 0)
            }
            string += " <"
            for v in values {
                string += (currentValue == v) ? "O" : "·"
            }
            string += ">"
            if let lastError {
                string += " \(lastError)"
            }
            return string
        }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .code(260): // left
                let value = values.elementBefore(currentValue, or: values.first!)
                set(to: value)
                
            case .code(261): // right
                let value = values.elementAfter(currentValue, or: values.last!)
                set(to: value)

            case .char(" "): // space
                set(to: defaultValue)
                
            default:
                return false
            }
            return true
        }
    }
}

//
//  Printer.swift
//  SwiftPTZ
//
//  Created by syan on 30/10/2024.
//

struct Printer {
    static func printHeader(_ header: String) {
        print("")
        print("")
        print(header)
        print(String(repeating: "-", count: header.count))
        print("")
    }

    static func printTable(_ table: [[String]], headers: [String], closeLastColumn: Bool) {
        var columnWidths: [Int: Int] = [:]
        for row in table + [headers] {
            for (col, value) in row.enumerated() {
                columnWidths[col] = max(columnWidths[col, default: 0], value.count)
            }
        }
        
        // header
        for (col, value) in headers.enumerated() {
            print("| " + value.padding(toLength: columnWidths[col]!, withPad: " ", startingAt: 0) + " ", terminator: "")
            if col == headers.count - 1 {
                print("|", terminator: "\n")
            }
        }
        
        // separator
        for col in columnWidths.keys.sorted() {
            print("|" + String(repeating: "-", count: columnWidths[col]! + 2), terminator: "")
            if col == headers.count - 1 {
                print("|", terminator: "\n")
            }
        }
        
        // header
        for row in table {
            for (col, value) in row.enumerated() {
                var formattedValue = value
                if col < headers.count - 1 || closeLastColumn {
                    formattedValue = formattedValue.padding(toLength: columnWidths[col]! + 1, withPad: " ", startingAt: 0)
                }
                print("| " + formattedValue, terminator: "")
                if col == headers.count - 1 {
                    print(closeLastColumn ? "|" : "", terminator: "\n")
                }
            }
        }
    }
}

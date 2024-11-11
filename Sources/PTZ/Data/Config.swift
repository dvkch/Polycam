//
//  Config.swift
//  PTZ
//
//  Created by syan on 11/11/2024.
//

import Foundation

struct Config: Codable {
    var presets: [Preset] = []
    
    private enum CodingKeys: String, CodingKey {
        case presets = "presets"
    }
}

extension Config {
    static var defaultURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appending(path: ".config").appending(path: "ptz.json")
    }
    
    static func read(path: URL) -> Config {
        guard let data = try? Data(contentsOf: path) else {
            return .init()
        }
        
        do {
            return try JSONDecoder().decode(Config.self, from: data)
        }
        catch {
            fatalError("Couldn't parse config file: \(error)")
        }
    }
    
    func write(to path: URL) {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: path, options: .atomic)
        }
        catch {
            print("Couldn't write config file: \(error)")
        }
    }
}

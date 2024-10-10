//
//  Files.swift
//  Rizz
//
//  Created by Tamas Bara on 06.10.24.
//

import Foundation

enum Files: String {
    
    case accessKey
    
    var text: String? {
        if let filepath = Bundle.main.path(forResource: rawValue, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                DebugLog.log("--- \(rawValue): \(contents)")
                return contents
            } catch {
                DebugLog.log("--- \(rawValue) could not be loaded")
            }
        } else {
            DebugLog.log("--- \(rawValue) not found")
        }
        
        return nil
    }
}

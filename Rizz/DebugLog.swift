//
//  DebugLog.swift
//  Rizz
//
//  Created by Tamas Bara on 07.10.24.
//

enum DebugLog {
    
    static var log: String = ""
    
    static func log(_ text: String) {
        log.append(text + "\n")
    }
}

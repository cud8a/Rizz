//
//  ColorTheme.swift
//  Rizz
//
//  Created by Tamas Bara on 06.10.24.
//

import SwiftUI

struct Theme: Hashable, Codable {
    
    let name: String
    let text: String
    let background: String
    let day: String
    let dayBackground: String
    let dayText: String
    let dayBackgroundAlpha: Float
    
    static var deflt: Theme {
        .init(name: "Default", text: "white", background: "clear", day: "#DA6C46", dayBackground: "#cdcdcd", dayText: "black", dayBackgroundAlpha: 0.2)
    }
}

enum DefinedColors: String {
    case clear, black, white, red, green, blue, yellow, purple, orange, gray
    
    var color: UIColor {
        switch self {
        case .clear: return .clear
        case .black: return .black
        case .white: return .white
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        case .gray: return .gray
        }
    }
}

struct ColorTheme: Hashable {
    
    let name: String
    let text: Color
    let background: Color
    let day: Color
    let dayBackground: Color
    let dayText: Color
    
    init(theme: Theme) {
        name = theme.name
        text = Color(Self.color(theme.text))
        background = Color(Self.color(theme.background))
        day = Color(Self.color(theme.day))
        dayBackground = Color(Self.color(theme.dayBackground).withAlphaComponent(CGFloat(theme.dayBackgroundAlpha)))
        dayText = Color(Self.color(theme.dayText))
    }
    
    private static func color(_ string: String) -> UIColor {
        if string.hasPrefix("#") {
            return .init(hash: string)
        }
        
        return DefinedColors(rawValue: string)?.color ?? .gray
    }
}

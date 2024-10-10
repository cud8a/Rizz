//
//  Extensions.swift
//  Rizz
//
//  Created by Tamas Bara on 04.04.24.
//

import SwiftUI

extension Float {
    
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = ","
        return formatter
    }
    
    var temperature: String {
        let value = Self.formatter.string(from: NSNumber(value: self)) ?? ""
        return value + " °C"
    }
}

extension UIColor {
    
    convenience init(hash: String) {
        var string = hash
        if (hash.hasPrefix("#")) {
            string.remove(at: hash.startIndex)
        }

        if ((string.count) != 6) {
            self.init(.gray)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: string).scanHexInt64(&rgbValue)
        
        self.init(hex: Int(rgbValue))
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
    
    static var cellText: UIColor { .init(hex: 0xffffff) }
    static var text: UIColor { .init(hex: 0x1c1c1c) }
    static var lightGray: UIColor { .init(hex: 0x8c8c8c) }
    static var ultraLightGray: UIColor { .init(hex: 0xe8e8e8) }
    static var dayBack: UIColor { .init(hex: 0xcdcdcd).withAlphaComponent(0.2) }
    static var cell: UIColor { .init(hex: 0xEB573E) }
    static var day: UIColor { .init(hex: 0x39FF13) }
    static var back: UIColor { .init(hex: 0x8a00c4) }
}

enum DateFormat: String {
    case deflt = "dd.MM.yyyy"
    case apiDate = "yyyy-MM-dd HH:mm:ss"
    case day = "EEEE"
    case hour = "H 'Uhr'"
    case minute = "H:mm 'Uhr'"
}

protocol DateCodable {
    static func decode(_ value: String?) throws -> Date?
    static func encode(_ date: Date?) -> String?
}

extension DateValue: Hashable {}

@propertyWrapper
struct DateValue<Formatter: DateCodable>: Codable {
    var wrappedValue: Date?
    
    init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let value = try? String(from: decoder)
        self.wrappedValue = try? Formatter.decode(value)
    }
    
    func encode(to encoder: Encoder) throws {
        let value = Formatter.encode(wrappedValue)
        try? value.encode(to: encoder)
    }
}

struct APIDate: DateCodable {
    static func decode(_ value: String?) throws -> Date? {
        guard let value else { return nil }
        return Date.apiFormatter.date(from: value)
    }
    
    static func encode(_ date: Date?) -> String? {
        guard let date else { return nil }
        return Date.apiFormatter.string(from: date)
    }
}

extension Date {
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    static var apiFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = DateFormat.apiDate.rawValue
        return dateFormatter
    }
    
    static func formatter(format: DateFormat) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter
    }
}

struct PinModifier: ViewModifier {

    enum Mode {
        case left
        case right
    }
    
    var mode = Mode.left
    
    func body(content: Content) -> some View {
        HStack {
            switch mode {
            case .left:
                content
                Spacer()
            default:
                Spacer()
                content
            }
        }
    }
}

extension View {
    
    func pinLeft() -> some View {
        modifier(PinModifier())
    }
    
    func pinRight() -> some View {
        modifier(PinModifier(mode: .right))
    }
}

extension Collection {

    subscript(safeIndex index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

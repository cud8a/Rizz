//
//  SettingsResult.swift
//  Rizz
//
//  Created by Tamas Bara on 04.10.24.
//

import Foundation

struct Location: Codable, Hashable {
    let lat: Float
    let lon: Float
    let name: String
}

struct SettingsResponse: Codable {
    var record: Record
}

struct Record: Codable {
    var openWeather: OpenWeather?
    var geoApify: GeoApify?
    var locations: [Location]?
    var themes: [Theme]?
    var sample: String?
    
    enum CodingKeys: String, CodingKey {
        case openWeather, locations, themes
        case geoApify = "geoapify"
    }
}

struct OpenWeather: Codable {
    var appId: String
}

struct GeoApify: Codable {
    var apiKey: String
}

struct UpdateError: Codable {
    var message: String
}

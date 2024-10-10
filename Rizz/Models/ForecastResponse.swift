//
//  ForecastResponse.swift
//  Rizz
//
//  Created by Tamas Bara on 02.10.24.
//

import Foundation

struct ForecastResponse: Codable {
    let cnt: Int
    let list: [Forecast]
    let city: City
}

struct City: Codable {
    
    var sunriseString: String {
        Date.formatter(format: .minute).string(for: Date(timeIntervalSince1970: TimeInterval(sunrise))) ?? ""
    }
    
    var sunsetString: String {
        Date.formatter(format: .minute).string(for: Date(timeIntervalSince1970: TimeInterval(sunset))) ?? ""
    }
    
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population, timezone, sunrise, sunset: Int
}

struct Coord: Codable {
    let lat, lon: Float
}

struct Weather: Hashable, Codable {
    let id: Int
    let description: String
    let icon: String
}

struct Temps: Hashable, Codable {
    
    let min, max, temp, feelsLike: Float
    let pressure, seaLevel, grndLevel, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case min = "temp_min"
        case max = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
    }
}

struct Forecast: Hashable, Codable {
    let timestamp: Int
    let temps: Temps
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let rain: Rain?
    
    @DateValue<APIDate> var date: Date?

    enum CodingKeys: String, CodingKey {
        case weather, clouds, wind, rain
        case temps = "main"
        case date = "dt_txt"
        case timestamp = "dt"
    }
    
    var iconUrl: URL? {
        guard let icon = weather.first?.icon else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
    
    var text: String { "\(weather.first?.description ?? "")\nMin: \(temps.min.temperature)\nMax: \(temps.max.temperature)" }
    
    var time: String {
        guard let date else { return "" }
        return Date.formatter(format: .hour).string(from: date)
    }
}

struct Wind: Hashable, Codable {
    let speed: Float
    let deg: Int
    let gust: Float
}

struct Rain: Hashable, Codable {
    let threeHours: Float

    enum CodingKeys: String, CodingKey {
        case threeHours = "3h"
    }
}

struct Clouds: Hashable, Codable {
    let all: Int
}

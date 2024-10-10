//
//  LocationResponse.swift
//  Rizz
//
//  Created by Tamas Bara on 08.10.24.
//

struct LocationResponse: Hashable, Codable {
    
    var features: [Feature]
    
    var filtered: [Feature] {
        features.filter({ $0.properties.isValid })
    }
}

struct Feature: Hashable, Codable {
    var properties: Properties
}

struct Properties: Hashable, Codable {
    
    let name: String?
    var city: String?
    var country: String
    var state: String?
    var lat: Float
    var lon: Float
    
    var info: String {
        [city, name, state, country].compactMap({ $0 }).joined(separator: ", ")
    }
    
    var isValid: Bool {
        name != nil || city != nil
    }
}

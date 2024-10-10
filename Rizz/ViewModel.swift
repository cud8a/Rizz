//
//  ViewModel.swift
//  Rizz
//
//  Created by Tamas Bara on 03.10.24.
//

import SwiftUI

@Observable class ViewModel {
    
    static var openWeather: OpenWeather?
    static var geoApify: GeoApify?
    
    @ObservationIgnored var themes: [Theme]?
    @ObservationIgnored var locations: [Location]?
    var loaded = false
    @ObservationIgnored var loading = false
    
    var colorThemes: [ColorTheme]? {
        themes?.map({ .init(theme: $0) })
    }
    
    func load() async {
        DebugLog.log("--- load locations")
        guard loaded == false, loading == false else { return }
        
        loading = true
        
        do {
            guard let result: SettingsResponse = try await Fetcher.locations.fetch() else { return }
            
            locations = result.record.locations
            Self.openWeather = result.record.openWeather
            Self.geoApify = result.record.geoApify
            themes = result.record.themes
            
            loading = false
            loaded = true
        } catch {
            DebugLog.log("--- load locations error: " + error.localizedDescription)
        }
    }
    
    func update(locations: [Location]) {
        DebugLog.log("--- update locations")
        guard loaded == true, loading == false else { return }
        
        guard let openWeather = Self.openWeather, let geoApify = Self.geoApify, let themes else { return }
        
        loaded = false
        loading = true
        
        Task {
            do {
                let record = Record(openWeather: openWeather, geoApify: geoApify, locations: locations, themes: themes)
                guard let result: SettingsResponse = try await Fetcher.update(model: record).fetch() else { return }
                self.locations = result.record.locations
                
                loading = false
                loaded = true
            } catch {
                DebugLog.log("--- update locations error: " + error.localizedDescription)
            }
        }
    }
}

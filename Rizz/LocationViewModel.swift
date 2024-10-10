//
//  LocationViewModel.swift
//  Rizz
//
//  Created by Tamas Bara on 03.10.24.
//

import SwiftUI

struct Day: Hashable {
    let isToday: Bool
    let name: String
    let forecasts: [Forecast]
    let info: [String]
    let sunrise: [String]
}

@Observable class LocationViewModel {
    
    @ObservationIgnored var forecast: ForecastResponse? {
        didSet {
            days = []
            var min = forecast?.list.first?.temps.min ?? 100
            var max: Float = forecast?.list.first?.temps.max ?? -100
            var isToday = true
            var forecasts: [Forecast] = []
            var currentDate = forecast?.list.first?.date ?? Date()
            var info: [String] = []
            var sunrise: [String] = []
            forecast?.list.forEach { entry in
                if canGroupDate(entry.date, currentDate: currentDate) {
                    if entry.temps.min < min { min = entry.temps.min }
                    if entry.temps.max > max { max = entry.temps.max }
                    forecasts.append(entry)
                } else if let date = entry.date {
                    var name = currentDate.isToday ? "Heute" : Date.formatter(format: .day).string(from: currentDate)
                    info = ["Min: \(min.temperature)", "Max: \(max.temperature)"]
                    if let forecast, name == "Heute" {
                        sunrise = ["\(forecast.city.sunriseString)", "\(forecast.city.sunsetString)"]
                    } else {
                        name = currentDate.isTomorrow ? "Morgen" : Date.formatter(format: .day).string(from: currentDate)
                    }
                    
                    days?.append(Day(isToday: isToday, name: name, forecasts: forecasts, info: info, sunrise: sunrise))
                    isToday = false
                    forecasts = [entry]
                    currentDate = date
                    min = entry.temps.min
                    max = entry.temps.max
                    info = []
                    sunrise = []
                }
            }
        }
    }
    
    private func canGroupDate(_ date: Date?, currentDate: Date) -> Bool {
        guard let date else { return false }
        
        if Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .day) {
            return true
        }
        
        if Calendar.current.component(.hour, from: date) < 8 {
            return true
        }
        
        return false
    }
    
    var loaded = false
    @ObservationIgnored var loading = false
    @ObservationIgnored var days: [Day]?
    @ObservationIgnored var lastLoad = Date()
    private var location: Location?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIfNeeded), name: Notification.Name("refreshIfNeeded"), object: nil)
    }
    
    func load(location: Location, delayed: Bool) async {
    
        guard loaded == false, loading == false else { return }
        
        DebugLog.log("--- load forecast for: \(location.name)")
        
        self.location = location
        loading = true
        
        do {
            forecast = try await Fetcher.forecast(location: location).fetch()
            loading = false
            lastLoad = Date()
            
            if delayed {
                try await Task.sleep(for: .seconds(0.3))
                DebugLog.log("+++ loaded delayed forecast for: \(location.name)")
                loaded = true
            } else {
                DebugLog.log("+++ loaded forecast for: \(location.name)")
                loaded = true
            }
        } catch {
            DebugLog.log("--- error loading forecast: " + error.localizedDescription)
        }
    }
    
    @objc func refreshIfNeeded() {
        guard needsRefresh else { return }
        loaded = false
        loading = false
        days = nil
    }
    
    var needsRefresh: Bool {
        if loaded, Calendar.current.isDate(Date(), equalTo: lastLoad, toGranularity: .day) == false {
            DebugLog.log("--- refresh needed: \(location?.name ?? "")")
            return true
        }

        return false
    }
}

//
//  ForecastView.swift
//  Rizz
//
//  Created by Tamas Bara on 04.04.24.
//

import SwiftUI

struct ForecastView: View {
    
    let firstView: Bool
    let location: Location
    private let locationViewModel = LocationViewModel()
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(ViewModel.self) private var viewModel: ViewModel
    @Environment(\.colorTheme) var colorTheme
    
    var body: some View {
        if locationViewModel.loaded == false {
            ProgressView()
                .foregroundStyle(.white)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0))
                .task {
                    await locationViewModel.load(location: location, delayed: firstView == false)
                }
        } else {
            List {
                ForEach(locationViewModel.days ?? [], id: \.self) { day in
                    DayView(day: day)
                        .listRowSeparator(.hidden)
                        .listRowBackground(colorTheme.background)
                        .listRowInsets(.init(top: day.isToday ? 0 : 30, leading: 0, bottom: 0, trailing: 0))
                        .environment(locationViewModel)
                }
            }
            .listStyle(.plain)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct DayView: View {
    
    let day: Day
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.colorTheme) var colorTheme
    
    var body: some View {
        ScrollViewReader { value in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    Text(day.name)
                        .foregroundStyle(colorTheme.dayText)
                        .font(.headline)
                        .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                        .background(RoundedRectangle(cornerRadius: 12).fill().foregroundColor(colorTheme.day))
                        .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10))
                    
                    if let sunrise = day.sunrise.first {
                        HStack(spacing: 6) {
                            Image(systemName: "sunrise")
                            Text(sunrise)
                                .font(.subheadline)
                        }
                        .foregroundStyle(colorTheme.text)
                    }
                    
                    if let sunset = day.sunrise[safeIndex: 1] {
                        HStack(spacing: 6) {
                            Image(systemName: "sunset")
                            Text(sunset)
                                .font(.subheadline)
                        }
                        .foregroundStyle(colorTheme.text)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorTheme.dayBackground)
                
                HStack(spacing: 10) {
                    ForEach(day.info, id: \.self) { info in
                        Text(info)
                            .font(.subheadline)
                            .foregroundStyle(colorTheme.text)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 0))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 40) {
                        ForEach(day.forecasts, id: \.self) { forecast in
                            HourView(forecast: forecast)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 26))
                }
            }
            .foregroundStyle(.white)
        }
    }
}

struct HourView: View {
    
    let forecast: Forecast
    @Environment(\.colorTheme) var colorTheme
    
    var body: some View {
        if let url = forecast.iconUrl {
            VStack(spacing: 10) {
                Text(forecast.time)
                    .font(.title3).bold()
                    .offset(x: -20)
                
                HStack(spacing: 30) {
                    AsyncImage(url: url)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .offset(y: -10)
                    
                    Text(forecast.text)
                }
            }
            .foregroundStyle(colorTheme.text)
        }
    }
}

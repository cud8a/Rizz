//
//  ContentView.swift
//  Rizz
//
//  Created by Tamas Bara on 02.10.24.
//

import SwiftUI

private struct ColorThemeKey: EnvironmentKey {
    static let defaultValue: ColorTheme = .init(theme: .deflt)
}

extension EnvironmentValues {
    var colorTheme: ColorTheme {
        get { self[ColorThemeKey.self] }
        set { self[ColorThemeKey.self] = newValue }
    }
}

struct LoadedView: View {
    
    let locations: [Location]
    @Environment(ViewModel.self) private var viewModel: ViewModel
    @State var selected: Location?
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(locations: locations, selected: $selected)
            
            Color(.white)
                .frame(height: 0.5)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            TabView(selection: $selected) {
                ForEach(locations, id: \.self) { location in
                    ForecastView(firstView: locations.first == location, location: location)
                        .tag(location)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear() {
            if selected == nil {
                selected = locations.first
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(ViewModel.self) private var viewModel: ViewModel
    
    @State var colorTheme: ColorTheme = ColorTheme(theme: .deflt)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background", bundle: nil)
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 10, opaque: true)
                
                VStack {
                    HStack {
                        Text("powered by OpenWeather")
                            .font(.footnote)
                            .foregroundColor(colorTheme.text)
                        
                        Spacer()
                        
                        NavigationLink(destination: SettingsView(selectedTheme: $colorTheme, locations: viewModel.locations ?? [])) {
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                                .foregroundStyle(colorTheme.text)
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
                    
                    if viewModel.loaded == false {
                        ProgressView()
                            .foregroundStyle(.white)
                            .frame(maxHeight: .infinity)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0))
                    } else {
                        LoadedView(locations: viewModel.locations ?? [])
                            .environment(\.colorTheme, colorTheme)
                    }
                }
                .background(colorTheme.background)
            }
            .frame(maxHeight: .infinity)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    NotificationCenter.default.post(name: Notification.Name("refreshIfNeeded"), object: nil)
                } else if newPhase == .background {
                    DebugLog.log("--------------------------------------")
                }
            }
        }
    }
}

struct HeaderView: View {
    
    let locations: [Location]
    @Binding var selected: Location?
    @Environment(\.colorTheme) var colorTheme
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(locations, id: \.self) { location in
                        if location == selected {
                            Text(location.name)
                                .foregroundColor(colorTheme.text)
                                .font(.title).bold()
                                .padding(EdgeInsets(top: 0, leading: location.name == locations.first?.name ? 0 : 10, bottom: 0, trailing: 10))
                                .id(location)
                        } else {
                            Button {
                                selected = location
                            } label: {
                                Text(location.name)
                                    .foregroundColor(colorTheme.text)
                                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 3, trailing: 8))
                                    .id(location)
                            }
                        }
                    }
                    
                    Spacer().frame(minWidth: 20).id("_tail")
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .scrollIndicators(.hidden)
            .animation(.easeIn, value: selected)
            .onChange(of: selected) {
                DebugLog.log("--- onChange: \(selected!)")
                value.scrollTo(selected, anchor: .center)
            }
        }
    }
}

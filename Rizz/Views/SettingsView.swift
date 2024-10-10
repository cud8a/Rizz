//
//  SettingsView.swift
//  Rizz
//
//  Created by Tamas Bara on 03.10.24.
//

import SwiftUI

struct SettingsView: View {
 
    @State private var showingSheetSearch = false
    @State private var showingSheetDebugLog = false
    @Binding var selectedTheme: ColorTheme
    @Environment(\.isPresented) var isPresented
    @Environment(ViewModel.self) private var viewModel: ViewModel
    @State var locations: [Location]
    
    var body: some View {
        NavigationStack {
            Form {
                Picker(
                    selection: $selectedTheme,
                    label: Text("Farbthema")
                ) {
                    ForEach(viewModel.colorThemes ?? [], id: \.self) {
                        Text($0.name)
                    }
                }
                
                Section("Orte") {
                    List {
                        ForEach(locations, id: \.self) { location in
                            Text(location.name)
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                locations.remove(at: index)
                            }
                        }
                        .onMove { from, to in
                            locations.move(fromOffsets: from, toOffset: to)
                        }
                    }
                }
                
                Button("Ort hinzufügen") {
                    showingSheetSearch.toggle()
                }
                
                Section("Debug") {
                    Button("Log anzeigen") {
                        showingSheetDebugLog.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingSheetSearch) {
                SheetViewSearch(locations: $locations)
            }
            .sheet(isPresented: $showingSheetDebugLog) {
                SheetViewDebugLog()
                    .interactiveDismissDisabled()
            }
            .navigationBarTitle("Einstellungen")
        }
        .onChange(of: isPresented) { _, isPresented in
            if isPresented == false, locations != viewModel.locations {
                viewModel.update(locations: locations)
            }
        }
    }
}

struct SheetViewSearch: View {
    
    @Binding var locations: [Location]
    @State private var search: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus
    @State private var loading = false
    @State private var results: LocationResponse?
    @State private var noResults = false
    
    private var textBackground: Color {
        colorScheme == .dark ? .white : Color(.init(hex: 0xf2f2f2))
    }
    
    private var listBackground: Color {
        colorScheme == .dark ? Color(.init(hex: 0x3c3c3e)) : Color(.init(hex: 0xf2f2f2))
    }
    
    private func listRowInsets(forResult result: Feature) -> EdgeInsets {
        if results?.filtered.first == result {
            EdgeInsets(top: 18, leading: 20, bottom: 14, trailing: 20)
        } else if results?.filtered.last == result {
            EdgeInsets(top: 14, leading: 20, bottom: 18, trailing: 20)
        } else {
            EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("Ort: ")
                            
                            TextField("", text: $search)
                                .autocorrectionDisabled()
                                .foregroundStyle(.black)
                                .focused($focus)
                                .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(textBackground)
                                }
                        }
                        .task {
                            focus = true
                        }
                        
                        Button {
                            if search.count > 2 {
                                results = nil
                                focus.toggle()
                                loading.toggle()
                                Task {
                                    do {
                                        results = try await Fetcher.location(name: search).fetch()
                                        loading = false
                                        noResults = results?.features.count == 0
                                    } catch {
                                        DebugLog.log("--- error: \(error)")
                                    }
                                }
                            }
                        } label: {
                            Text("Suchen")
                        }
                        .foregroundStyle(.blue)
                        
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 16))
                    
                    if let results, results.features.count > 0 {
                        List(results.filtered, id: \.self) { feature in
                            HStack(spacing: 6) {
                                Text(feature.properties.info)
                                Spacer()
                                Button {
                                    if let name = feature.properties.name ?? feature.properties.city, locations.first(where: { $0.name == name }) == nil {
                                        locations.append(Location(lat: feature.properties.lat, lon: feature.properties.lon, name: name))
                                    }
                                    
                                    dismiss()
                                } label: {
                                    Text("Hinzufügen")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .listRowInsets(listRowInsets(forResult: feature))
                            .listRowBackground(listBackground)
                        }
                        .scrollContentBackground(.hidden)
                    } else if noResults {
                        Text("Dieser Ort existiert leider nicht.")
                            .pinLeft()
                            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .background() {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(listBackground)
                            }
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    }
                    
                    Spacer()
                }
                
                if loading {
                    ProgressView()
                }
            }
            .frame(maxHeight: .infinity)
            .navigationBarTitle("Ort hinzufügen")
        }
    }
}

struct SheetViewDebugLog: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Text("Schließen")
                    .foregroundStyle(.blue)
            }
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10))
            .pinRight()
            
            ScrollView {
                Text(DebugLog.log)
            }
        }
    }
}

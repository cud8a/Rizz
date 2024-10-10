//
//  RizzApp.swift
//  Rizz
//
//  Created by Tamas Bara on 09.10.24.
//

import SwiftUI
import Bagel

@main
struct RizzApp: App {
    
    private let viewModel = ViewModel()
    
    init() {
#if targetEnvironment(simulator)
        Bagel.start()
#endif
        Task { [weak viewModel] in
            await viewModel?.load()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}

//
//  ContentView.swift
//  Auri 02
//
//  Created by Justin Oliak on 3/20/25.
//

import SwiftUI

struct ContentView: View {
    // Support both types of environment access
    @Environment(\.sessionManager) private var envSessionManager
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            await MainActor.run {
                                showSplash = false
                            }
                        }
                    }
            } else {
                #if DEBUG
                // Debug mode - use mock data with consistent injection
                let container = MockData.createMockContainer()
                MainTabView()
                    .inject(container)
                #else
                // Release mode - handle real auth flow
                if sessionManager.isAuthenticated {  // Use the @EnvironmentObject version
                    MainTabView()
                        .inject(DIContainer.preview())
                } else {
                    AuthView()
                }
                #endif
            }
        }
    }
}

#Preview {
    let container = MockData.createMockContainer()
    return ContentView()
        .inject(container)
        .preferredColorScheme(.dark)
}

// MARK: - Tab Items Configuration
enum TabItem: Int, CaseIterable {
    case home, ai, analysis
    
    var icon: String {
        switch self {
        case .home: "circle.hexagongrid.fill"
        case .ai: "sparkles.square.fill.on.square"
        case .analysis: "waveform.path.ecg.rectangle"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomeView()
        case .ai: AIContentView()
        case .analysis: AnalysisView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                tab.view
                    .tabItem {
                        Image(systemName: tab.icon)
                    }
                    .tag(tab.rawValue)
            }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// End of file

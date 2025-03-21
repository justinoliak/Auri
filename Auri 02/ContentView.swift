//
//  ContentView.swift
//  Auri 02
//
//  Created by Justin Oliak on 3/20/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(SessionManager.self) private var sessionManager
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
            } else if sessionManager.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SessionManager())
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

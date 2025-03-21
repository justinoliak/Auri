//
//  ContentView.swift
//  Auri 02
//
//  Created by Justin Oliak on 3/20/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "circle.hexagongrid.fill")
                }
                .tag(0)
            
            AIContentView()
                .tabItem {
                    Image(systemName: "sparkles.square.fill.on.square")
                }
                .tag(1)
            
            AnalysisView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg.rectangle")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
        .tint(.white)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
}

// End of file

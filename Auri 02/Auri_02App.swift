//
//  Auri_02App.swift
//  Auri 02
//
//  Created by Justin Oliak on 3/20/25.
//

import SwiftUI
import os

@main
struct Auri_02App: App {
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "App")
    
    @StateObject private var sessionManager = SessionManager()
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isInitialized {
                    SplashView()
                        .environmentObject(sessionManager)
                } else {
                    Color.black
                        .ignoresSafeArea()
                        .overlay(
                            Text("Loading...")
                                .foregroundColor(.white)
                        )
                }
            }
            .task {
                if !isInitialized {
                    logger.debug("Initializing app...")
                    isInitialized = true
                    logger.debug("App initialization completed")
                }
            }
        }
    }
}

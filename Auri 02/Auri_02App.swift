//
//  Auri_02App.swift
//  Auri 02
//
//  Created by Justin Oliak on 3/20/25.
//

import SwiftUI

@main
struct Auri_02App: App {
    @State private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(sessionManager)
        }
    }
}

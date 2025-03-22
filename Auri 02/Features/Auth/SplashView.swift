import SwiftUI
import os

struct SplashView: View {
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "SplashView")
    
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        ZStack {
            Theme.backgroundPrimary.ignoresSafeArea()
            
            Text("AURI")
                .font(Theme.newYorkHeadline(40))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.8), radius: 2)
        }
        .onAppear {
            logger.debug("SplashView appeared")
        }
    }
}

#Preview {
    SplashView()
        .environment(SessionManager())
}

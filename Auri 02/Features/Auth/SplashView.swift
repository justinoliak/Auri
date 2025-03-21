import SwiftUI

struct SplashView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Theme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Add WaveView with animation
                WaveView(isPressed: isAnimating)
                    .frame(width: 180, height: 180)
                
                Text("AURI")
                    .font(Theme.newYorkHeadline(40))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(SessionManager())
}

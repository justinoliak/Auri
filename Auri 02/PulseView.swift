import SwiftUI

struct PulseView: View {
    let isPressed: Bool
    
    @State private var pulseScale = 1.0
    @State private var opacity = 0.5
    @State private var phase = 0.0
    
    var body: some View {
        ZStack {
            // Multiple pulse layers with wave-like animation
            ForEach(0..<5) { index in
                Circle()
                    .stroke(Color.white.opacity(0.4 - Double(index) * 0.05), lineWidth: 2)
                    .scaleEffect(pulseScale + Double(index) * 0.1 + sin(phase + Double(index) * .pi / 2) * 0.1)
                    .opacity(opacity - Double(index) * 0.1)
            }
        }
        .frame(width: 120, height: 120)
        .scaleEffect(isPressed ? 1.3 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isPressed)
        .onAppear {
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
                opacity = 0.3
            }
            
            // Wave animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = 2 * .pi
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        PulseView(isPressed: false)
    }
}

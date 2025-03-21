import SwiftUI
import Foundation

struct WaveView: View {
    let isPressed: Bool
    
    @State private var rotationPhase = 0.0
    @State private var pulsePhase = 1.0
    @State private var glowOpacity = 0.0
    
    private var outerGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.7),
                Color.pink.opacity(0.6),
                Color.blue.opacity(0.8)
            ]),
            center: .center,
            startAngle: .degrees(rotationPhase),
            endAngle: .degrees(rotationPhase + 360)
        )
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .blur(radius: isPressed ? 40 : 30)
                    .opacity(isPressed ? 0.3 : 0.15)
                    .scaleEffect(isPressed ? 1.3 : 1.1)
                
                Circle()
                    .fill(Color.purple)
                    .blur(radius: isPressed ? 50 : 40)
                    .opacity(isPressed ? 0.2 : 0.1)
                    .scaleEffect(isPressed ? 1.4 : 1.2)
                
                Circle()
                    .fill(Color.pink)
                    .blur(radius: isPressed ? 45 : 35)
                    .opacity(isPressed ? 0.15 : 0.08)
                    .scaleEffect(isPressed ? 1.35 : 1.15)
                
                Circle()
                    .strokeBorder(outerGradient, lineWidth: 3)
                    .scaleEffect(pulsePhase)
                    .opacity(isPressed ? 0.8 : 0.6)
                
                ForEach(0..<2) { index in
                    Circle()
                        .strokeBorder(outerGradient, lineWidth: 2)
                        .scaleEffect(isPressed ? 1.0 + Double(index) * 0.4 : 1.0 + Double(index) * 0.3)
                        .opacity(isPressed ? 0.6 - Double(index) * 0.2 : 0.5 - Double(index) * 0.15)
                        .animation(
                            .easeInOut(duration: isPressed ? 1.0 : 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.4),
                            value: isPressed
                        )
                }
            }
            .frame(width: 180, height: 180)
            .onChange(of: isPressed) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulsePhase = newValue ? 1.15 : 1.05
                    glowOpacity = newValue ? 0.5 : 0.2
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotationPhase = 360
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        WaveView(isPressed: false)
    }
    .preferredColorScheme(.dark)
}

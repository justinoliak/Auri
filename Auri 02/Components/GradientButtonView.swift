import SwiftUI

struct GradientButtonView: View {
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    @State private var rotation = 0.0
    
    private var gradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.blue.opacity(0.6),
                                      .purple.opacity(0.5),
                                      .blue.opacity(0.6)]),
            center: .center,
            startAngle: .degrees(rotation),
            endAngle: .degrees(rotation + 360)
        )
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(gradient, lineWidth: 3)
                .frame(width: 120, height: 120)
            
            ForEach(0..<5) { index in
                Circle()
                    .strokeBorder(gradient, lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(isPressed ? 1.0 + Double(index) * 0.3 : 1.0)
                    .opacity(isPressed ? 0.4 - Double(index) * 0.1 : 0)
            }
            .animation(.easeInOut(duration: 0.5), value: isPressed)
            
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Theme.backgroundSecondary)
                .clipShape(Circle())
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onLongPress()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ZStack {
        Color.black
        GradientButtonView(
            onTap: { print("Tapped") },
            onLongPress: { print("Long pressed") }
        )
    }
}

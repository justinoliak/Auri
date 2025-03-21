import SwiftUI

// Emotion bubble data structure
struct EmotionBubble: Identifiable {
    let id = UUID()
    let emotion: String
    let frequency: Int
    var position: CGPoint
    var color: Color
    
    var size: CGFloat {
        // More dramatic size differences
        let baseSize: CGFloat = 45
        let scaleFactor = log(CGFloat(frequency + 1)) * 25
        return baseSize + scaleFactor
    }
    
    func overlapsWith(_ other: EmotionBubble) -> Bool {
        let dx = position.x - other.position.x
        let dy = position.y - other.position.y
        let distance = sqrt(dx * dx + dy * dy)
        return distance < (size + other.size) / 2
    }
}

struct BubbleView: View {
    let bubble: EmotionBubble
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Background with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bubble.color.opacity(0.2),
                            bubble.color.opacity(0.15)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: bubble.size/2
                    )
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            bubble.color.opacity(0.6),
                            lineWidth: bubble.size > 60 ? 2 : 1.5
                        )
                )
            
            VStack(spacing: 2) {
                Text(bubble.emotion)
                    .font(Theme.newYorkHeadline(min(bubble.size * 0.22, 14)))
                    .foregroundColor(.white)
                Text("\(bubble.frequency)")
                    .font(Theme.sfProText(min(bubble.size * 0.18, 12)))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: bubble.size, height: bubble.size)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct BubbleMapView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var selectedBubbleId: UUID?
    
    let bubbles: [EmotionBubble]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(bubbles) { bubble in
                    BubbleView(
                        bubble: bubble,
                        isSelected: selectedBubbleId == bubble.id
                    )
                    .position(
                        x: bubble.position.x * scale + offset.width + geometry.size.width / 2,
                        y: bubble.position.y * scale + offset.height + geometry.size.height / 2
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedBubbleId = selectedBubbleId == bubble.id ? nil : bubble.id
                        }
                    }
                }
            }
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        },
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
        }
    }
}

struct AnalysisView: View {
    @State private var selectedFilter: String = "All Entries"
    
    private let sampleBubbles: [EmotionBubble] = {
        let emotionsData: [(String, Int)] = [
            ("Happy", 18), ("Excited", 8), ("Calm", 15),
            ("Anxious", 6), ("Focused", 25), ("Tired", 4),
            ("Grateful", 12), ("Stressed", 7), ("Peaceful", 9),
            ("Inspired", 11), ("Creative", 14), ("Motivated", 20)
        ]
        
        let colors: [Color] = [.blue, .purple, .pink, .green, .orange, .teal]
        
        // Sort emotions by frequency (largest first)
        let sortedEmotions = emotionsData.sorted { $0.1 > $1.1 }
        var bubbles: [EmotionBubble] = []
        
        // Place bubbles with collision detection
        for (index, (emotion, frequency)) in sortedEmotions.enumerated() {
            var placed = false
            var radius = 60.0
            var angle = Double(index) * .pi * 0.5
            
            // Try to find a non-overlapping position
            while !placed {
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                
                let newBubble = EmotionBubble(
                    emotion: emotion,
                    frequency: frequency,
                    position: CGPoint(x: x, y: y),
                    color: colors[index % colors.count]
                )
                
                // Check if this position overlaps with any existing bubbles
                if !bubbles.contains(where: { newBubble.overlapsWith($0) }) {
                    bubbles.append(newBubble)
                    placed = true
                } else {
                    // Try next position
                    angle += 0.3
                    if angle >= .pi * 2 {
                        angle = 0
                        radius += 30
                    }
                }
            }
        }
        
        return bubbles
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("March 2025")
                            .font(Theme.newYorkHeadline(20))
                            .foregroundColor(.white)
                        Spacer()
                        Menu(selectedFilter) {
                            Button("All Entries") { selectedFilter = "All Entries" }
                            Button("Positive") { selectedFilter = "Positive" }
                            Button("Negative") { selectedFilter = "Negative" }
                        }
                    }
                    .padding(.horizontal)
                    
                    BubbleMapView(bubbles: sampleBubbles)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Analysis")
                        .font(Theme.newYorkHeadline(20))
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AnalysisView()
}

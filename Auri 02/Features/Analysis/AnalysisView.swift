import SwiftUI
import Combine
import os

// Emotion bubble data structure
struct EmotionBubble: Identifiable, Equatable {
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
    
    // Add Equatable conformance
    static func == (lhs: EmotionBubble, rhs: EmotionBubble) -> Bool {
        lhs.id == rhs.id
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

actor BubbleLayoutEngine {
    func calculatePositions(for bubbles: [EmotionBubble]) async -> [EmotionBubble] {
        var result = [EmotionBubble]()
        
        for var bubble in bubbles.sorted(by: { $0.frequency > $1.frequency }) {
            var placed = false
            var radius = 60.0
            var angle = Double(result.count) * .pi * 0.5
            
            while !placed {
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                bubble.position = CGPoint(x: x, y: y)
                
                if !result.contains(where: { bubble.overlapsWith($0) }) {
                    result.append(bubble)
                    placed = true
                } else {
                    angle += 0.3
                    if angle >= .pi * 2 {
                        angle = 0
                        radius += 30
                    }
                }
            }
        }
        
        return result
    }
}

struct BubbleMapView: View {
    let bubbles: [EmotionBubble]
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var selectedBubbleId: UUID?
    @State private var displayedBubbles: [EmotionBubble] = []
    
    private let layoutEngine = BubbleLayoutEngine()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(displayedBubbles) { bubble in
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
        .task {
            displayedBubbles = await layoutEngine.calculatePositions(for: bubbles)
        }
        .onChange(of: bubbles) { _, newBubbles in
            Task {
                displayedBubbles = await layoutEngine.calculatePositions(for: newBubbles)
            }
        }
    }
}

@Observable
class AnalysisViewModel {
    private let journalService: JournalServiceProtocol
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "AnalysisViewModel")
    
    var emotions: [EmotionBubble] = []
    var isLoading = false
    var selectedFilter = "All Entries"
    
    init(journalService: JournalServiceProtocol) {
        self.journalService = journalService
    }
    
    func loadEmotions() async {
        isLoading = true
        defer { isLoading = false }
        
        // Mock data for now
        let mockEmotions = [
            "Joy": 10,
            "Sadness": 5,
            "Anger": 3,
            "Fear": 2,
            "Surprise": 4,
            "Love": 8,
            "Anxiety": 6
        ]
        
        emotions = mockEmotions.map { emotion in
            EmotionBubble(
                emotion: emotion.key,
                frequency: emotion.value,
                position: .zero,
                color: Theme.randomGradientColor
            )
        }
    }
}

struct AnalysisView: View {
    @State private var viewModel: AnalysisViewModel
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "AnalysisView")
    
    init(viewModel: AnalysisViewModel? = nil) {
        let vm = viewModel ?? AnalysisViewModel(
            journalService: MockJournalService()
        )
        _viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    AnalysisHeaderView(selectedFilter: $viewModel.selectedFilter)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        BubbleMapView(bubbles: viewModel.emotions)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                    }
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
            .task {
                logger.debug("Loading emotions")
                await viewModel.loadEmotions()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct AnalysisHeaderView: View {
    @Binding var selectedFilter: String
    
    var body: some View {
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
    }
}

#Preview {
    AnalysisView(viewModel: AnalysisViewModel(
        journalService: MockJournalService()
    ))
}

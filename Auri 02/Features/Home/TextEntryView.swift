import SwiftUI

// MARK: - View Model
@Observable final class TextEntryViewModel {
    private let container: ServiceContainer
    
    var journalText: String = ""
    var analysisText: String?
    var isGeneratingAnalysis = false
    
    init(container: ServiceContainer) {
        self.container = container
    }
    
    @MainActor
    func generateAnalysis() async {
        isGeneratingAnalysis = true
        
        do {
            analysisText = try await container.aiService.generateAnalysis(for: journalText)
        } catch {
            container.errorHandler.handle(error)
        }
        
        isGeneratingAnalysis = false
    }
    
    func saveEntry() {
        // Implementation
    }
}

// MARK: - Main View
struct TextEntryView: View {
    @Bindable private var viewModel: TextEntryViewModel
    @Binding var isPresented: Bool
    let namespace: Namespace.ID
    
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var topBarOffset: CGFloat = -20
    @State private var textEditorScale: CGFloat = 0.95
    @State private var showingAnalysis = false
    
    init(
        isPresented: Binding<Bool>,
        namespace: Namespace.ID,
        container: ServiceContainer
    ) {
        self._isPresented = isPresented
        self.namespace = namespace
        self.viewModel = TextEntryViewModel(container: container)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundPrimary
                .matchedGeometryEffect(id: "background", in: namespace)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TopBarView(
                    showContent: $showContent,
                    topBarOffset: $topBarOffset,
                    textEditorScale: $textEditorScale,
                    isPresented: $isPresented,
                    canSave: !viewModel.journalText.isEmpty,
                    onSave: viewModel.saveEntry
                )
                
                JournalEditorView(
                    text: $viewModel.journalText,
                    showContent: showContent,
                    textEditorScale: textEditorScale
                )
                
                if showingAnalysis {
                    AIAnalysisView(analysisText: viewModel.analysisText)
                        .transition(.scale.combined(with: .opacity))
                }
                
                AIInsightsButton(
                    isGenerating: viewModel.isGeneratingAnalysis,
                    isEnabled: !viewModel.journalText.isEmpty
                ) {
                    Task {
                        await viewModel.generateAnalysis()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingAnalysis = true
                        }
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
                topBarOffset = 0
                textEditorScale = 1
            }
        }
    }
}

// MARK: - Supporting Views
private struct TopBarView: View {
    @Binding var showContent: Bool
    @Binding var topBarOffset: CGFloat
    @Binding var textEditorScale: CGFloat
    @Binding var isPresented: Bool
    let canSave: Bool
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            CloseButton(
                showContent: $showContent,
                topBarOffset: $topBarOffset,
                textEditorScale: $textEditorScale,
                isPresented: $isPresented
            )
            
            Spacer()
            
            Button("Save") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContent = false
                    topBarOffset = -20
                    textEditorScale = 0.95
                }
                onSave()
            }
            .buttonStyle(SaveButtonStyle())
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
        }
        .offset(y: topBarOffset)
        .opacity(showContent ? 1 : 0)
    }
}

private struct JournalEditorView: View {
    @Binding var text: String
    let showContent: Bool
    let textEditorScale: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(maxHeight: .infinity)
                .padding()
                .foregroundColor(.white)
                .font(Theme.sfProText(16))
                .scrollContentBackground(.hidden)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(textEditorScale)
            
            if text.isEmpty {
                Text("What's on your mind?")
                    .font(Theme.newYorkHeadline(18))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.leading, 20)
                    .padding(.top, 24)
            }
        }
    }
}

private struct AIAnalysisView: View {
    let analysisText: String?
    
    var body: some View {
        if let analysis = analysisText {
            Text(analysis)
                .font(Theme.newYorkHeadline(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

private struct CloseButton: View {
    @Binding var showContent: Bool
    @Binding var topBarOffset: CGFloat
    @Binding var textEditorScale: CGFloat
    @Binding var isPresented: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = false
                topBarOffset = -20
                textEditorScale = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct AIInsightsButton: View {
    let isGenerating: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(isGenerating ? "Analyzing..." : "AI Insights")
                    .font(Theme.newYorkHeadline(16))
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(!isEnabled || isGenerating)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Button Styles
private struct SaveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.newYorkHeadline(16))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

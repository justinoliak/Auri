import SwiftUI
import os

struct HomeView: View {
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "HomeView")
    
    @Environment(\.container) private var container: DIContainer?
    @Environment(SessionManager.self) private var sessionManager
    
    // MARK: - View State
    @State private var viewState = ViewState()
    
    private let transitionDuration: Double = 0.4
    
    struct ViewState {
        var showingProfile = false
        var showTextEntry = false
        var isRecording = false
        var showingError = false
        var error: Error?
        var textEntryTransition = false
    }
    
    // MARK: - Computed Properties
    private var currentDateString: String {
        Date().formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
        )
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var headerView: some View {
        if !viewState.showTextEntry {
            HomeHeaderView(
                date: currentDateString,
                onProfileTap: {
                    withAnimation(.easeIn) {
                        viewState.showingProfile.toggle()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var auraSection: some View {
        if !viewState.showTextEntry {
            VStack {
                AuraView(
                    onTap: {
                        withAnimation(.easeInOut(duration: transitionDuration)) {
                            viewState.showTextEntry = true
                            viewState.textEntryTransition = true
                        }
                    },
                    onRecordingChange: { isRecording in
                        if isRecording {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        viewState.isRecording = isRecording
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 260)
                .shadow(color: .black.opacity(0.2), radius: 10)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var entriesView: some View {
        if let container = container {
            EntriesListView(
                entries: container.journalService.entries,
                firstEntryAnalysis: container.journalService.entries.first?.analysis
            )
        }
    }
    
    @ViewBuilder
    private var textEntryOverlay: some View {
        if let container = container {
            Color.black
                .opacity(viewState.textEntryTransition ? 0.5 : 0)
                .ignoresSafeArea()
                .transition(.opacity.animation(.easeInOut(duration: transitionDuration)))
            
            TextEntryView(
                isPresented: $viewState.showTextEntry,
                container: container
            )
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        headerView
                        auraSection
                        entriesView
                    }
                    .padding(.top, 20)
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .edgesIgnoringSafeArea(.top)
                
                if viewState.showTextEntry {
                    textEntryOverlay
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewState.showingProfile) {
                if let container = container {
                    ProfileView(container: container)
                }
            }
            .alert("Error", isPresented: $viewState.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewState.error?.localizedDescription ?? "An error occurred")
            }
            .task {
                do {
                    try await loadEntries()
                } catch {
                    viewState.error = error
                    viewState.showingError = true
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: viewState.showTextEntry) { _, isShowing in
            if !isShowing {
                withAnimation(.easeInOut(duration: transitionDuration)) {
                    viewState.textEntryTransition = false
                }
            }
        }
    }
    
    private func loadEntries() async throws {
        guard let userId = sessionManager.currentUser?.id.uuidString else {
            throw AuthError.userNotFound
        }
        
        guard let container = container else {
            throw AppError.service(.unknown(NSError(domain: "DIContainer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Container not initialized"])))
        }
        
        await container.journalService.fetchEntries(userId: userId)
    }
}

// MARK: - Supporting Views
private struct HomeHeaderView: View {
    let date: String
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            Text(date)
                .font(Theme.newYorkHeadline(20))
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onProfileTap) {
                Image(systemName: "person.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 24)
        .transition(.opacity)
    }
}

private struct EntriesListView: View {
    let entries: [JournalEntry]
    let firstEntryAnalysis: String?
    
    var body: some View {
        VStack(spacing: 24) {
            MoodCard(
                mood: "Today's Mood",
                description: firstEntryAnalysis ?? "Share how you're feeling..."
            )
            .frame(minHeight: 100)
            .shadow(color: .black.opacity(0.1), radius: 5)
            
            ForEach(entries.prefix(3)) { entry in
                EntryCard(
                    title: entry.createdAt.formatted(date: .abbreviated, time: .shortened),
                    content: entry.text
                )
                .frame(minHeight: 80)
            }
            
            if entries.isEmpty {
                ForEach(0..<2) { _ in
                    EntryCard(
                        title: "New Entry",
                        content: "Tap the aura to start journaling..."
                    )
                    .opacity(0.5)
                }
            }
            
            Color.clear.frame(height: 40)
        }
        .padding(.horizontal)
        .transition(.opacity)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer.preview()
        HomeView()
            .inject(container)
    }
}

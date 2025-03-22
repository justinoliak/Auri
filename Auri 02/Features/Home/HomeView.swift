import SwiftUI
import os

struct HomeView: View {
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "HomeView")
    
    @Environment(\.container) private var container: DIContainer?
    @Environment(SessionManager.self) private var sessionManager
    @State private var showingProfile = false
    @State private var showTextEntry = false
    @State private var isRecording = false
    @State private var showingError = false
    @State private var showContent = false
    
    @Namespace private var animation
    @Namespace private var namespace
    @State private var textEntryTransition = false
    
    private var currentDateString: String {
        Date().formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        HStack {
                            Text(currentDateString)
                                .font(Theme.newYorkHeadline(20))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeIn) {
                                    showingProfile.toggle()
                                }
                            } label: {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)
                        .padding(.bottom, 24)
                        .opacity(showTextEntry ? 0 : 1)
                        .offset(y: showTextEntry ? -20 : 0)
                        
                        VStack {
                            if !showTextEntry {
                                AuraView(
                                    onTap: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showTextEntry = true
                                            // Delay the transition animation slightly
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                    textEntryTransition = true
                                                }
                                            }
                                        }
                                    },
                                    onRecordingChange: { isRecording in
                                        if isRecording {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                        self.isRecording = isRecording
                                    }
                                )
                                .matchedGeometryEffect(id: "textEntry", in: animation)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 260)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        
                        VStack(spacing: 24) {
                            MoodCard(
                                mood: "Today's Mood",
                                description: container?.journalService.entries.first?.analysis ?? "Share how you're feeling..."
                            )
                            .frame(minHeight: 100)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            
                            ForEach(container?.journalService.entries.prefix(3) ?? [], id: \.id) { entry in
                                EntryCard(
                                    title: entry.createdAt.formatted(date: .abbreviated, time: .shortened),
                                    content: entry.text
                                )
                                .frame(minHeight: 80)
                            }
                            
                            if container?.journalService.entries.isEmpty ?? true {
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
                        .opacity(showTextEntry ? 0 : 1)
                        .offset(y: showTextEntry ? 100 : 0)
                    }
                    .padding(.top, 20)
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .edgesIgnoringSafeArea(.top)
                
                // Background overlay when text entry is shown
                if showTextEntry {
                    Color.black
                        .opacity(textEntryTransition ? 0.5 : 0)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                // Text entry view with animation
                if showTextEntry {
                    GeometryReader { geometry in
                        if let container = container {
                            TextEntryView(
                                isPresented: $showTextEntry,
                                namespace: animation,
                                container: container
                            )
                            .matchedGeometryEffect(id: "textEntry", in: animation)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(y: textEntryTransition ? 0 : geometry.size.height)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity.combined(with: .move(edge: .bottom))
                                )
                            )
                            .zIndex(1)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingProfile) {
                if let container = container {
                    NavigationStack {
                        ProfileView(container: container)
                    }
                    .preferredColorScheme(.dark)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTextEntry)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(container?.journalService.error ?? "An error occurred")
            }
            .task {
                await loadEntries()
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: showTextEntry) { _, isShowing in
            if !isShowing {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    textEntryTransition = false
                }
            }
        }
    }
    
    private func loadEntries() async {
        guard let container = container,
              let userId = sessionManager.currentUser?.id.uuidString else {
            return
        }
        
        await container.journalService.fetchEntries(userId: userId)
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

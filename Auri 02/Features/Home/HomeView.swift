import SwiftUI

struct HomeView: View {
    @State private var journalText = ""
    @State private var showingProfile = false
    @State private var showingTextEntry = false
    @State private var isRecording = false
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        Color.clear
                            .frame(height: 60)
                        
                        AuraView(
                            onTap: { showingTextEntry = true },
                            onRecordingChange: { isRecording in
                                if isRecording {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                                self.isRecording = isRecording
                            }
                        )
                        .frame(height: 260)
                        .padding(.bottom, 40)
                        
                        VStack(spacing: 20) {
                            MoodCard(
                                mood: "Today's Mood",
                                description: "Based on your entries, you seem focused and optimistic"
                            )
                            .frame(height: 100)
                            
                            ForEach(0..<3) { index in
                                EntryCard(
                                    title: "Previous Entry",
                                    content: "Your past journal entries will appear here..."
                                )
                                .frame(height: 80)
                            }
                            
                            Color.clear.frame(height: 40)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(currentDateString)
                        .font(Theme.newYorkHeadline(20))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeIn) {
                            showingProfile.toggle()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingTextEntry) {
                NavigationView {
                    TextEntryView(journalText: $journalText, isPresented: $showingTextEntry)
                }
                .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - TextEntryView
struct TextEntryView: View {
    @Binding var journalText: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            TextEditor(text: $journalText)
                .frame(maxHeight: .infinity)
                .padding()
                .background(Theme.backgroundSecondary)
                .foregroundColor(.white)
                .cornerRadius(16)
                .font(Theme.sfProText(16))
                .padding()
        }
        .background(Theme.backgroundPrimary)
        .navigationTitle("New Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    isPresented = false
                }
            }
        }
        .transition(.identity)
    }
}

#Preview {
    HomeView()
}

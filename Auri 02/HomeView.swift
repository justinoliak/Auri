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
                            MoodCard()
                                .frame(height: 100)
                            
                            ForEach(0..<3) { index in
                                EntryCard()
                                    .frame(height: 80)
                            }
                            
                            Color.clear.frame(height: 40)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(currentDateString)
                        .font(Theme.newYorkHeadline(20))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
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

private struct MoodCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Mood")
                .font(Theme.newYorkHeadline(20))
                .foregroundColor(.white)
            Text("Based on your entries, you seem focused and optimistic")
                .font(Theme.sfProText(14))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.backgroundSecondary)
        .cornerRadius(16)
    }
}

private struct EntryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Previous Entry")
                .font(Theme.newYorkHeadline(16))
                .foregroundColor(.white)
            Text("Your past journal entries will appear here...")
                .font(Theme.sfProText(14))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.backgroundSecondary)
        .cornerRadius(16)
    }
}

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

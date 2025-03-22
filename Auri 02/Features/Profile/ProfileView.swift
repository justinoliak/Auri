import SwiftUI

@Observable @MainActor
final class ProfileViewModel {
    private let container: ServiceContainer
    private(set) var currentUserEmail: String?
    var notificationsEnabled = true
    var darkModeEnabled = true
    
    init(container: ServiceContainer) {
        self.container = container
    }
    
    func loadUserEmail() {
        currentUserEmail = container.sessionManager.currentUser?.email
    }
    
    func signOut() async {
        await container.sessionManager.signOut()
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ProfileViewModel
    
    init(container: ServiceContainer) {
        _viewModel = State(initialValue: ProfileViewModel(container: container))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let email = viewModel.currentUserEmail {
                    Text(email)
                        .font(Theme.sfProText(16))
                        .foregroundColor(.white)
                }
                
                Button("Sign Out") {
                    Task {
                        await viewModel.signOut()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarTitleItem()
                ToolbarDismissButton(dismiss: dismiss)
            }
        }
        .task {
            viewModel.loadUserEmail()
        }
    }
}

// MARK: - Supporting Views
private struct AccountSection: View {
    let email: String
    let onSignOut: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if !email.isEmpty {
                Text(email)
                    .foregroundColor(.white)
            }
            Button("Sign Out", action: onSignOut)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Theme.backgroundSecondary)
    }
}

private struct PreferencesSection: View {
    @Binding var notificationsEnabled: Bool
    @Binding var darkModeEnabled: Bool
    
    var body: some View {
        Group {
            Toggle("Notifications", isOn: $notificationsEnabled)
            Toggle("Dark Mode", isOn: $darkModeEnabled)
        }
        .tint(.white)
        .listRowBackground(Theme.backgroundSecondary)
    }
}

private struct AboutSection: View {
    var body: some View {
        Group {
            Text("Version 1.0")
            Text("Terms of Service")
            Text("Privacy Policy")
        }
        .listRowBackground(Theme.backgroundSecondary)
        .foregroundColor(.white)
    }
}

private struct SectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(Theme.newYorkHeadline(14))
            .foregroundColor(.white)
    }
}

private struct ToolbarTitleItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Profile")
                .font(Theme.newYorkHeadline(20))
                .foregroundColor(.white)
        }
    }
}

private struct ToolbarDismissButton: ToolbarContent {
    let dismiss: DismissAction
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ProfileView(container: DIContainer.preview())
        .preferredColorScheme(.dark)
}

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("email@example.com")
                        .foregroundColor(.white)
                    Button("Sign Out") {
                        // TODO: Implement sign out
                    }
                } header: {
                    Text("Account")
                        .font(Theme.newYorkHeadline(14))
                        .foregroundColor(.white)
                }
                
                Section {
                    Toggle("Notifications", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(false))
                } header: {
                    Text("Preferences")
                        .font(Theme.newYorkHeadline(14))
                        .foregroundColor(.white)
                }
                
                Section {
                    Text("Version 1.0")
                    Text("Terms of Service")
                    Text("Privacy Policy")
                } header: {
                    Text("About")
                        .font(Theme.newYorkHeadline(14))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(Theme.newYorkHeadline(20))
                        .foregroundColor(.white)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundPrimary)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView()
}

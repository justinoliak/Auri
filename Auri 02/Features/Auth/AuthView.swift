import SwiftUI

struct AuthView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Welcome to Auri")
                        .font(Theme.newYorkHeadline(32))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, 32)
                    
                    if sessionManager.needsEmailConfirmation {
                        Text("Please check your email to confirm your account")
                            .foregroundColor(.yellow)
                            .font(Theme.sfProText(14))
                    } else if let error = sessionManager.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(Theme.sfProText(14))
                    }
                    
                    Button(action: authenticate) {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(Theme.sfProText(16).bold())
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(10)
                    .disabled(email.isEmpty || password.isEmpty || isProcessing)
                    .padding(.horizontal, 32)
                    
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                            // Clear any errors when switching modes
                            sessionManager.error = nil
                            sessionManager.needsEmailConfirmation = false
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(Theme.sfProText(14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func authenticate() {
        guard !email.isEmpty, !password.isEmpty else {
            sessionManager.error = "Email and password cannot be empty"
            return
        }
        
        isProcessing = true
        
        Task {
            if isSignUp {
                await sessionManager.signUp(email: email, password: password)
            } else {
                await sessionManager.signIn(email: email, password: password)
            }
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(SessionManager())
}

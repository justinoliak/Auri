import SwiftUI

struct AuthView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var isProcessing = false
    @State private var rememberMe = false
    @State private var isPressed = false
    @State private var isSignIn: Bool
    
    init(isSignIn: Bool = false) {
        _isSignIn = State(initialValue: isSignIn)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(isSignIn ? "Welcome Back" : "Create Account")
                            .font(Theme.newYorkHeadline(32))
                            .foregroundColor(.white)
                        
                        Text(isSignIn ? "Sign in to continue" : "Start your journey with us")
                            .font(Theme.sfProText(16))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 16) {
                        // Email Field
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("Email")
                                        .font(Theme.sfProText(16))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                TextField("", text: $email)
                                    .font(Theme.sfProText(16))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Password Field
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("At least 8 characters")
                                        .font(Theme.sfProText(16))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                SecureField("", text: $password)
                                    .font(Theme.sfProText(16))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    
                    // Remember Me
                    HStack {
                        Button {
                            rememberMe.toggle()
                        } label: {
                            HStack {
                                Image(systemName: rememberMe ? "checkmark.circle.fill" : "circle")
                                Text("Remember me")
                            }
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.gray)
                    .font(Theme.sfProText(14))
                    .padding(.horizontal, 32)
                    
                    // Sign Up/In Button
                    Button(action: authenticate) {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignIn ? "Sign in" : "Sign up")
                                .font(Theme.sfProText(16).bold())
                        }
                    }
                    .foregroundColor(isPressed ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(10)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .opacity(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    .disabled(email.isEmpty || password.isEmpty || isProcessing)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isProcessing {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                isPressed = false
                            }
                    )
                    .padding(.horizontal, 32)
                    
                    // Google Sign In Button
                    Button(action: handleGoogleSignIn) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Sign up with Google")
                            .font(Theme.sfProText(16))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
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
                    
                    Button {
                        withAnimation {
                            isSignIn.toggle()
                        }
                    } label: {
                        Text(isSignIn ? "Need an account? Sign Up" : "Have an account? Sign In")
                            .font(Theme.sfProText(14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            // TODO: Implement Google Sign In
        }
    }
    
    private func authenticate() {
        guard !email.isEmpty, !password.isEmpty else {
            sessionManager.error = "Email and password cannot be empty"
            return
        }
        
        isProcessing = true
        
        Task {
            if isSignIn {
                await sessionManager.signIn(email: email, password: password)
                if sessionManager.isAuthenticated {
                    // Clear fields on successful sign in
                    email = ""
                    password = ""
                }
            } else {
                await sessionManager.signUp(email: email, password: password)
                if !sessionManager.needsEmailConfirmation {
                    // Clear fields on successful sign up
                    email = ""
                    password = ""
                }
            }
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}

// MARK: - Previews
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        // Sign Up Preview
        AuthView(isSignIn: false)
            .environment(makePreviewSessionManager())
            .previewDisplayName("Sign Up")
        
        // Sign In Preview
        AuthView(isSignIn: true)
            .environment(makePreviewSessionManager())
            .previewDisplayName("Sign In")
        
        // Loading State Preview
        AuthView()
            .environment(makePreviewSessionManager(isLoading: true))
            .previewDisplayName("Loading")
        
        // Error State Preview
        AuthView()
            .environment(makePreviewSessionManager(error: "Invalid credentials"))
            .previewDisplayName("Error State")
    }
    
    // Helper function to create consistent preview session managers
    private static func makePreviewSessionManager(
        isLoading: Bool = false,
        error: String? = nil
    ) -> SessionManager {
        let manager = SessionManager()
        manager.isLoading = isLoading
        manager.error = error
        return manager
    }
}

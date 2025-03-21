import Foundation
import Auth
import Supabase

@Observable final class SessionManager {
    private let supabase: SupabaseClient
    var currentUser: User?
    var isAuthenticated = false
    var isLoading = true
    var error: String?
    var needsEmailConfirmation = false
    
    init() {
        self.supabase = AppConfig.shared
        Task {
            await checkAuth()
        }
    }
    
    func checkAuth() async {
        do {
            currentUser = try await supabase.auth.session.user
            isAuthenticated = currentUser != nil
            
            if let user = currentUser {
                needsEmailConfirmation = user.emailConfirmedAt == nil
            }
        } catch {
            handleError(error)
        }
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        needsEmailConfirmation = false
        
        do {
            let auth = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            currentUser = auth.user
            needsEmailConfirmation = auth.user.emailConfirmedAt == nil
            isAuthenticated = !needsEmailConfirmation
            
            if needsEmailConfirmation {
                error = "Please confirm your email to continue"
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        error = nil
        needsEmailConfirmation = false
        
        do {
            let auth = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            currentUser = auth.user
            needsEmailConfirmation = auth.user.emailConfirmedAt == nil
            isAuthenticated = !needsEmailConfirmation
            
            if needsEmailConfirmation {
                error = "Please check your email to confirm your account"
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
            needsEmailConfirmation = false
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
        
        let errorMessage = error.localizedDescription.lowercased()
        if errorMessage.contains("invalid credentials") || 
           errorMessage.contains("invalid login") {
            self.error = "Invalid email or password"
        } else if errorMessage.contains("user not found") {
            self.error = "No account found with this email"
        } else if errorMessage.contains("email not confirmed") {
            self.error = "Please confirm your email address"
            needsEmailConfirmation = true
        }
        
        currentUser = nil
        isAuthenticated = false
    }
}

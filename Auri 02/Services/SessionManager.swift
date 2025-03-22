import Foundation
import Auth
import Supabase
import SwiftUI
import os
import Combine

@Observable
final class SessionManager: ObservableObject {
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "SessionManager")
    
    private let supabase: SupabaseClient
    var currentUser: User? = nil
    var isAuthenticated: Bool = false
    var isLoading = true
    var error: String?
    var needsEmailConfirmation = false
    
    private let initializationTime: Date
    private let skipAuthCheck: Bool
    
    init(skipAuthCheck: Bool = false) {
        self.initializationTime = Date()
        self.skipAuthCheck = skipAuthCheck
        logger.debug("Initializing SessionManager")
        
        #if DEBUG
        logger.debug("SessionManager initialized in preview mode")
        // For previews, we can set some default state
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            isAuthenticated = false
            currentUser = nil
        }
        #endif
        
        self.supabase = AppConfig.shared
        
        if !skipAuthCheck {
            Task {
                logger.debug("Starting auth check")
                await withTimeout(seconds: 5) {
                    await self.checkAuth()
                }
            }
        } else {
            isLoading = false
        }
    }
    
    private func withTimeout<T>(seconds: Double, operation: @escaping () async -> T) async -> T? {
        await withTaskGroup(of: Optional<T>.self) { group in
            // Add operation task
            group.addTask {
                await operation()
            }
            
            // Add timeout task
            group.addTask { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                self?.logger.error("Operation timed out after \(seconds) seconds")
                return nil
            }
            
            // Get first completed result
            // Use flatMap to handle the double optional
            return await group.next().flatMap { $0 }
        }
    }
    
    func checkAuth() async {
        do {
            currentUser = try await supabase.auth.user()
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
        
        do {
            let auth = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            if auth.user.emailConfirmedAt == nil {
                throw AuthError.emailNotConfirmed
            }
            
            currentUser = auth.user
            isAuthenticated = true
            needsEmailConfirmation = false
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
        let authError: AuthError
        
        switch error {
        case let error as AuthError:
            authError = error
        case _ where error.localizedDescription.lowercased().contains("invalid credentials"):
            authError = .invalidCredentials
        case _ where error.localizedDescription.lowercased().contains("user not found"):
            authError = .unauthorized
        case _ where error.localizedDescription.lowercased().contains("email not confirmed"):
            authError = .emailNotConfirmed
        default:
            authError = .unauthorized
        }
        
        self.error = authError.description
        currentUser = nil
        isAuthenticated = false
        needsEmailConfirmation = authError == .emailNotConfirmed
    }
}

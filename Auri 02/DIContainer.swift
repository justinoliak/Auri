import Foundation
import SwiftUI

// Add this at the top of the file
#if DEBUG
enum DebugSettings {
    /// Set this to true to use real Supabase backend in debug mode
    static var useRealServices = false
}
#endif

// MARK: - Service Protocols
@MainActor
protocol ServiceContainer {
    var aiService: AIServiceProtocol { get }
    var journalService: JournalServiceProtocol { get }
    var sessionManager: SessionManager { get }
    var errorHandler: ErrorHandling { get }
}

// MARK: - Environment Keys
private struct SessionManagerKey: EnvironmentKey {
    static let defaultValue: SessionManager? = nil
}

extension EnvironmentValues {
    var sessionManager: SessionManager? {
        get { self[SessionManagerKey.self] }
        set { self[SessionManagerKey.self] = newValue }
    }
}

// MARK: - Container Implementation
@MainActor
final class DIContainer: ServiceContainer {
    let aiService: AIServiceProtocol
    let journalService: JournalServiceProtocol
    let sessionManager: SessionManager
    let errorHandler: ErrorHandling
    
    init(
        aiService: AIServiceProtocol? = nil,
        journalService: JournalServiceProtocol? = nil,
        sessionManager: SessionManager? = nil,
        errorHandler: ErrorHandler? = nil
    ) {
        self.aiService = aiService ?? MockAIService()
        self.journalService = journalService ?? MockJournalService()
        self.sessionManager = sessionManager ?? SessionManager()
        self.errorHandler = errorHandler ?? ErrorHandler()
    }
    
    @MainActor
    static func preview() -> DIContainer {
        #if DEBUG
        if DebugSettings.useRealServices {
            // Use real services even in debug mode
            let journalService = JournalService(supabase: AppConfig.shared)
            
            // CHANGE: Create session manager directly instead of using static method
            let sessionManager = SessionManager(skipAuthCheck: true)
            sessionManager.currentUser = MockData.user
            sessionManager.isAuthenticated = true
            sessionManager.isLoading = false
            
            return DIContainer(
                aiService: MockAIService(),
                journalService: journalService,
                sessionManager: sessionManager,
                errorHandler: ErrorHandler()
            )
        } else {
            // Use mock services
            let mockJournalService = MockJournalService()
            mockJournalService.entries = MockData.journalEntries
            
            // CHANGE: Create mock session manager directly
            let mockSessionManager = SessionManager(skipAuthCheck: true)
            mockSessionManager.currentUser = MockData.user
            mockSessionManager.isAuthenticated = true
            mockSessionManager.isLoading = false
            
            return DIContainer(
                aiService: MockAIService(),
                journalService: mockJournalService,
                sessionManager: mockSessionManager,
                errorHandler: ErrorHandler()
            )
        }
        #else
        let journalService = JournalService(supabase: AppConfig.shared)
        let sessionManager = SessionManager()
        return DIContainer(
            aiService: MockAIService(),
            journalService: journalService,
            sessionManager: sessionManager,
            errorHandler: ErrorHandler()
        )
        #endif
    }
}

// MARK: - Container Environment
private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer? = nil
}

extension EnvironmentValues {
    var container: DIContainer? {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func inject(_ container: DIContainer) -> some View {
        self
            .environment(\.container, container)
            .environment(\.sessionManager, container.sessionManager)  // For @Environment access
            .environmentObject(container.sessionManager)  // For @EnvironmentObject access
    }
}

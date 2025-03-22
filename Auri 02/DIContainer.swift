import Foundation
import SwiftUI

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
    
    static func preview() -> DIContainer {
        DIContainer()
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
            .environment(\.sessionManager, container.sessionManager)
    }
}

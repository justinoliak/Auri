import Foundation
import Auth
import Supabase
import SwiftUI

#if DEBUG
enum MockData {
    static let user = User(
        id: .init(),
        appMetadata: [:],
        userMetadata: [:],
        aud: "authenticated",
        email: "test@example.com",
        phone: nil,
        createdAt: Date(),
        confirmedAt: Date(),
        emailConfirmedAt: Date(),
        phoneConfirmedAt: nil,
        lastSignInAt: Date(),
        role: nil,
        updatedAt: Date(),
        identities: [],
        factors: []
    )
    
    static let journalEntries: [JournalEntry] = [
        .init(
            id: UUID(),
            userId: user.id.uuidString,
            text: "Today was incredible! Launched my new project and got great feedback.",
            analysis: "Very positive sentiment. High enthusiasm and accomplishment.",
            createdAt: Date()
        ),
        .init(
            id: UUID(),
            userId: user.id.uuidString,
            text: "Feeling a bit overwhelmed with deadlines, but staying focused.",
            analysis: "Mixed emotions, showing resilience despite stress.",
            createdAt: Date().addingTimeInterval(-86400)
        ),
        .init(
            id: UUID(),
            userId: user.id.uuidString,
            text: "Morning meditation really helped center me today.",
            analysis: "Calm and balanced emotional state.",
            createdAt: Date().addingTimeInterval(-172800)
        )
    ]
    
    @MainActor
    static func createMockContainer() -> DIContainer {
        // Create an authenticated session manager
        let sessionManager = SessionManager(skipAuthCheck: true)
        sessionManager.currentUser = MockData.user
        sessionManager.isAuthenticated = true
        sessionManager.isLoading = false
        
        // Create mock journal service with entries
        let mockJournalService = MockJournalService()
        mockJournalService.entries = MockData.journalEntries
        
        // Create mock AI service
        let mockAIService = MockAIService()
        
        // Create container with all mock services
        return DIContainer(
            aiService: mockAIService,
            journalService: mockJournalService,
            sessionManager: sessionManager,
            errorHandler: ErrorHandler()
        )
    }
}

// MARK: - Mock Journal Service
@Observable
class MockJournalService: JournalServiceProtocol {
    var entries: [JournalEntry] = MockData.journalEntries
    var error: String?
    var isLoading = false
    
    func createEntry(text: String, analysis: String?, userId: String) async throws {
        let entry = JournalEntry(
            id: UUID(),
            userId: userId,
            text: text,
            analysis: analysis,
            createdAt: Date()
        )
        entries.insert(entry, at: 0)
    }
    
    func fetchEntries(userId: String) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        entries = MockData.journalEntries
        isLoading = false
    }
}
#endif

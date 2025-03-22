import Foundation
import Supabase
import os

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let userId: String
    let text: String
    let analysis: String?
    let createdAt: Date
    
    init(id: UUID = UUID(), userId: String, text: String, analysis: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.text = text
        self.analysis = analysis
        self.createdAt = createdAt
    }
}

protocol JournalServiceProtocol {
    var entries: [JournalEntry] { get set }
    var error: String? { get set }
    var isLoading: Bool { get set }
    
    func createEntry(text: String, analysis: String?, userId: String) async throws
    func fetchEntries(userId: String) async
}

@Observable
class JournalService: JournalServiceProtocol {
    private let supabase: SupabaseClient
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "JournalService")
    
    var entries: [JournalEntry] = []
    var error: String?
    var isLoading = false
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func createEntry(text: String, analysis: String? = nil, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        logger.debug("Calling journal-entry Edge Function")
        
        // Prepare the payload for the Edge Function using only Encodable types
        let payload: [String: String?] = [
            "text": text,
            "analysis": analysis,
            "userId": userId
        ]
        
        do {
            // Call the Edge Function with proper options parameter
            let response: JournalEntry = try await supabase.functions.invoke(
                "journal-entry",
                options: .init(
                    headers: ["Authorization": "Bearer \(supabase.auth.session.accessToken)"],
                    body: payload
                )
            )
            
            logger.debug("Edge Function call successful")
            
            await MainActor.run {
                entries.insert(response, at: 0)
            }
        } catch {
            logger.error("Edge Function call failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchEntries(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            logger.debug("Calling get-entries Edge Function")
            
            // Use Encodable dictionary for body
            let body: [String: String] = ["userId": userId]
            
            let response: [JournalEntry] = try await supabase.functions.invoke(
                "get-entries",
                options: .init(
                    headers: ["Authorization": "Bearer \(supabase.auth.session.accessToken)"],
                    body: body
                )
            )
            
            logger.debug("Successfully fetched \(response.count) entries")
            
            await MainActor.run {
                entries = response
                error = nil
            }
        } catch {
            logger.error("Failed to fetch entries: \(error.localizedDescription)")
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
}

//
//  Auri_02Tests.swift
//  Auri 02Tests
//
//  Created by Justin Oliak on 3/20/25.
//

import XCTest
@testable import Auri_02

final class Auri_02Tests: XCTestCase {
    var journalService: MockJournalService!
    var aiService: MockAIService!
    
    override func setUpWithError() throws {
        journalService = MockJournalService()
        aiService = MockAIService()
    }
    
    override func tearDownWithError() throws {
        journalService = nil
        aiService = nil
    }
    
    func testJournalEntryCreation() async throws {
        // Given
        let text = "Test entry"
        let userId = UUID().uuidString
        
        // When
        try await journalService.createEntry(text: text, analysis: nil, userId: userId)
        
        // Then
        XCTAssertEqual(journalService.entries.count, 1)
        XCTAssertEqual(journalService.entries.first?.text, text)
        XCTAssertEqual(journalService.entries.first?.userId, userId)
    }
    
    func testAIAnalysis() async throws {
        // Given
        let text = "Test entry for analysis"
        
        // When
        let analysis = try await aiService.generateAnalysis(for: text)
        
        // Then
        XCTAssertFalse(analysis.isEmpty)
    }
    
    func testErrorHandling() async throws {
        // Given
        let errorHandler = ErrorHandler() // Create new instance instead of using shared
        
        // When
        errorHandler.handle(AppError.rateLimitExceeded)
        
        // Then
        XCTAssertNotNil(errorHandler.currentError)
        XCTAssertEqual(errorHandler.currentError?.errorDescription, "Too many requests. Please try again later.")
    }
}

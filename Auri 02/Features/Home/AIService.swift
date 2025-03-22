import Foundation

protocol AIServiceProtocol {
    var isLoading: Bool { get set }
    var error: String? { get set }
    func generateAnalysis(for text: String) async throws -> String
}

@Observable
class AIService: AIServiceProtocol {
    private let apiKey: String
    var isLoading = false
    var error: String?
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateAnalysis(for text: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Analyze this journal entry and provide a brief, empathetic insight (2-3 sentences):
        
        Entry: \(text)
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are an empathetic AI assistant analyzing journal entries."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        return response.choices.first?.message.content ?? ""
    }
}

@Observable
class MockAIService: AIServiceProtocol {
    var isLoading = false
    var error: String?
    
    func generateAnalysis(for text: String) async throws -> String {
        return "This is a mock analysis for preview purposes."
    }
}

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

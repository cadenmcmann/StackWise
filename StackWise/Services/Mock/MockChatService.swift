import Foundation

// MARK: - MockChatService
public class MockChatService: ChatService {
    private var messageHistory: [Message] = []
    private var sessions: [ChatSession] = []
    private var sessionMessages: [String: [Message]] = [:]
    private var currentSessionId: String?
    
    public init() {
        // Create a default session
        let defaultSession = ChatSession(
            id: UUID().uuidString,
            title: "General Questions",
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date()
        )
        sessions.append(defaultSession)
        currentSessionId = defaultSession.id
        
        // Add initial system message to the default session
        let systemMessage = Message(
            role: .system,
            text: "Hi! I'm here to help you optimize your supplement stack. Ask me anything about your regimen, dosing, timing, or potential adjustments."
        )
        sessionMessages[defaultSession.id] = [systemMessage]
        messageHistory = [systemMessage]
    }
    
    public func send(message: Message, context: ChatContext) async throws -> [Message] {
        guard let sessionId = currentSessionId else {
            throw NetworkError.apiError(message: "No active session", statusCode: 400)
        }
        
        // Get current session messages
        var messages = sessionMessages[sessionId] ?? []
        
        // Add user message
        messages.append(message)
        
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Generate mock response based on message content
        let responseText = generateMockResponse(for: message.text, context: context)
        
        let assistantMessage = Message(
            role: .assistant,
            text: responseText
        )
        
        messages.append(assistantMessage)
        
        // Update session messages
        sessionMessages[sessionId] = messages
        
        // Update session's updatedAt time
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            var updatedSession = sessions[index]
            updatedSession = ChatSession(
                id: updatedSession.id,
                userId: updatedSession.userId,
                title: updatedSession.title,
                createdAt: updatedSession.createdAt,
                updatedAt: Date()
            )
            sessions[index] = updatedSession
        }
        
        // Return the conversation with the new messages
        return messages
    }
    
    public func createSession(title: String?) async throws -> ChatSession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let session = ChatSession(
            id: UUID().uuidString,
            title: title,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        sessions.insert(session, at: 0)
        
        // Initialize with system message
        let systemMessage = Message(
            role: .system,
            text: "Hi! I'm here to help you optimize your supplement stack. Ask me anything about your regimen, dosing, timing, or potential adjustments."
        )
        sessionMessages[session.id] = [systemMessage]
        
        return session
    }
    
    public func fetchSessions(limit: Int, cursor: String?) async throws -> [ChatSession] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock sessions sorted by updatedAt
        return sessions.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    public func fetchSessionMessages(sessionId: String, limit: Int, before: String?) async throws -> [Message] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return sessionMessages[sessionId] ?? []
    }
    
    public func setCurrentSession(_ sessionId: String?) {
        currentSessionId = sessionId
    }
    
    public func getCurrentSessionId() -> String? {
        return currentSessionId
    }
    
    public func getCachedSessions() -> [ChatSession] {
        return sessions
    }
    
    public func getCachedMessages(for sessionId: String) -> [Message] {
        return sessionMessages[sessionId] ?? []
    }
    
    public func clearCache() {
        // In mock, we'll keep the default session
        if let defaultSession = sessions.first {
            sessions = [defaultSession]
            let systemMessage = sessionMessages[defaultSession.id]?.first { $0.role == .system }
            sessionMessages = [defaultSession.id: systemMessage.map { [$0] } ?? []]
        }
    }
    
    private func generateMockResponse(for text: String, context: ChatContext) -> String {
        let lowercased = text.lowercased()
        
        // Check for common queries and provide appropriate responses
        if lowercased.contains("magnesium") && lowercased.contains("pm") {
            return "Moving magnesium to PM is a great idea! Magnesium glycinate can promote relaxation and improve sleep quality when taken 30-60 minutes before bed. I'll update your schedule accordingly."
        } else if lowercased.contains("cheaper") || lowercased.contains("budget") {
            return "I can help you optimize for budget. Consider these options:\n\n1. Focus on the essentials (keep creatine and magnesium)\n2. Buy in bulk when possible\n3. Choose powder forms over capsules\n\nWould you like me to create a budget-optimized version of your stack?"
        } else if lowercased.contains("powder") {
            return "If you prefer to avoid powders, we can switch to capsule or tablet forms. Note that:\n\n• Capsules may be more expensive\n• You might need to take more pills\n• Some supplements (like creatine) require many capsules for effective doses\n\nShall I update your stack with capsule alternatives?"
        } else if lowercased.contains("side effect") {
            return "Common side effects to watch for:\n\n• Creatine: Minor water retention, digestive discomfort if taken on empty stomach\n• Magnesium: Loose stools if dose is too high\n• L-Theanine: Very rare, but some report drowsiness\n\nIf you experience any concerning symptoms, please consult with your healthcare provider."
        } else if lowercased.contains("timing") || lowercased.contains("when") {
            return "Here's the optimal timing for your supplements:\n\n• Creatine: Any time (consistency matters more than timing)\n• Magnesium Glycinate: 30-60 min before bed\n• L-Theanine: Morning with coffee or afternoon for focus\n• Vitamin D: Morning with breakfast (fat helps absorption)\n\nWould you like to adjust any of these timings?"
        } else if lowercased.contains("athlete") || lowercased.contains("workout") {
            return "For athletic performance, consider:\n\n• Take creatine daily (timing doesn't matter)\n• Add beta-alanine for endurance\n• Consider citrulline for pump/blood flow\n• Ensure adequate protein intake\n\nWould you like me to create an athlete-focused stack?"
        } else {
            // Generic helpful response
            return "That's a great question! Based on your current stack and goals, here are some thoughts:\n\nYour current regimen looks well-balanced for your goals. The combination of creatine, magnesium, and L-theanine addresses strength, recovery, and stress management.\n\nIs there a specific aspect of your stack you'd like to explore further?"
        }
    }
}

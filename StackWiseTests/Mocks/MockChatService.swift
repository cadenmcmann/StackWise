import Foundation
@testable import StackWise

// MARK: - MockChatService
final class MockChatService: ChatService {
    
    // MARK: - Call Tracking
    var sendMessageCallCount = 0
    var createSessionCallCount = 0
    var fetchSessionsCallCount = 0
    var fetchSessionMessagesCallCount = 0
    var setCurrentSessionCallCount = 0
    var getCurrentSessionIdCallCount = 0
    var getCachedSessionsCallCount = 0
    var getCachedMessagesCallCount = 0
    var clearCacheCallCount = 0
    
    // MARK: - Captured Parameters
    var lastMessage: Message?
    var lastContext: ChatContext?
    var lastSessionTitle: String?
    var lastSessionId: String?
    var lastLimit: Int?
    var lastCursor: String?
    var lastBefore: String?
    
    // MARK: - Configured Responses
    var messagesToReturn: [Message] = []
    var sessionToReturn: ChatSession?
    var sessionsToReturn: [ChatSession] = []
    var errorToThrow: Error?
    
    // MARK: - Internal State
    private var currentSessionId: String?
    private var cachedSessions: [ChatSession] = []
    private var cachedMessages: [String: [Message]] = [:]
    
    // MARK: - ChatService Implementation
    
    func send(message: Message, context: ChatContext) async throws -> [Message] {
        sendMessageCallCount += 1
        lastMessage = message
        lastContext = context
        if let error = errorToThrow { throw error }
        return messagesToReturn
    }
    
    func createSession(title: String?) async throws -> ChatSession {
        createSessionCallCount += 1
        lastSessionTitle = title
        if let error = errorToThrow { throw error }
        guard let session = sessionToReturn else {
            throw MockError.notConfigured
        }
        return session
    }
    
    func fetchSessions(limit: Int, cursor: String?) async throws -> [ChatSession] {
        fetchSessionsCallCount += 1
        lastLimit = limit
        lastCursor = cursor
        if let error = errorToThrow { throw error }
        return sessionsToReturn
    }
    
    func fetchSessionMessages(sessionId: String, limit: Int, before: String?) async throws -> [Message] {
        fetchSessionMessagesCallCount += 1
        lastSessionId = sessionId
        lastLimit = limit
        lastBefore = before
        if let error = errorToThrow { throw error }
        return messagesToReturn
    }
    
    func setCurrentSession(_ sessionId: String?) {
        setCurrentSessionCallCount += 1
        lastSessionId = sessionId
        currentSessionId = sessionId
    }
    
    func getCurrentSessionId() -> String? {
        getCurrentSessionIdCallCount += 1
        return currentSessionId
    }
    
    func getCachedSessions() -> [ChatSession] {
        getCachedSessionsCallCount += 1
        return cachedSessions
    }
    
    func getCachedMessages(for sessionId: String) -> [Message] {
        getCachedMessagesCallCount += 1
        lastSessionId = sessionId
        return cachedMessages[sessionId] ?? []
    }
    
    func clearCache() {
        clearCacheCallCount += 1
        cachedSessions = []
        cachedMessages = [:]
    }
    
    // MARK: - Test Configuration
    func setCachedSessions(_ sessions: [ChatSession]) {
        cachedSessions = sessions
    }
    
    func setCachedMessages(_ messages: [Message], for sessionId: String) {
        cachedMessages[sessionId] = messages
    }
    
    // MARK: - Helper
    func reset() {
        sendMessageCallCount = 0
        createSessionCallCount = 0
        fetchSessionsCallCount = 0
        fetchSessionMessagesCallCount = 0
        setCurrentSessionCallCount = 0
        getCurrentSessionIdCallCount = 0
        getCachedSessionsCallCount = 0
        getCachedMessagesCallCount = 0
        clearCacheCallCount = 0
        
        lastMessage = nil
        lastContext = nil
        lastSessionTitle = nil
        lastSessionId = nil
        lastLimit = nil
        lastCursor = nil
        lastBefore = nil
        
        messagesToReturn = []
        sessionToReturn = nil
        sessionsToReturn = []
        errorToThrow = nil
        
        currentSessionId = nil
        cachedSessions = []
        cachedMessages = [:]
    }
}


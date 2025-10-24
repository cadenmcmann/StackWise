import Foundation

// MARK: - RealChatService
public class RealChatService: ChatService {
    private let networkManager = NetworkManager.shared
    private var currentSessionId: String?
    private var cachedSessions: [ChatSession] = []
    private var cachedMessages: [String: [Message]] = [:] // sessionId -> messages
    private let cacheKey = "chat_cache"
    
    public init() {
        loadCache()
    }
    
    // MARK: - ChatService Protocol
    
    public func send(message: Message, context: ChatContext) async throws -> [Message] {
        // If we don't have a current session, create one
        if currentSessionId == nil {
            let session = try await createSession(title: nil)
            currentSessionId = session.id
        }
        
        guard let sessionId = currentSessionId else {
            throw NetworkError.apiError(message: "Failed to create chat session", statusCode: 500)
        }
        
        // Send the message
        let request = SendMessageRequest(message: message.text)
        let response = try await networkManager.request(
            endpoint: "chat/session/\(sessionId)/message",
            method: "POST",
            body: request,
            requiresAuth: true,
            responseType: SendMessageResponse.self
        )
        
        // Create the assistant's response message
        let assistantMessage = Message(
            id: response.messageId,
            role: .assistant,
            text: response.content,
            createdAt: ISO8601DateFormatter().date(from: response.createdAt) ?? Date()
        )
        
        // Update cached messages
        var messages = cachedMessages[sessionId] ?? []
        messages.append(message)
        messages.append(assistantMessage)
        cachedMessages[sessionId] = messages
        
        // Save cache
        saveCache()
        
        return messages
    }
    
    // MARK: - Session Management
    
    public func createSession(title: String?) async throws -> ChatSession {
        let response: CreateSessionResponse
        
        if let title = title {
            // Send with title
            let request = CreateSessionWithTitleRequest(title: title)
            response = try await networkManager.request(
                endpoint: "chat/session",
                method: "POST",
                body: request,
                requiresAuth: true,
                responseType: CreateSessionResponse.self
            )
        } else {
            // Send empty object {}
            let request = CreateSessionRequest()
            response = try await networkManager.request(
                endpoint: "chat/session",
                method: "POST",
                body: request,
                requiresAuth: true,
                responseType: CreateSessionResponse.self
            )
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let session = ChatSession(
            id: response.sessionId,
            title: response.title,
            createdAt: formatter.date(from: response.createdAt) ?? Date(),
            updatedAt: formatter.date(from: response.createdAt) ?? Date()
        )
        
        // Add to cached sessions
        cachedSessions.insert(session, at: 0)
        saveCache()
        
        return session
    }
    
    public func fetchSessions(limit: Int = 20, cursor: String? = nil) async throws -> [ChatSession] {
        var endpoint = "chat/sessions?limit=\(limit)"
        if let cursor = cursor {
            endpoint += "&cursor=\(cursor)"
        }
        
        let response = try await networkManager.request(
            endpoint: endpoint,
            method: "GET",
            requiresAuth: true,
            responseType: ChatSessionsResponse.self
        )
        
        let sessions = response.sessions.map { $0.toChatSession() }
        
        // Update cache
        if cursor == nil {
            // This is the first page, replace cache
            cachedSessions = sessions
        } else {
            // Append to cache
            cachedSessions.append(contentsOf: sessions)
        }
        saveCache()
        
        return sessions
    }
    
    public func fetchSessionMessages(sessionId: String, limit: Int = 50, before: String? = nil) async throws -> [Message] {
        var endpoint = "chat/session/\(sessionId)?limit=\(limit)"
        if let before = before {
            endpoint += "&before=\(before)"
        }
        
        let response = try await networkManager.request(
            endpoint: endpoint,
            method: "GET",
            requiresAuth: true,
            responseType: ChatSessionDetailResponse.self
        )
        
        let messages = response.messages.map { $0.toMessage() }
        
        // Update cache
        if before == nil {
            // This is the initial load, replace cache
            cachedMessages[sessionId] = messages
        } else {
            // Prepend older messages
            var existingMessages = cachedMessages[sessionId] ?? []
            existingMessages.insert(contentsOf: messages, at: 0)
            cachedMessages[sessionId] = existingMessages
        }
        saveCache()
        
        return messages
    }
    
    // MARK: - Current Session Management
    
    public func setCurrentSession(_ sessionId: String?) {
        currentSessionId = sessionId
    }
    
    public func getCurrentSessionId() -> String? {
        return currentSessionId
    }
    
    // MARK: - Cache Management
    
    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode(ChatCache.self, from: data) else {
            return
        }
        
        cachedSessions = cache.sessions
        cachedMessages = cache.messages
    }
    
    private func saveCache() {
        let cache = ChatCache(
            sessions: cachedSessions,
            messages: cachedMessages
        )
        
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    public func getCachedSessions() -> [ChatSession] {
        return cachedSessions
    }
    
    public func getCachedMessages(for sessionId: String) -> [Message] {
        return cachedMessages[sessionId] ?? []
    }
    
    public func clearCache() {
        cachedSessions = []
        cachedMessages = [:]
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
}

// MARK: - Cache Model
private struct ChatCache: Codable {
    let sessions: [ChatSession]
    let messages: [String: [Message]]
}

import Foundation

// MARK: - ChatService Protocol
public protocol ChatService {
    func send(message: Message, context: ChatContext) async throws -> [Message]
}

// MARK: - ChatContext
public struct ChatContext {
    public let user: User?
    public let stack: Stack?
    
    public init(user: User? = nil, stack: Stack? = nil) {
        self.user = user
        self.stack = stack
    }
}

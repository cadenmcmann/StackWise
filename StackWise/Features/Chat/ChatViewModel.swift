import Foundation
import SwiftUI

// MARK: - ChatViewModel
@MainActor
public class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let container: DIContainer
    private let chatService: ChatService
    
    // Suggestion chips
    let suggestions = [
        "Move magnesium to PM",
        "Make stack cheaper",
        "I don't like powders",
        "Add something for focus",
        "Explain creatine benefits",
        "Check for interactions"
    ]
    
    public init(container: DIContainer) {
        self.container = container
        self.chatService = container.chatService
        
        // Initialize with welcome message
        messages = [
            Message(
                role: .system,
                text: "Hi! I'm here to help you optimize your supplement stack. Ask me anything about your regimen, dosing, timing, or potential adjustments."
            )
        ]
    }
    
    // MARK: - Actions
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Create user message
        let userMessage = Message(role: .user, text: text)
        messages.append(userMessage)
        
        // Clear input
        inputText = ""
        isLoading = true
        
        do {
            // Create context
            let context = ChatContext(
                user: container.currentUser,
                stack: container.currentStack
            )
            
            // Send message and get response
            let updatedMessages = try await chatService.send(
                message: userMessage,
                context: context
            )
            
            // Update messages (includes the assistant's response)
            messages = updatedMessages
        } catch {
            errorMessage = "Failed to send message. Please try again."
            showError = true
        }
        
        isLoading = false
    }
    
    func sendSuggestion(_ suggestion: String) {
        inputText = suggestion
        Task {
            await sendMessage()
        }
    }
    
    func clearChat() {
        messages = [
            Message(
                role: .system,
                text: "Hi! I'm here to help you optimize your supplement stack. Ask me anything about your regimen, dosing, timing, or potential adjustments."
            )
        ]
    }
}

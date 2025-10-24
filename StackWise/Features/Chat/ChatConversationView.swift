import SwiftUI

// MARK: - ChatConversationView
public struct ChatConversationView: View {
    @StateObject private var viewModel: ChatConversationViewModel
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.container) private var container
    
    private let session: ChatSession
    
    public init(container: DIContainer, session: ChatSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: ChatConversationViewModel(
            container: container,
            session: session
        ))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Guardrail banner
                Banner(
                    type: .info,
                    title: "Educational Only",
                    message: "This is not medical advice. Consult healthcare professionals for medical decisions."
                )
                .padding(Theme.Spacing.gutter)
                
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            // Load more button if there are older messages
                            if viewModel.hasMore {
                                Button {
                                    Task {
                                        await viewModel.loadOlderMessages()
                                    }
                                } label: {
                                    HStack {
                                        if viewModel.isLoadingMore {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "arrow.up.circle")
                                        }
                                        Text("Load earlier messages")
                                            .font(Theme.Typography.caption)
                                    }
                                    .foregroundColor(Theme.Colors.primary)
                                    .padding(.vertical, Theme.Spacing.sm)
                                }
                                .disabled(viewModel.isLoadingMore)
                            }
                            
                            // Messages
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Loading indicator for new messages
                            if viewModel.isLoading {
                                LoadingBubble()
                            }
                        }
                        .padding(Theme.Spacing.gutter)
                    }
                    .onChange(of: viewModel.messages.count) { _, newCount in
                        if !viewModel.isLoadingMore {
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        // Scroll to bottom on initial load
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
                
                Divider()
                
                // Input area
                VStack(spacing: Theme.Spacing.md) {
                    // Text input and send button
                    HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                        TextField(
                            "Ask about your supplements...",
                            text: $viewModel.inputText,
                            axis: .vertical
                        )
                        .font(Theme.Typography.body)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.xl)
                                .fill(Theme.Colors.surfaceAlt)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radii.xl)
                                .stroke(
                                    isInputFocused ? Theme.Colors.primary : Theme.Colors.border,
                                    lineWidth: isInputFocused ? 2 : 1
                                )
                        )
                        .focused($isInputFocused)
                        .lineLimit(1...4)
                        .onSubmit {
                            Task {
                                await viewModel.sendMessage()
                            }
                        }
                        
                        Button {
                            Task {
                                await viewModel.sendMessage()
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(
                                    viewModel.inputText.isEmpty ? Theme.Colors.disabled : Theme.Colors.primary
                                )
                        }
                        .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.bottom, Theme.Spacing.md)
                }
                .background(Theme.Colors.surface)
            }
            .navigationTitle(session.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await viewModel.renameSession()
                            }
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            viewModel.clearMessages()
                        } label: {
                            Label("Clear Messages", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.loadMessages()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Rename Chat", isPresented: $viewModel.showRenameAlert) {
            TextField("Chat Title", text: $viewModel.newTitle)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                Task {
                    await viewModel.saveNewTitle()
                }
            }
        }
    }
}

// MARK: - ChatConversationViewModel
@MainActor
public class ChatConversationViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMore = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showRenameAlert = false
    @Published var newTitle = ""
    
    private let container: DIContainer
    private let chatService: ChatService
    private let session: ChatSession
    
    public init(container: DIContainer, session: ChatSession) {
        self.container = container
        self.chatService = container.chatService
        self.session = session
        self.newTitle = session.title ?? ""
        
        // Set this session as current
        chatService.setCurrentSession(session.id)
    }
    
    // MARK: - Actions
    
    func loadMessages() async {
        isLoading = true
        
        // First show cached messages if available
        let cached = chatService.getCachedMessages(for: session.id)
        if !cached.isEmpty {
            messages = cached
        }
        
        do {
            // Fetch fresh messages from server
            let fetchedMessages = try await chatService.fetchSessionMessages(
                sessionId: session.id,
                limit: 50,
                before: nil
            )
            
            messages = fetchedMessages
            hasMore = fetchedMessages.count >= 50
            
            // Add welcome message if no messages exist
            if messages.isEmpty {
                messages = [
                    Message(
                        role: .system,
                        text: "Hi! I'm here to help you optimize your supplement stack. Ask me anything about your regimen, dosing, timing, or potential adjustments."
                    )
                ]
            }
        } catch {
            if messages.isEmpty {
                errorMessage = "Failed to load messages"
                showError = true
            }
        }
        
        isLoading = false
    }
    
    func loadOlderMessages() async {
        guard !isLoadingMore, hasMore, let oldestMessage = messages.first else { return }
        
        isLoadingMore = true
        
        do {
            let olderMessages = try await chatService.fetchSessionMessages(
                sessionId: session.id,
                limit: 50,
                before: oldestMessage.createdAt.ISO8601Format()
            )
            
            // Prepend older messages
            messages.insert(contentsOf: olderMessages, at: 0)
            hasMore = olderMessages.count >= 50
        } catch {
            errorMessage = "Failed to load older messages"
            showError = true
        }
        
        isLoadingMore = false
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Create user message
        let userMessage = Message(role: .user, text: text)
        
        // Add to UI immediately (optimistic update)
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
            
            // Send message and get updated conversation
            let updatedMessages = try await chatService.send(
                message: userMessage,
                context: context
            )
            
            // Update messages with the full conversation including assistant's response
            messages = updatedMessages
        } catch {
            // Remove the optimistic user message on error
            messages.removeLast()
            errorMessage = "Failed to send message. Please try again."
            showError = true
            inputText = text // Restore input text so user can retry
        }
        
        isLoading = false
    }
    
    func clearMessages() {
        messages = [
            Message(
                role: .system,
                text: "Chat cleared. How can I help you with your supplements today?"
            )
        ]
    }
    
    func renameSession() async {
        showRenameAlert = true
    }
    
    func saveNewTitle() async {
        // This would call an API endpoint to update the session title
        // For now, we'll just update locally
        // TODO: Implement session rename API endpoint when available
    }
}

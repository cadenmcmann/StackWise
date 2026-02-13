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
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.sm) {
                            // Compact disclaimer at the top of conversation
                            disclaimerPill
                                .padding(.bottom, Theme.Spacing.sm)

                            // Load more button
                            if viewModel.hasMore {
                                loadMoreButton
                            }

                            // Messages
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }

                            // Loading indicator
                            if viewModel.isLoading {
                                LoadingBubble()
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.gutter)
                        .padding(.top, Theme.Spacing.sm)
                        .padding(.bottom, Theme.Spacing.md)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) { _, newCount in
                        if !viewModel.isLoadingMore {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }

                // Suggestion chips (only when conversation is fresh)
                if viewModel.messages.count <= 1 && !viewModel.isLoading {
                    suggestionChips
                }

                // Input area
                inputArea
            }
            .background(Theme.Colors.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(session.displayTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineLimit(1)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.clearMessages()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17))
                            .foregroundColor(Theme.Colors.textSecondary)
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
    }

    // MARK: - Compact Disclaimer Pill
    private var disclaimerPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 11, weight: .medium))
            Text("AI-generated educational content \u{2022} Not medical advice")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(Theme.Colors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Theme.Colors.surfaceAlt)
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Load More
    private var loadMoreButton: some View {
        Button {
            Task {
                await viewModel.loadOlderMessages()
            }
        } label: {
            HStack(spacing: 6) {
                if viewModel.isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11, weight: .semibold))
                }
                Text("Earlier messages")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Theme.Colors.primary.opacity(0.08))
            )
        }
        .disabled(viewModel.isLoadingMore)
        .frame(maxWidth: .infinity)
        .padding(.bottom, Theme.Spacing.sm)
    }

    // MARK: - Suggestion Chips
    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Button {
                        viewModel.inputText = suggestion
                        Task {
                            await viewModel.sendMessage()
                        }
                    } label: {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Theme.Colors.primary.opacity(0.08))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Theme.Colors.primary.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            // Subtle top separator
            Rectangle()
                .fill(Theme.Colors.border.opacity(0.5))
                .frame(height: 0.5)

            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                // Text field
                TextField(
                    "Ask about your supplements...",
                    text: $viewModel.inputText,
                    axis: .vertical
                )
                .font(Theme.Typography.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Theme.Colors.surfaceAlt)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            isInputFocused ? Theme.Colors.primary.opacity(0.4) : Theme.Colors.border.opacity(0.5),
                            lineWidth: 1
                        )
                )
                .focused($isInputFocused)
                .lineLimit(1...5)
                .onSubmit {
                    Task {
                        await viewModel.sendMessage()
                    }
                }

                // Send button
                Button {
                    Task {
                        await viewModel.sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(
                                    viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? Theme.Colors.disabled
                                        : Theme.Colors.primary
                                )
                        )
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                .animation(.easeInOut(duration: 0.15), value: viewModel.inputText.isEmpty)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.vertical, Theme.Spacing.md)
        }
        .background(Theme.Colors.surface)
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

    private let container: DIContainer
    private let chatService: ChatService
    private let session: ChatSession

    let suggestions = [
        "Optimize my timing",
        "Make stack cheaper",
        "Check for interactions",
        "Add something for focus",
        "Explain my stack"
    ]

    public init(container: DIContainer, session: ChatSession) {
        self.container = container
        self.chatService = container.chatService
        self.session = session

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
}

import SwiftUI

// MARK: - ChatSessionsView
public struct ChatSessionsView: View {
    @StateObject private var viewModel: ChatSessionsViewModel
    @Environment(\.container) private var container
    @State private var selectedSession: ChatSession?
    @State private var showingNewChatSheet = false
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: ChatSessionsViewModel(container: container))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.sessions.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Chat")
                        .font(Theme.Typography.titleM)
                        .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await createNewSession()
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshSessions()
            }
            .sheet(item: $selectedSession) { session in
                ChatConversationView(
                    container: container,
                    session: session
                )
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .task {
            await viewModel.loadSessions()
        }
    }
    
    // MARK: - Views
    
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sessions) { session in
                    SessionRow(
                        session: session,
                        onTap: {
                            selectedSession = session
                        }
                    )
                    
                    if session.id != viewModel.sessions.last?.id {
                        Divider()
                            .padding(.leading, Theme.Spacing.gutter)
                    }
                }
                
                if viewModel.hasMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadMoreSessions()
                        }
                    }
                }
            }
            .background(Theme.Colors.surface)
        }
        .overlay {
            if viewModel.isLoading && viewModel.sessions.isEmpty {
                LoadingOverlay()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.primary.opacity(0.3))
            
            VStack(spacing: Theme.Spacing.sm) {
                Text("No Conversations Yet")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Start a new chat to get personalized supplement guidance")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Button {
                Task {
                    await createNewSession()
                }
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Start New Chat")
                }
                .font(Theme.Typography.body.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.primary)
                .cornerRadius(Theme.Radii.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.surfaceAlt)
    }
    
    // MARK: - Actions
    
    private func createNewSession() async {
        do {
            let session = try await viewModel.createNewSession()
            selectedSession = session
        } catch {
            // Show the actual error message for debugging
            if let networkError = error as? NetworkError {
                viewModel.errorMessage = "Failed to create chat session: \(networkError.localizedDescription)"
            } else {
                viewModel.errorMessage = "Failed to create chat session: \(error.localizedDescription)"
            }
            viewModel.showError = true
            
            // Also log to console for debugging
            print("❌ Create session error: \(error)")
        }
    }
}

// MARK: - SessionRow
private struct SessionRow: View {
    let session: ChatSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.primary)
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(session.displayTitle)
                        .font(Theme.Typography.body.weight(.medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(session.formattedTime)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.gutter)
            .background(Theme.Colors.surface)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - LoadingOverlay
private struct LoadingOverlay: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
            Text("Loading conversations...")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(Theme.Colors.surface)
                .shadow(radius: 4, y: 2)
        )
    }
}

// MARK: - ChatSessionsViewModel
@MainActor
public class ChatSessionsViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var hasMore = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let container: DIContainer
    private let chatService: ChatService
    private var nextCursor: String?
    
    public init(container: DIContainer) {
        self.container = container
        self.chatService = container.chatService
    }
    
    func loadSessions() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        // First try to show cached sessions
        sessions = chatService.getCachedSessions()
        
        do {
            // Fetch fresh sessions from server
            let fetchedSessions = try await chatService.fetchSessions(limit: 20, cursor: nil)
            sessions = fetchedSessions
            hasMore = fetchedSessions.count >= 20
        } catch {
            if sessions.isEmpty {
                errorMessage = "Failed to load conversations"
                showError = true
            }
        }
        
        isLoading = false
    }
    
    func loadMoreSessions() async {
        guard !isLoading && hasMore else { return }
        
        isLoading = true
        
        do {
            let moreSessions = try await chatService.fetchSessions(
                limit: 20,
                cursor: sessions.last?.updatedAt.ISO8601Format()
            )
            sessions.append(contentsOf: moreSessions)
            hasMore = moreSessions.count >= 20
        } catch {
            errorMessage = "Failed to load more conversations"
            showError = true
        }
        
        isLoading = false
    }
    
    func refreshSessions() async {
        nextCursor = nil
        await loadSessions()
    }
    
    func createNewSession() async throws -> ChatSession {
        return try await chatService.createSession(title: nil)
    }
}

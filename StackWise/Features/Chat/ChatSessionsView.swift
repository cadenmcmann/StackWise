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
            .background(Theme.Colors.surface)
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
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

    // MARK: - Sessions List

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(viewModel.sessions) { session in
                    SessionRow(
                        session: session,
                        onTap: {
                            selectedSession = session
                        }
                    )
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
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, Theme.Spacing.sm)
        }
        .background(Theme.Colors.surface)
        .overlay {
            if viewModel.isLoading && viewModel.sessions.isEmpty {
                LoadingOverlay()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Icon with subtle gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.Colors.primary.opacity(0.1),
                                Theme.Colors.primary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)

                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(Theme.Colors.primary)
            }

            VStack(spacing: Theme.Spacing.sm) {
                Text("No Conversations Yet")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("Get personalized guidance on your\nsupplement stack")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await createNewSession()
                }
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("New Chat")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Theme.Colors.primary)
                )
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.surface)
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
            #if DEBUG
            print("❌ Create session error: \(error)")
            #endif
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
                // Compact avatar-style icon
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primary.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.primary)
                }

                // Content
                VStack(alignment: .leading, spacing: 3) {
                    Text(session.displayTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(session.formattedTime)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 14)
            .background(
                // Liquid glass: frosted material fill
                RoundedRectangle(cornerRadius: Theme.Radii.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .background(
                // Subtle tinted under-layer so the material has something to frost over
                RoundedRectangle(cornerRadius: Theme.Radii.lg, style: .continuous)
                    .fill(Theme.Colors.surfaceAlt.opacity(0.55))
            )
            .overlay(
                // Glass edge: gradient border for that reflective rim
                RoundedRectangle(cornerRadius: Theme.Radii.lg, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Theme.Colors.shadow, radius: 6, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radii.lg, style: .continuous))
        }
        .buttonStyle(GlassCardButtonStyle())
    }
}

// MARK: - GlassCardButtonStyle
/// Subtle scale + brightness shift on press for the glass cards
private struct GlassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1.0)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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
            RoundedRectangle(cornerRadius: Theme.Radii.lg, style: .continuous)
                .fill(Theme.Colors.surface)
                .shadow(color: Theme.Colors.shadow, radius: 8, x: 0, y: 4)
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

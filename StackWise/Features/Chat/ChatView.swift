import SwiftUI

// MARK: - ChatView
public struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(container: container))
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
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                LoadingBubble()
                            }
                        }
                        .padding(Theme.Spacing.gutter)
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                // Input area
                VStack(spacing: Theme.Spacing.md) {
                    // Suggestion chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                SuggestionChip(text: suggestion) {
                                    viewModel.sendSuggestion(suggestion)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.gutter)
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                    
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
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.clearChat()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - MessageBubble
struct MessageBubble: View {
    let message: Message
    
    private var isUser: Bool {
        message.role == .user
    }
    
    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return Theme.Colors.primary
        case .assistant:
            return Theme.Colors.surfaceAlt
        case .system:
            return Theme.Colors.info.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        switch message.role {
        case .user:
            return .white
        case .assistant, .system:
            return Theme.Colors.textPrimary
        }
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: Theme.Spacing.xs) {
                if message.role == .system {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.info)
                        Text("System")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.info)
                    }
                }
                
                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(isUser ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(formatTime(message.createdAt))
                    .font(Theme.Typography.caption)
                    .foregroundColor(
                        isUser ? Color.white.opacity(0.7) : Theme.Colors.textSecondary
                    )
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(
                    cornerRadius: Theme.Radii.lg,
                    style: .continuous
                )
                .fill(backgroundColor)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - LoadingBubble
struct LoadingBubble: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Theme.Colors.textSecondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .opacity(animationPhase == index ? 1.0 : 0.5)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.lg)
                    .fill(Theme.Colors.surfaceAlt)
            )
            
            Spacer()
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever()
            ) {
                animationPhase = (animationPhase + 1) % 3
            }
            
            // Timer to cycle through dots
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

// MARK: - SuggestionChip
struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.primary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radii.xl)
                        .fill(Theme.Colors.primary.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radii.xl)
                        .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

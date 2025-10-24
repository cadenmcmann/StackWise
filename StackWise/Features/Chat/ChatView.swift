import SwiftUI

// MARK: - ChatView
// This is now the main entry point that shows the sessions list
public struct ChatView: View {
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        // No longer need viewModel here as ChatSessionsView handles it
    }
    
    public var body: some View {
        ChatSessionsView(container: container)
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

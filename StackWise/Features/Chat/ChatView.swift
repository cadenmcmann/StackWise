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

// MARK: - Bubble Corner Shape
/// Chat-bubble shape with one "tail" corner kept sharp (like iMessage)
private struct BubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let tail: CGFloat = 4 // small radius for the "tail" corner

        // User: sharp bottom-right. Assistant: sharp bottom-left.
        let topLeft: CGFloat = r
        let topRight: CGFloat = r
        let bottomLeft: CGFloat = isUser ? r : tail
        let bottomRight: CGFloat = isUser ? tail : r

        return Path { p in
            p.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
            p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                      tangent2End: CGPoint(x: rect.maxX, y: rect.minY + topRight),
                      radius: topRight)
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
            p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                      tangent2End: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
                      radius: bottomRight)
            p.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
            p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                      tangent2End: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
                      radius: bottomLeft)
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
            p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                      tangent2End: CGPoint(x: rect.minX + topLeft, y: rect.minY),
                      radius: topLeft)
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
            return .clear
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
        if message.role == .system {
            systemBubble
        } else {
            chatBubble
        }
    }

    // MARK: - System Message
    private var systemBubble: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.Colors.primary)

            Text(message.text)
                .font(Theme.Typography.subhead)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Theme.Spacing.sm)
    }

    // MARK: - Chat Bubble
    private var chatBubble: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(isUser ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message.createdAt.shortTimeString)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(
                        isUser ? Color.white.opacity(0.6) : Theme.Colors.textSecondary.opacity(0.7)
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                BubbleShape(isUser: isUser)
                    .fill(backgroundColor)
            )
            .background(
                Group {
                    if !isUser {
                        BubbleShape(isUser: isUser)
                            .fill(Theme.Colors.shadow)
                            .offset(y: 1)
                            .blur(radius: 2)
                    }
                }
            )
            .contextMenu {
                if message.role == .assistant {
                    Button {
                        reportMessage()
                    } label: {
                        Label("Report this response", systemImage: "exclamationmark.bubble")
                    }
                }
            }

            if !isUser { Spacer(minLength: 48) }
        }
    }

    private func reportMessage() {
        let subject = "StackWise Chat Content Report"
        let body = "Message ID: \(message.id)\n\nMessage:\n\(message.text)"

        guard
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "mailto:\(AppConfig.supportEmailAddress)?subject=\(encodedSubject)&body=\(encodedBody)")
        else {
            return
        }

        UIApplication.shared.open(url)
    }
}

// MARK: - LoadingBubble
struct LoadingBubble: View {
    @State private var animationPhase = 0
    @State private var animationTimer: Timer?

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Theme.Colors.textSecondary.opacity(0.5))
                        .frame(width: 7, height: 7)
                        .scaleEffect(animationPhase == index ? 1.0 : 0.6)
                        .opacity(animationPhase == index ? 1.0 : 0.4)
                        .animation(
                            .easeInOut(duration: 0.4),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                BubbleShape(isUser: false)
                    .fill(Theme.Colors.surfaceAlt)
            )

            Spacer(minLength: 48)
        }
        .onAppear {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
}

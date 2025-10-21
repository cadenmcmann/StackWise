import SwiftUI

// MARK: - LoadingView
public struct LoadingView: View {
    let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.surface.opacity(0.95))
    }
}

// MARK: - SkeletonView
public struct SkeletonView: View {
    @State private var isAnimating = false
    let height: CGFloat
    let cornerRadius: CGFloat
    
    public init(height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Theme.Colors.surfaceAlt)
            .frame(height: height)
            .overlay(
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Theme.Colors.surfaceAlt,
                                    Theme.Colors.surfaceAlt.opacity(0.4),
                                    Theme.Colors.surfaceAlt
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.3)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.3)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - CardSkeleton
public struct CardSkeleton: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Title
            SkeletonView(height: 24, cornerRadius: Theme.Radii.sm)
                .frame(width: 200)
            
            // Subtitle
            SkeletonView(height: 16, cornerRadius: Theme.Radii.sm)
                .frame(width: 150)
            
            // Tags
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonView(height: 28, cornerRadius: Theme.Radii.sm)
                        .frame(width: 60)
                }
            }
            
            // Content lines
            VStack(spacing: Theme.Spacing.sm) {
                SkeletonView(height: 14, cornerRadius: Theme.Radii.sm)
                SkeletonView(height: 14, cornerRadius: Theme.Radii.sm)
                    .frame(maxWidth: 250)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .fill(Theme.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - MessageBubbleSkeleton
public struct MessageBubbleSkeleton: View {
    let isUser: Bool
    
    public init(isUser: Bool = false) {
        self.isUser = isUser
    }
    
    public var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: Theme.Spacing.xs) {
                SkeletonView(height: 16, cornerRadius: Theme.Radii.sm)
                    .frame(width: 200)
                SkeletonView(height: 16, cornerRadius: Theme.Radii.sm)
                    .frame(width: 150)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.lg)
                    .fill(isUser ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.surfaceAlt)
            )
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal, Theme.Spacing.gutter)
    }
}

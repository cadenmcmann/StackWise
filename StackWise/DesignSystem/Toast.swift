import SwiftUI

// MARK: - Toast
public struct Toast: View {
    public enum ToastType {
        case success
        case info
        case error
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return Theme.Colors.success
            case .info: return Theme.Colors.info
            case .error: return Theme.Colors.danger
            }
        }
    }
    
    let message: String
    let type: ToastType
    
    public init(message: String, type: ToastType = .info) {
        self.message = message
        self.type = type
    }
    
    public var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.color)
            
            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(Theme.Colors.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .padding(.horizontal, Theme.Spacing.gutter)
    }
}

// MARK: - ToastModifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let type: Toast.ToastType
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Toast(message: message, type: type)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(Theme.Animation.quick) {
                                    isShowing = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .padding(.top, 50) // Account for safe area
            }
        }
    }
}

// MARK: - View Extension
public extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        type: Toast.ToastType = .info,
        duration: Double = 3.0
    ) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            type: type,
            duration: duration
        ))
    }
}

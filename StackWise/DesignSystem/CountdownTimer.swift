import SwiftUI

// MARK: - CountdownTimer
/// A countdown timer component for verification code expiration with resend functionality
public struct CountdownTimer: View {
    @State private var timeRemaining: Int
    @State private var isResendDisabled = true
    @State private var resendCooldown = 0
    
    let expirationTime: Int // in seconds
    let resendCooldownTime: Int // in seconds
    let onResend: () async -> Void
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init(
        expirationTime: Int = 600, // 10 minutes
        resendCooldownTime: Int = 30,
        onResend: @escaping () async -> Void
    ) {
        self.expirationTime = expirationTime
        self.resendCooldownTime = resendCooldownTime
        self.onResend = onResend
        self._timeRemaining = State(initialValue: expirationTime)
    }
    
    public var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Expiration timer
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text("Code expires in \(formattedTime(timeRemaining))")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Resend button
            Button {
                Task {
                    await handleResend()
                }
            } label: {
                if resendCooldown > 0 {
                    Text("Resend code (\(resendCooldown)s)")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                } else {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                        Text("Resend code")
                            .font(Theme.Typography.body)
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
            }
            .disabled(isResendDisabled || resendCooldown > 0)
        }
        .onReceive(timer) { _ in
            updateTimers()
        }
        .onAppear {
            // Enable resend after initial delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isResendDisabled = false
            }
        }
    }
    
    private func updateTimers() {
        // Update expiration timer
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        
        // Update resend cooldown
        if resendCooldown > 0 {
            resendCooldown -= 1
        }
    }
    
    private func handleResend() async {
        // Start cooldown
        resendCooldown = resendCooldownTime
        
        // Reset expiration timer
        timeRemaining = expirationTime
        
        // Call the resend handler
        await onResend()
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Preview
struct CountdownTimer_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            // Default timer
            CountdownTimer {
                print("Resend code tapped")
            }
            
            // Timer with shorter durations for preview
            CountdownTimer(
                expirationTime: 60,
                resendCooldownTime: 10
            ) {
                print("Resend code tapped")
            }
        }
        .padding(Theme.Spacing.gutter)
    }
}

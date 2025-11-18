import SwiftUI

// MARK: - VerificationCodeInput
/// A 6-digit verification code input component with individual boxes
public struct VerificationCodeInput: View {
    @Binding var code: String
    @State private var digits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    
    var onComplete: ((String) -> Void)?
    var isError: Bool = false
    
    public init(code: Binding<String>, isError: Bool = false, onComplete: ((String) -> Void)? = nil) {
        self._code = code
        self.isError = isError
        self.onComplete = onComplete
    }
    
    public var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(0..<6) { index in
                digitBox(at: index)
            }
        }
        .onAppear {
            // If code is pre-filled, update digits
            if !code.isEmpty {
                updateDigitsFromCode()
            }
        }
        .onChange(of: code) { _, newValue in
            if newValue.isEmpty {
                // Clear all digits if code is cleared
                digits = Array(repeating: "", count: 6)
            }
        }
    }
    
    private func digitBox(at index: Int) -> some View {
        TextField("", text: $digits[index])
            .font(Theme.Typography.titleL)
            .multilineTextAlignment(.center)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .fill(isError ? Theme.Colors.danger.opacity(0.1) : Theme.Colors.surfaceAlt)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .stroke(
                        isError ? Theme.Colors.danger :
                        (focusedIndex == index ? Theme.Colors.primary : Theme.Colors.border),
                        lineWidth: focusedIndex == index ? 2 : 1
                    )
            )
            .keyboardType(.numberPad)
            .focused($focusedIndex, equals: index)
            .onChange(of: digits[index]) { oldValue, newValue in
                handleDigitChange(at: index, oldValue: oldValue, newValue: newValue)
            }
            .onSubmit {
                // Move to next field on submit
                if index < 5 {
                    focusedIndex = index + 1
                }
            }
    }
    
    private func handleDigitChange(at index: Int, oldValue: String, newValue: String) {
        // Handle paste
        if newValue.count > 1 {
            handlePaste(newValue)
            return
        }
        
        // Only allow single digit
        if newValue.count > 1 {
            digits[index] = String(newValue.last ?? Character(""))
        }
        
        // Only allow numbers
        if !newValue.isEmpty && !newValue.allSatisfy({ $0.isNumber }) {
            digits[index] = oldValue
            return
        }
        
        // Auto-advance to next field
        if newValue.count == 1 && index < 5 {
            focusedIndex = index + 1
        }
        
        // Auto-go back on delete
        if newValue.isEmpty && oldValue.count == 1 && index > 0 {
            focusedIndex = index - 1
        }
        
        // Update the binding
        updateCodeFromDigits()
        
        // Check if complete
        if digits.allSatisfy({ !$0.isEmpty }) {
            let fullCode = digits.joined()
            onComplete?(fullCode)
        }
    }
    
    private func handlePaste(_ pastedText: String) {
        // Extract only numbers from pasted text
        let numbers = pastedText.filter { $0.isNumber }
        
        // Fill digits with pasted numbers (up to 6)
        for (index, char) in numbers.prefix(6).enumerated() {
            digits[index] = String(char)
        }
        
        // Clear remaining digits
        for index in numbers.count..<6 {
            digits[index] = ""
        }
        
        // Update the binding
        updateCodeFromDigits()
        
        // Focus the appropriate field
        if numbers.count >= 6 {
            focusedIndex = 5
            let fullCode = digits.joined()
            onComplete?(fullCode)
        } else if numbers.count > 0 {
            focusedIndex = min(numbers.count, 5)
        }
    }
    
    private func updateCodeFromDigits() {
        code = digits.joined()
    }
    
    private func updateDigitsFromCode() {
        let codeArray = Array(code.prefix(6))
        for index in 0..<6 {
            if index < codeArray.count {
                digits[index] = String(codeArray[index])
            } else {
                digits[index] = ""
            }
        }
    }
}

// MARK: - Preview
struct VerificationCodeInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Normal state
            VerificationCodeInput(code: .constant(""))
            
            // Error state
            VerificationCodeInput(code: .constant("123456"), isError: true)
        }
        .padding(Theme.Spacing.gutter)
    }
}

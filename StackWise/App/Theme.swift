import SwiftUI

// MARK: - Theme
/// Centralized design tokens for consistent styling across the app
public struct Theme {
    
    // MARK: - Colors
    public struct Colors {
        static let primary = Color(red: 0.0, green: 0.478, blue: 1.0) // Clinical blue
        static let primaryMuted = Color(red: 0.4, green: 0.6, blue: 1.0)
        static let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.118)
        static let textSecondary = Color(red: 0.557, green: 0.557, blue: 0.576)
        static let surface = Color.white
        static let surfaceAlt = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let border = Color(red: 0.878, green: 0.878, blue: 0.878)
        static let info = Color(red: 0.0, green: 0.478, blue: 1.0)
        static let warning = Color(red: 1.0, green: 0.584, blue: 0.0)
        static let danger = Color(red: 1.0, green: 0.231, blue: 0.188)
        static let success = Color(red: 0.196, green: 0.843, blue: 0.294)
        static let disabled = Color(red: 0.776, green: 0.776, blue: 0.784)
    }
    
    // MARK: - Radii
    public struct Radii {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Spacing
    public struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let gutter: CGFloat = 16 // Screen edge padding
    }
    
    // MARK: - Typography
    public struct Typography {
        static let titleXL = Font.system(size: 34, weight: .bold, design: .default)
        static let titleL = Font.system(size: 28, weight: .semibold, design: .default)
        static let titleM = Font.system(size: 22, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let subhead = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
    }
    
    // MARK: - Animation
    public struct Animation {
        static var standard: SwiftUI.Animation {
            guard !UIAccessibility.isReduceMotionEnabled else {
                return .easeInOut(duration: 0.15)
            }
            return .spring(response: 0.3, dampingFraction: 0.8)
        }
        
        static var quick: SwiftUI.Animation {
            guard !UIAccessibility.isReduceMotionEnabled else {
                return .easeInOut(duration: 0.1)
            }
            return .easeInOut(duration: 0.2)
        }
    }
}

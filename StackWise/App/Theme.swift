import SwiftUI

// MARK: - Adaptive Color Extension
/// Creates a Color that automatically adapts to light/dark mode
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    init(lightHex: UInt, darkHex: UInt) {
        self.init(
            light: Color(hex: lightHex),
            dark: Color(hex: darkHex)
        )
    }
    
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Theme
/// Centralized design tokens for consistent styling across the app
public struct Theme {
    
    // MARK: - Colors
    /// Adaptive color palette that automatically responds to light/dark mode
    public struct Colors {
        // Primary brand color - clinical blue
        // Light: #007AFF, Dark: #0A84FF (iOS system blue for dark mode - slightly brighter)
        static let primary = Color(
            light: Color(red: 0.0, green: 0.478, blue: 1.0),
            dark: Color(red: 0.039, green: 0.518, blue: 1.0)
        )
        
        // Muted primary for subtle accents
        static let primaryMuted = Color(
            light: Color(red: 0.4, green: 0.6, blue: 1.0),
            dark: Color(red: 0.35, green: 0.55, blue: 0.95)
        )
        
        // Primary text - high contrast
        // Light: Near black #1C1C1E, Dark: White #FFFFFF
        static let textPrimary = Color(
            light: Color(red: 0.11, green: 0.11, blue: 0.118),
            dark: Color.white
        )
        
        // Secondary text - medium contrast
        // Light: #8E8E93, Dark: #8E8E93 (works well in both modes)
        static let textSecondary = Color(
            light: Color(red: 0.557, green: 0.557, blue: 0.576),
            dark: Color(red: 0.557, green: 0.557, blue: 0.576)
        )
        
        // Main background surface
        // Light: White #FFFFFF, Dark: True black #000000 (OLED friendly)
        static let surface = Color(
            light: Color.white,
            dark: Color.black
        )
        
        // Elevated/alternate surface for cards, inputs
        // Light: Off-white #FAFAFA, Dark: Elevated dark #1C1C1E
        static let surfaceAlt = Color(
            light: Color(red: 0.98, green: 0.98, blue: 0.98),
            dark: Color(red: 0.11, green: 0.11, blue: 0.118)
        )
        
        // Borders and dividers
        // Light: #E0E0E0, Dark: #38383A
        static let border = Color(
            light: Color(red: 0.878, green: 0.878, blue: 0.878),
            dark: Color(red: 0.22, green: 0.22, blue: 0.227)
        )
        
        // Semantic colors with adaptive variants
        // Info - same as primary
        static let info = Color(
            light: Color(red: 0.0, green: 0.478, blue: 1.0),
            dark: Color(red: 0.039, green: 0.518, blue: 1.0)
        )
        
        // Warning - orange
        // Light: #FF9500, Dark: #FF9F0A (slightly brighter for dark mode)
        static let warning = Color(
            light: Color(red: 1.0, green: 0.584, blue: 0.0),
            dark: Color(red: 1.0, green: 0.624, blue: 0.039)
        )
        
        // Danger/Error - red
        // Light: #FF3B30, Dark: #FF453A
        static let danger = Color(
            light: Color(red: 1.0, green: 0.231, blue: 0.188),
            dark: Color(red: 1.0, green: 0.271, blue: 0.227)
        )
        
        // Success - green
        // Light: #32D74B, Dark: #30D158
        static let success = Color(
            light: Color(red: 0.196, green: 0.843, blue: 0.294),
            dark: Color(red: 0.188, green: 0.82, blue: 0.345)
        )
        
        // Disabled state
        // Light: #C6C6C8, Dark: #48484A
        static let disabled = Color(
            light: Color(red: 0.776, green: 0.776, blue: 0.784),
            dark: Color(red: 0.282, green: 0.282, blue: 0.29)
        )
        
        // MARK: - Shadow Colors
        /// Adaptive shadow color - darker in light mode, subtle glow in dark mode
        static let shadow = Color(
            light: Color.black.opacity(0.08),
            dark: Color.white.opacity(0.04)
        )
        
        /// Stronger shadow for elevated elements
        static let shadowStrong = Color(
            light: Color.black.opacity(0.15),
            dark: Color.white.opacity(0.08)
        )
        
        // MARK: - Apple Sign In Button Colors
        /// Per Apple HIG: black button in light mode, white button in dark mode
        static let appleButtonBackground = Color(
            light: Color.black,
            dark: Color.white
        )
        
        /// Per Apple HIG: white text in light mode, black text in dark mode
        static let appleButtonForeground = Color(
            light: Color.white,
            dark: Color.black
        )
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

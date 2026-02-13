import SwiftUI

// MARK: - View Extensions
public extension View {
    /// Applies conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Hides keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions
public extension Color {
    /// Creates a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions
public extension Date {
    /// Returns start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns end of day
    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }
    
    /// Checks if date is in the same day as another date
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

// MARK: - Date Formatting
public enum DateFormatting {
    // Cached formatters (expensive to create, safe to reuse)
    
    /// API date format: "2025-01-15"
    public static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// ISO8601 with fractional seconds for API timestamps
    public static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Short time: "8:00 AM"
    public static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Short weekday: "Mon"
    public static let shortWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    /// Day number: "15"
    public static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    /// Full date: "Monday, Jan 15"
    public static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    /// Month day: "Jan 15"
    public static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    /// Month year: "Jan 2025"
    public static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
}

// MARK: - Date Formatting Extensions
public extension Date {
    /// Format for API: "2025-01-15"
    var apiDateString: String {
        DateFormatting.apiDateFormatter.string(from: self)
    }
    
    /// Format as short time: "8:00 AM"
    var shortTimeString: String {
        DateFormatting.shortTimeFormatter.string(from: self)
    }
    
    /// Format as short weekday: "Mon"
    var shortWeekday: String {
        DateFormatting.shortWeekdayFormatter.string(from: self)
    }
    
    /// Format as day number: "15"
    var dayNumber: String {
        DateFormatting.dayNumberFormatter.string(from: self)
    }
    
    /// Format as full date: "Monday, Jan 15"
    var fullDateString: String {
        DateFormatting.fullDateFormatter.string(from: self)
    }
    
    /// Format as month day: "Jan 15"
    var monthDayString: String {
        DateFormatting.monthDayFormatter.string(from: self)
    }
    
    /// Format as month year: "Jan 2025"
    var monthYearString: String {
        DateFormatting.monthYearFormatter.string(from: self)
    }
}

// MARK: - String Extensions
public extension String {
    /// Returns trimmed string
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Checks if string is valid email
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Parse API date string to Date
    var apiDate: Date? {
        DateFormatting.apiDateFormatter.date(from: self)
    }
    
    /// Parse ISO8601 string to Date
    var iso8601Date: Date? {
        DateFormatting.iso8601Formatter.date(from: self)
    }
}

// MARK: - Collection Extensions
public extension Collection {
    /// Safe subscript
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

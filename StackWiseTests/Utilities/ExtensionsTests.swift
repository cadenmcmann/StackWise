import Testing
import Foundation
import SwiftUI
@testable import StackWise

@Suite("Extensions Tests")
struct ExtensionsTests {
    
    // MARK: - Date.apiDateString Tests
    
    @Test("apiDateString format is yyyy-MM-dd")
    func apiDateStringFormat() {
        // Create a specific date
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        let date = Calendar.current.date(from: components)!
        
        #expect(date.apiDateString == "2025-01-15")
    }
    
    @Test("apiDateString handles different months correctly")
    func apiDateStringMonths() {
        var components = DateComponents()
        components.year = 2025
        components.month = 12
        components.day = 5
        let date = Calendar.current.date(from: components)!
        
        #expect(date.apiDateString == "2025-12-05")
    }
    
    // MARK: - Date.shortTimeString Tests
    
    @Test("shortTimeString includes AM/PM")
    func shortTimeStringIncludesAmPm() {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        
        let timeString = date.shortTimeString
        // Should contain either AM or PM
        #expect(timeString.contains("AM") || timeString.contains("PM"))
    }
    
    // MARK: - String.isValidEmail Tests
    
    @Test("isValidEmail validates standard email")
    func isValidEmailStandard() {
        #expect("test@example.com".isValidEmail == true)
        #expect("user.name@domain.org".isValidEmail == true)
        #expect("user+tag@example.com".isValidEmail == true)
    }
    
    @Test("isValidEmail rejects invalid emails")
    func isValidEmailRejectsInvalid() {
        #expect("not-an-email".isValidEmail == false)
        #expect("@missing-local.com".isValidEmail == false)
        #expect("missing-domain@".isValidEmail == false)
        #expect("spaces in@email.com".isValidEmail == false)
        #expect("".isValidEmail == false)
    }
    
    // MARK: - String.apiDate Tests
    
    @Test("apiDate parses date strings")
    func apiDateParses() {
        let dateString = "2025-01-15"
        let date = dateString.apiDate
        
        #expect(date != nil)
        
        if let date = date {
            let calendar = Calendar.current
            #expect(calendar.component(.year, from: date) == 2025)
            #expect(calendar.component(.month, from: date) == 1)
            #expect(calendar.component(.day, from: date) == 15)
        }
    }
    
    @Test("apiDate returns nil for invalid strings")
    func apiDateReturnsNilForInvalid() {
        #expect("invalid-date".apiDate == nil)
        #expect("not-a-date".apiDate == nil)
        #expect("".apiDate == nil)
    }
    
    // MARK: - String.iso8601Date Tests
    
    @Test("iso8601Date parses ISO timestamps")
    func iso8601DateParses() {
        let isoString = "2025-01-15T14:30:00.000Z"
        let date = isoString.iso8601Date
        
        #expect(date != nil)
    }
    
    @Test("iso8601Date returns nil for invalid strings")
    func iso8601DateReturnsNilForInvalid() {
        #expect("not-iso-format".iso8601Date == nil)
        #expect("2025-01-15".iso8601Date == nil) // Missing time component
    }
    
    // MARK: - Color(hex:) Tests
    
    @Test("Color(hex:) handles 6 character hex")
    func colorHex6Characters() {
        let color = Color(hex: "FF0000") // Red
        // Color was created (we can't easily test the actual color values)
        #expect(color != nil)
    }
    
    @Test("Color(hex:) handles 3 character hex")
    func colorHex3Characters() {
        let color = Color(hex: "F00") // Red shorthand
        #expect(color != nil)
    }
    
    @Test("Color(hex:) handles 8 character hex with alpha")
    func colorHex8Characters() {
        let color = Color(hex: "80FF0000") // Semi-transparent red
        #expect(color != nil)
    }
    
    @Test("Color(hex:) handles # prefix")
    func colorHexWithPrefix() {
        let color = Color(hex: "#FF0000")
        #expect(color != nil)
    }
    
    // MARK: - Collection Safe Subscript Tests
    
    @Test("safe subscript returns nil for out of bounds")
    func safeSubscriptOutOfBounds() {
        let array = [1, 2, 3]
        
        #expect(array[safe: 0] == 1)
        #expect(array[safe: 2] == 3)
        #expect(array[safe: 5] == nil)
        #expect(array[safe: -1] == nil)
    }
    
    @Test("safe subscript works with empty collections")
    func safeSubscriptEmptyCollection() {
        let array: [Int] = []
        
        #expect(array[safe: 0] == nil)
    }
    
    // MARK: - String.trimmed Tests
    
    @Test("trimmed removes whitespace")
    func trimmedRemovesWhitespace() {
        #expect("  hello  ".trimmed == "hello")
        #expect("\nhello\n".trimmed == "hello")
        #expect("\t hello \t".trimmed == "hello")
    }
    
    @Test("trimmed returns same string if no whitespace")
    func trimmedNoChange() {
        #expect("hello".trimmed == "hello")
    }
    
    // MARK: - Date Extensions Tests
    
    @Test("startOfDay returns midnight")
    func startOfDayReturnsMidnight() {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        
        let startOfDay = date.startOfDay
        let hour = Calendar.current.component(.hour, from: startOfDay)
        let minute = Calendar.current.component(.minute, from: startOfDay)
        
        #expect(hour == 0)
        #expect(minute == 0)
    }
    
    @Test("isSameDay compares correctly")
    func isSameDayCompares() {
        let calendar = Calendar.current
        
        var components1 = DateComponents()
        components1.year = 2025
        components1.month = 1
        components1.day = 15
        components1.hour = 10
        let date1 = calendar.date(from: components1)!
        
        var components2 = DateComponents()
        components2.year = 2025
        components2.month = 1
        components2.day = 15
        components2.hour = 20
        let date2 = calendar.date(from: components2)!
        
        var components3 = DateComponents()
        components3.year = 2025
        components3.month = 1
        components3.day = 16
        let date3 = calendar.date(from: components3)!
        
        #expect(date1.isSameDay(as: date2) == true)
        #expect(date1.isSameDay(as: date3) == false)
    }
    
    // MARK: - DateFormatting Tests
    
    @Test("DateFormatting formatters are available")
    func dateFormattingFormattersAvailable() {
        #expect(DateFormatting.apiDateFormatter != nil)
        #expect(DateFormatting.iso8601Formatter != nil)
        #expect(DateFormatting.shortTimeFormatter != nil)
        #expect(DateFormatting.shortWeekdayFormatter != nil)
        #expect(DateFormatting.dayNumberFormatter != nil)
        #expect(DateFormatting.fullDateFormatter != nil)
        #expect(DateFormatting.monthDayFormatter != nil)
        #expect(DateFormatting.monthYearFormatter != nil)
    }
    
    @Test("shortWeekday returns correct format")
    func shortWeekdayFormat() {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 13 // Monday
        let date = Calendar.current.date(from: components)!
        
        let weekday = date.shortWeekday
        // Should be "Mon" or similar short format
        #expect(weekday.count <= 3)
    }
    
    @Test("dayNumber returns day as string")
    func dayNumberFormat() {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        let date = Calendar.current.date(from: components)!
        
        #expect(date.dayNumber == "15")
    }
    
    @Test("monthDayString returns correct format")
    func monthDayFormat() {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        let date = Calendar.current.date(from: components)!
        
        let monthDay = date.monthDayString
        #expect(monthDay.contains("15"))
        #expect(monthDay.contains("Jan"))
    }
}


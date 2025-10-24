import Foundation
import PDFKit
import EventKit

// MARK: - MockExportService
public class MockExportService: ExportService {
    
    public init() {}
    
    public func generateRegimenPDF(stack: Stack, user: User) async throws -> URL {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create a simple PDF document
        let pdfDocument = PDFDocument()
        let page = PDFPage()
        
        // Create content
        let bounds = page.bounds(for: .mediaBox)
        let textRect = CGRect(x: 50, y: bounds.height - 100, width: bounds.width - 100, height: bounds.height - 150)
        
        let content = createPDFContent(stack: stack, user: user)
        
        // Draw content
        let annotation = PDFAnnotation(bounds: textRect, forType: .freeText, withProperties: nil)
        annotation.contents = content
        annotation.font = .systemFont(ofSize: 12)
        annotation.fontColor = .black
        annotation.color = .clear
        page.addAnnotation(annotation)
        
        pdfDocument.insert(page, at: 0)
        
        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "StackWise_Regimen_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        pdfDocument.write(to: fileURL)
        
        return fileURL
    }
    
    public func generateCalendarICS(reminders: [Reminder]) async throws -> URL {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Create ICS content
        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//StackWise//Supplement Schedule//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        """
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        for reminder in reminders where reminder.enabled {
            let uid = UUID().uuidString
            let dtstart = dateFormatter.string(from: reminder.timeOfDay)
            let dtend = dateFormatter.string(from: reminder.timeOfDay.addingTimeInterval(900)) // 15 minutes later
            
            icsContent += """
            
            BEGIN:VEVENT
            UID:\(uid)@stackwise.app
            DTSTART:\(dtstart)
            DTEND:\(dtend)
            RRULE:FREQ=DAILY
            SUMMARY:Take supplement: \(reminder.supplementId)
            DESCRIPTION:Time to take your \(reminder.supplementId) supplement
            BEGIN:VALARM
            TRIGGER:-PT5M
            ACTION:DISPLAY
            DESCRIPTION:Supplement reminder
            END:VALARM
            END:VEVENT
            """
        }
        
        icsContent += "\nEND:VCALENDAR"
        
        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "StackWise_Schedule_\(Date().timeIntervalSince1970).ics"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try icsContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
    
    private func createPDFContent(stack: Stack, user: User) -> String {
        var content = """
        STACKWISE SUPPLEMENT REGIMEN
        Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none))
        
        USER PROFILE
        Age: \(user.age)
        Sex: \(user.sex.rawValue)
        Height: \(user.height) cm
        Weight: \(user.weight) kg
        Stimulant Tolerance: \(user.stimulantTolerance.rawValue)
        Budget: $\(Int(user.budgetPerMonth))/month
        
        MINIMAL STACK
        """
        
        for supplement in stack.minimal {
            let timingText = supplement.schedule?.times.joined(separator: ", ") ?? "As needed"
            content += """
            
            • \(supplement.name)
              Purpose: \(supplement.purposeShort ?? supplement.rationale)
              Dose: \(supplement.doseRangeText)
              Timing: \(timingText)
            """
            if let formNote = supplement.formNote {
                content += "\n  Form: \(formNote)"
            }
        }
        
        if !stack.addons.isEmpty {
            content += "\n\nOPTIONAL ADD-ONS"
            for supplement in stack.addons {
                let timingText = supplement.schedule?.times.joined(separator: ", ") ?? "As needed"
                content += """
                
                • \(supplement.name)
                  Purpose: \(supplement.purposeShort ?? supplement.rationale)
                  Dose: \(supplement.doseRangeText)
                  Timing: \(timingText)
                """
            }
        }
        
        content += """
        
        
        DISCLAIMER
        This information is for educational purposes only and is not medical advice.
        Please consult with a healthcare professional before starting any supplement regimen.
        """
        
        return content
    }
}

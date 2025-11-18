import Foundation
import Combine

// MARK: - IntakeLogManager
/// Manages supplement intake logging with smart batching and debouncing
@MainActor
public class IntakeLogManager: ObservableObject {
    private let networkManager = NetworkManager.shared
    
    // Tracks the local state of supplements (for immediate UI updates)
    @Published public var localIntakeState: [String: Bool] = [:] // Key: "date|supplementId|time"
    
    // Pending changes to be sent to the API
    private var pendingChanges: [String: IntakeChange] = [:] // Key: "date|supplementId|time"
    
    // Timer for debouncing
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 1.5 // Wait 1.5 seconds after last change
    
    // Track if we're currently sending a request
    private var isSending = false
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Toggle a supplement's taken status with immediate UI update and debounced API call
    public func toggleSupplement(
        supplementId: String,
        time: String,
        date: Date,
        currentState: Bool
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let key = "\(dateString)|\(supplementId)|\(time)"
        let newState = !currentState
        
        // Immediate UI update
        localIntakeState[key] = newState
        
        // Track the change for API
        pendingChanges[key] = IntakeChange(
            date: dateString,
            supplementId: supplementId,
            time: time,
            taken: newState
        )
        
        // Reset the debounce timer
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sendPendingChanges()
            }
        }
    }
    
    /// Get the current state of a supplement (checks local state first, then provided state)
    public func isSupplementTaken(
        supplementId: String,
        time: String,
        date: Date,
        apiState: Bool
    ) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let key = "\(dateString)|\(supplementId)|\(time)"
        
        // Return local state if we have it (user has toggled), otherwise use API state
        return localIntakeState[key] ?? apiState
    }
    
    /// Sync local state with API data (call when loading new data)
    public func syncWithAPIData(_ weeklyData: WeeklyIntakeResponse) {
        // Preserve pending changes - don't overwrite local state for items we're about to send
        let pendingKeys = Set(pendingChanges.keys)
        
        // Update local state with API data, but preserve pending changes
        for dayData in weeklyData.weekData {
            for supplement in dayData.stackIntakeData {
                let key = "\(dayData.date)|\(supplement.supplementId)|\(supplement.time)"
                
                // Only update if we don't have a pending change for this item
                if !pendingKeys.contains(key) {
                    localIntakeState[key] = supplement.taken
                }
            }
        }
        
        // Remove any stale local state that's not in API data and not pending
        // This prevents memory leaks from old data
        let apiKeys = Set(weeklyData.weekData.flatMap { dayData in
            dayData.stackIntakeData.map { supplement in
                "\(dayData.date)|\(supplement.supplementId)|\(supplement.time)"
            }
        })
        
        let keysToRemove = localIntakeState.keys.filter { key in
            !apiKeys.contains(key) && !pendingKeys.contains(key)
        }
        
        for key in keysToRemove {
            localIntakeState.removeValue(forKey: key)
        }
    }
    
    /// Force send any pending changes (useful when leaving a screen)
    public func flushPendingChanges() async {
        debounceTimer?.invalidate()
        await sendPendingChanges()
    }
    
    // MARK: - Private Methods
    
    private func sendPendingChanges() async {
        guard !pendingChanges.isEmpty, !isSending else { return }
        
        isSending = true
        defer { isSending = false }
        
        // Group changes by date
        let changesByDate = Dictionary(grouping: pendingChanges.values) { $0.date }
        
        // Send batch requests for each date
        for (date, changes) in changesByDate {
            await sendBatchForDate(date: date, changes: changes)
        }
        
        // Clear pending changes after sending
        pendingChanges.removeAll()
    }
    
    private func sendBatchForDate(date: String, changes: [IntakeChange]) async {
        // Create the batch request
        let entries = changes.map { change in
            IntakeLogEntry(
                supplementId: change.supplementId,
                time: change.time,
                taken: change.taken
            )
        }
        
        let request = IntakeLogRequest(date: date, entries: entries)
        
        do {
            // Send to API
            let _ = try await networkManager.request(
                endpoint: "intake/log",
                method: "POST",
                body: request,
                requiresAuth: true,
                responseType: IntakeLogResponse.self
            )
            
            print("Successfully logged \(entries.count) entries for \(date)")
        } catch {
            print("Failed to log intake: \(error)")
            
            // On failure, revert local state for these changes
            for change in changes {
                let key = "\(date)|\(change.supplementId)|\(change.time)"
                // Toggle back to opposite of what we tried to set
                localIntakeState[key] = !change.taken
            }
        }
    }
}

// MARK: - Supporting Types

private struct IntakeChange {
    let date: String
    let supplementId: String
    let time: String
    let taken: Bool
}

// MARK: - API Request/Response Models

struct IntakeLogEntry: Codable {
    let supplementId: String
    let time: String
    let taken: Bool
}

struct IntakeLogRequest: Codable {
    let date: String
    let entries: [IntakeLogEntry]
}

struct IntakeLogResponse: Codable {
    let log: IntakeLog
    let message: String
}

struct IntakeLog: Codable {
    let id: String
    let userId: String
    let stackId: String?
    let date: String
    let createdAt: String
    let entries: [IntakeLogEntryResponse]
}

struct IntakeLogEntryResponse: Codable {
    let supplementId: String
    let time: String
}

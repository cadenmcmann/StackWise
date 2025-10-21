import Foundation

// MARK: - Supplement
public struct Supplement: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let purpose: String
    public let doseRangeText: String
    public let formNote: String?
    public let timingTag: TimingTag?
    public let evidenceLevel: EvidenceLevel?
    public let flags: Set<SupplementFlag>
    public let citations: [Citation]
    public let rationale: String
    // New API fields
    public let schedule: SupplementSchedule?
    public let tags: [String]
    
    public enum TimingTag: String, Codable, CaseIterable {
        case morning = "AM"
        case noon = "Lunch"
        case evening = "PM"
        case night = "Night"
    }
    
    public enum EvidenceLevel: String, Codable, CaseIterable {
        case a = "A"
        case b = "B"
        case c = "C"
        
        public var description: String {
            switch self {
            case .a: return "Strong evidence"
            case .b: return "Moderate evidence"
            case .c: return "Emerging evidence"
            }
        }
    }
    
    public enum SupplementFlag: String, Codable {
        case vegan = "Vegan"
        case stimulantFree = "Stimulant-Free"
        case thirdPartyTested = "3rd Party Tested"
    }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        purpose: String,
        doseRangeText: String,
        formNote: String? = nil,
        timingTag: TimingTag? = nil,
        evidenceLevel: EvidenceLevel? = nil,
        flags: Set<SupplementFlag> = [],
        citations: [Citation] = [],
        rationale: String = "",
        schedule: SupplementSchedule? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.purpose = purpose
        self.doseRangeText = doseRangeText
        self.formNote = formNote
        self.timingTag = timingTag
        self.evidenceLevel = evidenceLevel
        self.flags = flags
        self.citations = citations
        self.rationale = rationale
        self.schedule = schedule
        self.tags = tags
    }
}

// MARK: - SupplementSchedule
public struct SupplementSchedule: Codable, Equatable {
    public let daysOfWeek: [String]
    public let times: [String]
    
    public init(daysOfWeek: [String], times: [String]) {
        self.daysOfWeek = daysOfWeek
        self.times = times
    }
}

// MARK: - Citation
public struct Citation: Codable, Equatable {
    public let title: String
    public let authors: String
    public let journal: String
    public let year: Int
    public let url: String
    
    public init(title: String, authors: String, journal: String, year: Int, url: String) {
        self.title = title
        self.authors = authors
        self.journal = journal
        self.year = year
        self.url = url
    }
}

// MARK: - Stack
public struct Stack: Codable {
    public let minimal: [Supplement]
    public let addons: [Supplement]
    
    public init(minimal: [Supplement] = [], addons: [Supplement] = []) {
        self.minimal = minimal
        self.addons = addons
    }
    
    public var allSupplements: [Supplement] {
        minimal + addons
    }
}

// MARK: - RemixOptions
public struct RemixOptions: Codable {
    public var fewerPills: Bool
    public var cheaper: Bool
    public var stimulantFree: Bool
    public var athleteMode: Bool
    
    public init(
        fewerPills: Bool = false,
        cheaper: Bool = false,
        stimulantFree: Bool = false,
        athleteMode: Bool = false
    ) {
        self.fewerPills = fewerPills
        self.cheaper = cheaper
        self.stimulantFree = stimulantFree
        self.athleteMode = athleteMode
    }
}

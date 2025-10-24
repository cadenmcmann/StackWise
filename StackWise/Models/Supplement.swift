import Foundation

// MARK: - Supplement
public struct Supplement: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let purposeShort: String?  // 1 sentence overview
    public let purposeLong: String?   // 3-5 sentence overview
    public let scientificFunction: String?  // Scientific explanation
    public let doseRangeText: String
    public let formNote: String?
    public let timingTag: TimingTag?
    public let evidenceLevel: EvidenceLevel?
    public let flags: Set<SupplementFlag>
    public let citations: [Citation]
    public let rationale: String  // Personalized explanation
    public var active: Bool  // Whether supplement is active in stack
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
        purposeShort: String? = nil,
        purposeLong: String? = nil,
        scientificFunction: String? = nil,
        doseRangeText: String,
        formNote: String? = nil,
        timingTag: TimingTag? = nil,
        evidenceLevel: EvidenceLevel? = nil,
        flags: Set<SupplementFlag> = [],
        citations: [Citation] = [],
        rationale: String = "",
        active: Bool = true,
        schedule: SupplementSchedule? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.purposeShort = purposeShort
        self.purposeLong = purposeLong
        self.scientificFunction = scientificFunction
        self.doseRangeText = doseRangeText
        self.formNote = formNote
        self.timingTag = timingTag
        self.evidenceLevel = evidenceLevel
        self.flags = flags
        self.citations = citations
        self.rationale = rationale
        self.active = active
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
    public var minimal: [Supplement]
    public var addons: [Supplement]
    public let id: String?
    
    public init(id: String? = nil, minimal: [Supplement] = [], addons: [Supplement] = []) {
        self.id = id
        self.minimal = minimal
        self.addons = addons
    }
    
    public var allSupplements: [Supplement] {
        minimal + addons
    }
    
    public var activeSupplements: [Supplement] {
        allSupplements.filter { $0.active }
    }
    
    public var inactiveSupplements: [Supplement] {
        allSupplements.filter { !$0.active }
    }
    
    public mutating func toggleSupplementActive(supplementId: String) {
        // Toggle in minimal array
        if let index = minimal.firstIndex(where: { $0.id == supplementId }) {
            minimal[index].active.toggle()
        }
        // Toggle in addons array
        else if let index = addons.firstIndex(where: { $0.id == supplementId }) {
            addons[index].active.toggle()
        }
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

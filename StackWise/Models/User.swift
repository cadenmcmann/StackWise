import Foundation

// MARK: - User
public struct User: Identifiable, Codable {
    public let id: String
    public var age: Int
    public var sex: Sex
    public var height: Double // in cm
    public var weight: Double // in kg
    public var bodyFat: Double?
    public var stimulantTolerance: StimulantTolerance
    public var budgetPerMonth: Double
    public var dietaryPreferences: Set<DietaryPreference>
    
    public enum Sex: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    public enum StimulantTolerance: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    public init(
        id: String = UUID().uuidString,
        age: Int,
        sex: Sex,
        height: Double,
        weight: Double,
        bodyFat: Double? = nil,
        stimulantTolerance: StimulantTolerance,
        budgetPerMonth: Double,
        dietaryPreferences: Set<DietaryPreference> = []
    ) {
        self.id = id
        self.age = age
        self.sex = sex
        self.height = height
        self.weight = weight
        self.bodyFat = bodyFat
        self.stimulantTolerance = stimulantTolerance
        self.budgetPerMonth = budgetPerMonth
        self.dietaryPreferences = dietaryPreferences
    }
}

// MARK: - DietaryPreference
public enum DietaryPreference: String, Codable, CaseIterable {
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case halal = "Halal"
    case kosher = "Kosher"
    case dairyFree = "Dairy-Free"
    case soyFree = "Soy-Free"
    case glutenFree = "Gluten-Free"
}

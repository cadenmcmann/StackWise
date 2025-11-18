import Foundation

// MARK: - User
public struct User: Identifiable, Codable {
    public let id: String
    // New authentication fields
    public var email: String?
    public var phoneNumber: String?
    public var firstName: String?
    public var lastName: String?
    public var createdAt: Date?
    
    // Existing preference fields
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
        case none = "None"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
    }
    
    public init(
        id: String = UUID().uuidString,
        email: String? = nil,
        phoneNumber: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        createdAt: Date? = nil,
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
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        self.age = age
        self.sex = sex
        self.height = height
        self.weight = weight
        self.bodyFat = bodyFat
        self.stimulantTolerance = stimulantTolerance
        self.budgetPerMonth = budgetPerMonth
        self.dietaryPreferences = dietaryPreferences
    }
    
    // Computed property for display name
    public var displayName: String? {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let email = email {
            return email
        }
        return nil
    }
    
    // Computed property for avatar initials
    public var initials: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
        } else if let firstName = firstName {
            return String(firstName.prefix(2)).uppercased()
        } else if let email = email, let firstChar = email.first {
            return String(firstChar).uppercased()
        }
        return "U"
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

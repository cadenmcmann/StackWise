import Foundation

// MARK: - Intake
public struct Intake: Codable {
    public var goals: Set<Goal>
    public var basics: Basics
    public var risks: Set<Risk>
    public var topPriorityText: String
    
    public init(
        goals: Set<Goal> = [],
        basics: Basics = Basics(),
        risks: Set<Risk> = [],
        topPriorityText: String = ""
    ) {
        self.goals = goals
        self.basics = basics
        self.risks = risks
        self.topPriorityText = topPriorityText
    }
}

// MARK: - Goal
public enum Goal: String, Codable, CaseIterable {
    // Energy
    case boostEnergyStimulant = "Boost Energy (caffeine/stimulant)"
    case boostEnergyNonStimulant = "Boost Energy (non-stimulant)"
    
    // Sexual Health
    case boostLibido = "Boost Libido / Sexual Health"
    case boostTestosterone = "Boost Testosterone"
    
    // Muscle & Recovery
    case buildMuscle = "Build Muscle"
    case enhanceRecovery = "Enhance Recovery"
    case increaseStrength = "Increase Strength"
    case reduceMuscularSoreness = "Reduce Muscle Soreness"
    
    // Sleep
    case fallAsleepFaster = "Fall Asleep Faster"
    case improveSleepQuality = "Improve Sleep Quality"
    case wakeRefreshed = "Wake Feeling Refreshed"
    
    // Physical Performance
    case improveEndurance = "Improve Endurance"
    case improveFlexibility = "Improve Flexibility / Mobility"
    
    // Mental Health
    case improveFocus = "Improve Focus / Concentration"
    case improveMood = "Improve Mood"
    case reduceAnxiety = "Reduce Anxiety"
    case reduceStress = "Reduce Stress"
    case supportCalm = "Support Calm / Relaxation"
    case supportMemory = "Support Memory / Learning"
    
    // Health & Wellness
    case improveGutHealth = "Improve Gut Health / Digestion"
    case reduceInflammation = "Reduce Inflammation"
    case strengthenBones = "Strengthen Bones"
    case strengthenNails = "Strengthen Nails"
    case supportHairGrowth = "Support Hair Growth"
    case supportHealthyBloodSugar = "Support Healthy Blood Sugar"
    case supportHealthyEstrogenBalance = "Support Healthy Estrogen Balance"
    case supportHealthyWeightGain = "Support Healthy Weight Gain"
    case supportHeartHealth = "Support Heart Health"
    case supportHormoneHealthGeneral = "Support Hormone Health (general)"
    case supportImmuneFunction = "Support Immune Function"
    case supportJointHealth = "Support Joint Health"
    case supportLiverHealth = "Support Liver Health"
    case supportLongevity = "Support Longevity / Anti-Aging"
    case supportSkinHealth = "Support Skin Health"
    case supportWeightLoss = "Support Weight Loss"
}

// MARK: - Basics
public struct Basics: Codable {
    public var age: Int
    public var sex: User.Sex
    public var height: Double // cm
    public var weight: Double // kg
    public var bodyFat: Double?
    public var stimulantTolerance: User.StimulantTolerance
    public var budgetPerMonth: Double
    public var dietaryPreferences: Set<DietaryPreference>
    
    public init(
        age: Int = 25,
        sex: User.Sex = .other,
        height: Double = 170,
        weight: Double = 70,
        bodyFat: Double? = nil,
        stimulantTolerance: User.StimulantTolerance = .medium,
        budgetPerMonth: Double = 100,
        dietaryPreferences: Set<DietaryPreference> = []
    ) {
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

// MARK: - Risk
public enum Risk: String, Codable, CaseIterable {
    case bloodPressureMeds = "Blood Pressure Medication"
    case bloodThinners = "Blood Thinners"
    case antidepressants = "Antidepressants"
    case anxietyMeds = "Anxiety Medication"
    case diabetesMeds = "Diabetes Medication"
    case thyroidMeds = "Thyroid Medication"
    case heartCondition = "Heart Condition"
    case kidneyDisease = "Kidney Disease"
    case liverDisease = "Liver Disease"
    case pregnancy = "Pregnancy/Nursing"
    case cancer = "Cancer Treatment"
    case autoimmune = "Autoimmune Condition"
    
    public var warningMessage: String {
        switch self {
        case .bloodPressureMeds:
            return "We'll avoid supplements that may affect blood pressure."
        case .bloodThinners:
            return "We'll exclude supplements with blood-thinning effects."
        case .antidepressants:
            return "We'll avoid supplements that interact with serotonin."
        case .anxietyMeds:
            return "We'll exclude supplements that may affect GABA."
        case .diabetesMeds:
            return "We'll avoid supplements that affect blood sugar."
        case .thyroidMeds:
            return "We'll exclude supplements that interact with thyroid function."
        case .heartCondition:
            return "We'll avoid stimulants and cardiovascular supplements."
        case .kidneyDisease:
            return "We'll limit supplements that are processed by kidneys."
        case .liverDisease:
            return "We'll avoid supplements metabolized by the liver."
        case .pregnancy:
            return "We'll only recommend pregnancy-safe supplements."
        case .cancer:
            return "We'll avoid supplements that may interfere with treatment."
        case .autoimmune:
            return "We'll exclude immune-stimulating supplements."
        }
    }
    
    public var isHardStop: Bool {
        switch self {
        case .pregnancy, .cancer, .kidneyDisease, .liverDisease:
            return true
        default:
            return false
        }
    }
}

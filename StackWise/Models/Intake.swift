import Foundation

// MARK: - Intake
public struct Intake: Codable {
    public var goals: Set<Goal>
    public var basics: Basics
    public var risks: Set<Risk>
    public var topPriorityText: String
    public var isOver18Confirmed: Bool?
    public var acceptsDisclaimerConfirmed: Bool?
    public var consentAcceptedAt: Date?
    
    public init(
        goals: Set<Goal> = [],
        basics: Basics = Basics(),
        risks: Set<Risk> = [],
        topPriorityText: String = "",
        isOver18Confirmed: Bool? = nil,
        acceptsDisclaimerConfirmed: Bool? = nil,
        consentAcceptedAt: Date? = nil
    ) {
        self.goals = goals
        self.basics = basics
        self.risks = risks
        self.topPriorityText = topPriorityText
        self.isOver18Confirmed = isOver18Confirmed
        self.acceptsDisclaimerConfirmed = acceptsDisclaimerConfirmed
        self.consentAcceptedAt = consentAcceptedAt
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
    
    public init(
        age: Int = 0,
        sex: User.Sex = .other,
        height: Double = 0,
        weight: Double = 0,
        bodyFat: Double? = nil,
        stimulantTolerance: User.StimulantTolerance = .moderate
    ) {
        self.age = age
        self.sex = sex
        self.height = height
        self.weight = weight
        self.bodyFat = bodyFat
        self.stimulantTolerance = stimulantTolerance
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
    
}

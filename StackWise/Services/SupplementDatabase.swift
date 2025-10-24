import Foundation

// MARK: - Static Supplement Database
public struct SupplementInfo {
    public let id: String
    public let name: String
    public let purposeShort: String
    public let purposeLong: String
    public let scientificFunction: String
    public let timingTags: [String]
    public let dietaryFlags: [String]
    public let stimulantFree: Bool
    public let citations: [String]
}

public class SupplementDatabase {
    public static let shared = SupplementDatabase()
    
    private let supplements: [String: SupplementInfo]
    
    private init() {
        // Initialize with static supplement data
        let supplementsData: [SupplementInfo] = [
            SupplementInfo(
                id: "8899053c-5d85-434a-996b-4ec6fcbd92cb",
                name: "Creatine Monohydrate",
                purposeShort: "Supports muscle strength, power output, and cognitive function",
                purposeLong: "Creatine monohydrate is one of the most researched supplements for athletic performance. It enhances strength, increases muscle mass, improves high-intensity exercise performance, and may support cognitive function and brain health.",
                scientificFunction: "Creatine increases phosphocreatine stores in muscles, enabling rapid ATP regeneration during high-intensity activities. This provides more immediate energy for muscle contractions during resistance training and explosive movements. It also increases cellular hydration, which may stimulate protein synthesis and muscle growth.",
                timingTags: ["morning", "afternoon"],
                dietaryFlags: ["vegan", "gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            ),
            SupplementInfo(
                id: "85dec638-40b9-4bb5-92c1-ffd2d754f0b8",
                name: "Magnesium Glycinate",
                purposeShort: "Improves sleep quality, supports muscle recovery, and manages stress",
                purposeLong: "Magnesium glycinate is a highly bioavailable form of magnesium that supports relaxation, sleep quality, and muscle recovery. It helps maintain healthy magnesium levels, which are crucial for hundreds of enzymatic processes in the body.",
                scientificFunction: "Magnesium regulates neurotransmitters that promote relaxation and sleep, particularly GABA receptors. It acts as a natural calcium blocker to help muscles relax and supports the parasympathetic nervous system. The glycinate chelate form enhances absorption and reduces digestive discomfort compared to other magnesium forms.",
                timingTags: ["evening", "night"],
                dietaryFlags: ["vegan", "gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            ),
            SupplementInfo(
                id: "eb676f01-7ad2-4349-9665-d586059f774f",
                name: "L-Theanine",
                purposeShort: "Promotes focus, relaxation, and reduces anxiety without sedation",
                purposeLong: "L-Theanine is an amino acid found naturally in tea leaves that promotes calm alertness. It reduces stress and anxiety while maintaining mental clarity and focus, making it ideal for work or study.",
                scientificFunction: "L-Theanine increases alpha brain wave activity associated with relaxed alertness. It modulates neurotransmitters including GABA, serotonin, and dopamine to promote calm without drowsiness. When combined with caffeine, it smooths out stimulant effects while enhancing focus and attention.",
                timingTags: ["morning", "afternoon"],
                dietaryFlags: ["vegan", "gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            ),
            SupplementInfo(
                id: "91728e54-3c5a-42bf-8f88-22ef7233293a",
                name: "Ashwagandha (KSM-66)",
                purposeShort: "Reduces stress, supports hormone balance, and enhances recovery",
                purposeLong: "Ashwagandha is an adaptogenic herb that helps the body manage stress and supports healthy cortisol levels. The KSM-66 extract is the most clinically studied form, shown to reduce anxiety, improve testosterone in men, and enhance physical performance and recovery.",
                scientificFunction: "Ashwagandha modulates the hypothalamic-pituitary-adrenal (HPA) axis to regulate cortisol production and stress response. It acts on GABA receptors to promote relaxation and supports healthy testosterone levels by reducing cortisol interference. The withanolides in KSM-66 extract have neuroprotective and anti-inflammatory properties.",
                timingTags: ["morning", "evening"],
                dietaryFlags: ["vegan", "gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            ),
            SupplementInfo(
                id: "436ed0d2-eebe-430e-9309-2b2e8fb859cc",
                name: "Whey Protein Isolate",
                purposeShort: "Supports muscle protein synthesis and post-workout recovery",
                purposeLong: "Whey protein isolate is a fast-digesting, high-quality protein source that provides all essential amino acids needed for muscle repair and growth. It is filtered to remove most lactose and fat, making it easier to digest while delivering concentrated protein.",
                scientificFunction: "Whey protein is rich in branched-chain amino acids (BCAAs), particularly leucine, which directly triggers muscle protein synthesis through the mTOR pathway. Its rapid digestion and absorption make it ideal for post-workout consumption when muscles are primed for nutrient uptake. The high biological value ensures efficient utilization of amino acids for tissue repair.",
                timingTags: ["afternoon", "morning"],
                dietaryFlags: ["gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            ),
            // Add Vitamin D3 which might be in some stacks
            SupplementInfo(
                id: "vitamin-d3-placeholder",
                name: "Vitamin D3",
                purposeShort: "Supports immune function, bone health, and mood regulation",
                purposeLong: "Vitamin D3 (cholecalciferol) is essential for calcium absorption, bone health, immune system function, and mental well-being. Many people are deficient, especially in winter months or with limited sun exposure.",
                scientificFunction: "Vitamin D3 acts as a hormone in the body, binding to vitamin D receptors found in nearly every cell. It regulates calcium and phosphate absorption in the intestines, modulates immune cell function, and influences the expression of genes involved in cell proliferation and differentiation.",
                timingTags: ["morning"],
                dietaryFlags: ["gluten_free"],
                stimulantFree: true,
                citations: ["https://www.example.com/"]
            )
        ]
        
        // Create lookup dictionary
        var supplementsDict: [String: SupplementInfo] = [:]
        for supplement in supplementsData {
            supplementsDict[supplement.id] = supplement
        }
        self.supplements = supplementsDict
    }
    
    public func getSupplementInfo(by id: String) -> SupplementInfo? {
        return supplements[id]
    }
    
    public func getSupplementInfo(byName name: String) -> SupplementInfo? {
        return supplements.values.first { $0.name == name }
    }
}

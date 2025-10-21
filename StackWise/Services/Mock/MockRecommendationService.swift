import Foundation

// MARK: - MockRecommendationService
public class MockRecommendationService: RecommendationService {
    
    public init() {}
    
    public func generateStack(intake: Intake) async throws -> Stack {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Create mock minimal stack
        var minimal: [Supplement] = []
        
        // Base supplements based on goals
        if intake.goals.contains(.buildMuscle) || intake.goals.contains(.increaseStrength) {
            minimal.append(createCreatine())
        }
        
        if intake.goals.contains(.improveSleepQuality) || intake.goals.contains(.fallAsleepFaster) || intake.goals.contains(.reduceStress) {
            minimal.append(createMagnesium())
        }
        
        if intake.goals.contains(.improveFocus) || intake.goals.contains(.reduceAnxiety) || intake.goals.contains(.reduceStress) {
            minimal.append(createLTheanine())
        }
        
        // Ensure at least one supplement
        if minimal.isEmpty {
            minimal.append(createMagnesium())
        }
        
        // Create mock optional add-ons
        var addons: [Supplement] = []
        
        if intake.goals.contains(.supportImmuneFunction) {
            addons.append(createVitaminD())
        }
        
        if (intake.goals.contains(.boostEnergyStimulant) || intake.goals.contains(.boostEnergyNonStimulant)) && intake.basics.stimulantTolerance != .low {
            addons.append(createAshwagandha())
        }
        
        // Filter based on dietary preferences
        let veganOnly = intake.basics.dietaryPreferences.contains(.vegan)
        if veganOnly {
            minimal = minimal.map { supplement in
                return Supplement(
                    id: supplement.id,
                    name: supplement.name,
                    purpose: supplement.purpose,
                    doseRangeText: supplement.doseRangeText,
                    formNote: supplement.formNote,
                    timingTag: supplement.timingTag,
                    evidenceLevel: supplement.evidenceLevel,
                    flags: supplement.flags.union([.vegan]),
                    citations: supplement.citations,
                    rationale: supplement.rationale
                )
            }
            addons = addons.map { supplement in
                return Supplement(
                    id: supplement.id,
                    name: supplement.name,
                    purpose: supplement.purpose,
                    doseRangeText: supplement.doseRangeText,
                    formNote: supplement.formNote,
                    timingTag: supplement.timingTag,
                    evidenceLevel: supplement.evidenceLevel,
                    flags: supplement.flags.union([.vegan]),
                    citations: supplement.citations,
                    rationale: supplement.rationale
                )
            }
        }
        
        return Stack(minimal: minimal, addons: addons)
    }
    
    public func remixStack(currentStack: Stack, options: RemixOptions) async throws -> Stack {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        var minimal = currentStack.minimal
        var addons = currentStack.addons
        
        if options.fewerPills {
            // Keep only top 2 minimal and 1 addon
            minimal = Array(minimal.prefix(2))
            addons = Array(addons.prefix(1))
        }
        
        if options.stimulantFree {
            // Filter out any stimulants
            minimal = minimal.filter { !$0.name.lowercased().contains("caffeine") }
            addons = addons.filter { !$0.name.lowercased().contains("caffeine") }
        }
        
        if options.cheaper {
            // Simulate removing expensive supplements
            if minimal.count > 2 {
                minimal.removeLast()
            }
            if addons.count > 1 {
                addons.removeLast()
            }
        }
        
        if options.athleteMode {
            // Add creatine if not present
            if !minimal.contains(where: { $0.name == "Creatine Monohydrate" }) {
                minimal.append(createCreatine())
            }
        }
        
        return Stack(minimal: minimal, addons: addons)
    }
    
    // MARK: - Helper Methods
    
    private func createCreatine() -> Supplement {
        Supplement(
            name: "Creatine Monohydrate",
            purpose: "Increase strength and power",
            doseRangeText: "5g daily",
            formNote: "Powder recommended",
            timingTag: .morning,
            evidenceLevel: .a,
            flags: [.vegan, .stimulantFree],
            citations: [
                Citation(
                    title: "Effects of creatine supplementation on performance",
                    authors: "Kreider RB, et al.",
                    journal: "Journal of the International Society of Sports Nutrition",
                    year: 2017,
                    url: "https://pubmed.example.com/28615996/"
                )
            ],
            rationale: "Creatine is one of the most researched supplements with strong evidence for improving strength, power, and muscle mass. The 5g daily dose is well-established and safe for long-term use."
        )
    }
    
    private func createMagnesium() -> Supplement {
        Supplement(
            name: "Magnesium Glycinate",
            purpose: "Improve sleep quality",
            doseRangeText: "200-400mg before bed",
            formNote: "Glycinate form for better absorption",
            timingTag: .night,
            evidenceLevel: .a,
            flags: [.vegan, .stimulantFree],
            citations: [
                Citation(
                    title: "The effect of magnesium supplementation on sleep",
                    authors: "Abbasi B, et al.",
                    journal: "Journal of Research in Medical Sciences",
                    year: 2012,
                    url: "https://pubmed.example.com/23853635/"
                )
            ],
            rationale: "Magnesium glycinate is well-absorbed and less likely to cause digestive issues. It supports muscle relaxation and may improve sleep quality when taken before bed."
        )
    }
    
    private func createLTheanine() -> Supplement {
        Supplement(
            name: "L-Theanine",
            purpose: "Reduce stress, improve focus",
            doseRangeText: "100-200mg daily",
            formNote: nil,
            timingTag: .morning,
            evidenceLevel: .b,
            flags: [.vegan, .stimulantFree],
            citations: [
                Citation(
                    title: "L-Theanine reduces psychological stress responses",
                    authors: "Kimura K, et al.",
                    journal: "Biological Psychology",
                    year: 2007,
                    url: "https://pubmed.example.com/16930802/"
                )
            ],
            rationale: "L-Theanine promotes relaxation without drowsiness and can improve focus when combined with caffeine. It's particularly helpful for managing stress and anxiety."
        )
    }
    
    private func createVitaminD() -> Supplement {
        Supplement(
            name: "Vitamin D3",
            purpose: "Support immune function",
            doseRangeText: "1000-2000 IU daily",
            formNote: "Take with fat for absorption",
            timingTag: .morning,
            evidenceLevel: .a,
            flags: [.stimulantFree],
            citations: [
                Citation(
                    title: "Vitamin D and immune function",
                    authors: "Aranow C",
                    journal: "Journal of Investigative Medicine",
                    year: 2011,
                    url: "https://pubmed.example.com/21527855/"
                )
            ],
            rationale: "Vitamin D deficiency is common and linked to weakened immune function. Supplementation can help maintain optimal levels, especially with limited sun exposure."
        )
    }
    
    private func createAshwagandha() -> Supplement {
        Supplement(
            name: "Ashwagandha",
            purpose: "Reduce stress and fatigue",
            doseRangeText: "300-600mg daily",
            formNote: "KSM-66 extract",
            timingTag: .evening,
            evidenceLevel: .b,
            flags: [.vegan, .stimulantFree],
            citations: [
                Citation(
                    title: "A prospective study on efficacy of Ashwagandha",
                    authors: "Chandrasekhar K, et al.",
                    journal: "Indian Journal of Psychological Medicine",
                    year: 2012,
                    url: "https://pubmed.example.com/23439798/"
                )
            ],
            rationale: "Ashwagandha is an adaptogen that may help the body manage stress and reduce cortisol levels. KSM-66 is a well-studied, standardized extract."
        )
    }
}

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
                    purposeShort: supplement.purposeShort,
                    purposeLong: supplement.purposeLong,
                    scientificFunction: supplement.scientificFunction,
                    doseRangeText: supplement.doseRangeText,
                    formNote: supplement.formNote,
                    timingTag: supplement.timingTag,
                    evidenceLevel: supplement.evidenceLevel,
                    flags: supplement.flags.union([.vegan]),
                    citations: supplement.citations,
                    rationale: supplement.rationale,
                    active: supplement.active
                )
            }
            addons = addons.map { supplement in
                return Supplement(
                    id: supplement.id,
                    name: supplement.name,
                    purposeShort: supplement.purposeShort,
                    purposeLong: supplement.purposeLong,
                    scientificFunction: supplement.scientificFunction,
                    doseRangeText: supplement.doseRangeText,
                    formNote: supplement.formNote,
                    timingTag: supplement.timingTag,
                    evidenceLevel: supplement.evidenceLevel,
                    flags: supplement.flags.union([.vegan]),
                    citations: supplement.citations,
                    rationale: supplement.rationale,
                    active: supplement.active
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
            purposeShort: "Supports muscle strength, power output, and cognitive function",
            purposeLong: "Creatine monohydrate is one of the most researched supplements for athletic performance. It enhances strength, increases muscle mass, improves high-intensity exercise performance, and may support cognitive function and brain health.",
            scientificFunction: "Creatine increases phosphocreatine stores in muscles, enabling rapid ATP regeneration during high-intensity activities. This enhanced energy availability leads to improved strength, power output, and work capacity during repeated high-intensity efforts.",
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
            rationale: "Based on your goals to build muscle and increase strength, creatine is one of the most well-researched supplements for enhancing power output and supporting muscle growth.",
            active: true
        )
    }
    
    private func createMagnesium() -> Supplement {
        Supplement(
            name: "Magnesium Glycinate",
            purposeShort: "Improves sleep quality and promotes relaxation",
            purposeLong: "Magnesium glycinate is a highly bioavailable form of magnesium that supports sleep quality, muscle relaxation, and nervous system function. It's particularly effective for reducing nighttime muscle cramps and promoting deeper, more restful sleep.",
            scientificFunction: "Magnesium acts as a natural NMDA receptor antagonist and GABA agonist, promoting neuronal relaxation. It also regulates melatonin production and reduces cortisol levels, facilitating the transition to sleep.",
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
            rationale: "Given your goal to improve sleep quality, magnesium glycinate is highly bioavailable and helps with sleep onset and quality without morning grogginess.",
            active: true
        )
    }
    
    private func createLTheanine() -> Supplement {
        Supplement(
            name: "L-Theanine",
            purposeShort: "Reduces stress and improves focus without drowsiness",
            purposeLong: "L-Theanine is an amino acid found in tea that promotes relaxation without causing drowsiness. It can improve focus, reduce stress, and enhance sleep quality when taken before bed.",
            scientificFunction: "L-Theanine increases alpha brain waves associated with relaxation and alertness. It modulates GABA, dopamine, and serotonin levels while reducing cortisol, creating a state of calm focus.",
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
            rationale: "L-Theanine promotes relaxation without drowsiness and can improve focus when combined with caffeine. It's particularly helpful for managing stress and anxiety.",
            active: true
        )
    }
    
    private func createVitaminD() -> Supplement {
        Supplement(
            name: "Vitamin D3",
            purposeShort: "Supports immune function and bone health",
            purposeLong: "Vitamin D3 is essential for immune function, bone health, and mood regulation. Many people are deficient, especially those with limited sun exposure or living in northern climates.",
            scientificFunction: "Vitamin D acts as a hormone in the body, regulating calcium absorption and bone mineralization. It also modulates immune cell function and has anti-inflammatory effects.",
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
            rationale: "Vitamin D deficiency is common and linked to weakened immune function. Supplementation can help maintain optimal levels, especially with limited sun exposure.",
            active: true
        )
    }
    
    private func createAshwagandha() -> Supplement {
        Supplement(
            name: "Ashwagandha",
            purposeShort: "Reduces stress and supports energy levels",
            purposeLong: "Ashwagandha is an ancient adaptogenic herb that helps the body manage stress, reduce anxiety, and improve energy levels. It may also support testosterone levels and muscle strength.",
            scientificFunction: "Ashwagandha modulates the HPA axis, reducing cortisol levels and stress response. It also exhibits GABA-mimetic activity and may increase testosterone and DHEA-S levels in stressed individuals.",
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
            rationale: "Ashwagandha is an adaptogen that may help the body manage stress and reduce cortisol levels. KSM-66 is a well-studied, standardized extract.",
            active: true
        )
    }
}

import Foundation

// MARK: - Ending System

enum EndingType: String, CaseIterable, Codable {
    case pureHero = "pure_hero"
    case corruptedTyrant = "corrupted_tyrant"
    case balancedMaster = "balanced_master"
    case mysteriousDisappearance = "mysterious_disappearance"
    case tragicSacrifice = "tragic_sacrifice"
    case ancientOneChosen = "ancient_one_chosen"
    case kaiBetrayal = "kai_betrayal"
    case nayaRedemption = "naya_redemption"
    
    var title: String {
        switch self {
        case .pureHero: return "The Pure Hero"
        case .corruptedTyrant: return "The Corrupted Tyrant"
        case .balancedMaster: return "The Balanced Master"
        case .mysteriousDisappearance: return "The Mysterious Disappearance"
        case .tragicSacrifice: return "The Tragic Sacrifice"
        case .ancientOneChosen: return "Chosen of the Ancient One"
        case .kaiBetrayal: return "Betrayed by Kai"
        case .nayaRedemption: return "Naya's Redemption"
        }
    }
    
    var description: String {
        switch self {
        case .pureHero:
            return "You maintained your moral compass throughout the journey, resisting corruption and helping others. Your compassion and strength of character made you a true hero."
        case .corruptedTyrant:
            return "The power consumed you. You became a tyrant, using your abilities to dominate and control. The Ancient One's influence corrupted your soul completely."
        case .balancedMaster:
            return "You found the perfect balance between power and morality. You used your abilities wisely, neither rejecting nor succumbing to corruption."
        case .mysteriousDisappearance:
            return "You vanished without a trace, leaving behind only questions. Some say you transcended this reality, others believe you were taken by forces beyond understanding."
        case .tragicSacrifice:
            return "You gave your life to save others or prevent a greater evil. Your sacrifice will be remembered, but the cost was your own existence."
        case .ancientOneChosen:
            return "The Ancient One chose you as their successor. You now wield unimaginable power, but at what cost to your humanity?"
        case .kaiBetrayal:
            return "Kai's betrayal was your undoing. Despite your best efforts, you couldn't prevent their treachery from destroying everything you built."
        case .nayaRedemption:
            return "You helped Naya find redemption and together you forged a new path. Your compassion and understanding changed the course of destiny."
        }
    }
    
    var requirements: EndingRequirements {
        switch self {
        case .pureHero:
            return EndingRequirements(
                corruption: 0...20,
                compassion: 70...100,
                ancientOneFavor: -100...30,
                kaiLoyalty: 50...100,
                requiredChoices: ["resist_magic", "trust_kai", "forgive_kai"],
                forbiddenChoices: ["embrace_magic", "rage_against_kai"]
            )
        case .corruptedTyrant:
            return EndingRequirements(
                corruption: 80...100,
                compassion: 0...30,
                ancientOneFavor: 70...100,
                kaiLoyalty: -100...(-50),
                requiredChoices: ["embrace_magic", "rage_against_kai"],
                forbiddenChoices: ["resist_magic", "forgive_kai"]
            )
        case .balancedMaster:
            return EndingRequirements(
                corruption: 30...70,
                compassion: 40...80,
                ancientOneFavor: 30...70,
                kaiLoyalty: -20...50,
                requiredChoices: [],
                forbiddenChoices: []
            )
        case .mysteriousDisappearance:
            return EndingRequirements(
                corruption: 50...100,
                compassion: 0...100,
                ancientOneFavor: 80...100,
                kaiLoyalty: -100...100,
                requiredChoices: ["embrace_magic"],
                forbiddenChoices: []
            )
        case .tragicSacrifice:
            return EndingRequirements(
                corruption: 0...50,
                compassion: 60...100,
                ancientOneFavor: -100...50,
                kaiLoyalty: 30...100,
                requiredChoices: ["forgive_kai"],
                forbiddenChoices: ["rage_against_kai"]
            )
        case .ancientOneChosen:
            return EndingRequirements(
                corruption: 60...100,
                compassion: 0...50,
                ancientOneFavor: 90...100,
                kaiLoyalty: -100...100,
                requiredChoices: ["embrace_magic", "cold_revenge"],
                forbiddenChoices: ["resist_magic", "forgive_kai"]
            )
        case .kaiBetrayal:
            return EndingRequirements(
                corruption: 0...100,
                compassion: 0...100,
                ancientOneFavor: -100...100,
                kaiLoyalty: -100...(-80),
                requiredChoices: [],
                forbiddenChoices: []
            )
        case .nayaRedemption:
            return EndingRequirements(
                corruption: 0...40,
                compassion: 80...100,
                ancientOneFavor: -50...50,
                kaiLoyalty: -100...100,
                requiredChoices: ["forgive_kai"],
                forbiddenChoices: ["rage_against_kai"]
            )
        }
    }
}

struct EndingRequirements {
    let corruption: ClosedRange<Int>
    let compassion: ClosedRange<Int>
    let ancientOneFavor: ClosedRange<Int>
    let kaiLoyalty: ClosedRange<Int>
    let requiredChoices: [String]
    let forbiddenChoices: [String]
    
    func isMet(by stats: PlayerStats) -> Bool {
        // Check stat requirements
        guard corruption.contains(stats.corruption),
              compassion.contains(stats.compassion),
              ancientOneFavor.contains(stats.ancientOneFavor),
              kaiLoyalty.contains(stats.kaiLoyalty) else {
            return false
        }
        
        // Check required choices
        for requiredChoice in requiredChoices {
            guard stats.majorChoices[requiredChoice] != nil else {
                return false
            }
        }
        
        // Check forbidden choices
        for forbiddenChoice in forbiddenChoices {
            guard stats.majorChoices[forbiddenChoice] == nil else {
                return false
            }
        }
        
        return true
    }
}

struct Ending {
    let type: EndingType
    let narrative: String
    let consequences: [String]
    let unlockDate: Date
    
    init(type: EndingType, narrative: String, consequences: [String] = []) {
        self.type = type
        self.narrative = narrative
        self.consequences = consequences
        self.unlockDate = Date()
    }
}

// MARK: - Ending Calculator

class EndingCalculator: ObservableObject {
    static let shared = EndingCalculator()
    
    @Published var currentEnding: Ending?
    @Published var unlockedEndings: [Ending] = []
    
    private init() {}
    
    func calculateEnding(for stats: PlayerStats) -> Ending {
        // Check each ending type in order of specificity
        let endingTypes: [EndingType] = [
            .ancientOneChosen,    // Most specific
            .kaiBetrayal,
            .nayaRedemption,
            .tragicSacrifice,
            .mysteriousDisappearance,
            .pureHero,
            .corruptedTyrant,
            .balancedMaster       // Most general
        ]
        
        for endingType in endingTypes {
            if endingType.requirements.isMet(by: stats) {
                let ending = createEnding(endingType, for: stats)
                currentEnding = ending
                
                // Add to unlocked endings if not already present
                if !unlockedEndings.contains(where: { $0.type == endingType }) {
                    unlockedEndings.append(ending)
                }
                
                return ending
            }
        }
        
        // Fallback to balanced master
        let fallbackEnding = createEnding(.balancedMaster, for: stats)
        currentEnding = fallbackEnding
        return fallbackEnding
    }
    
    private func createEnding(_ type: EndingType, for stats: PlayerStats) -> Ending {
        let narrative = generateNarrative(for: type, stats: stats)
        let consequences = generateConsequences(for: type, stats: stats)
        
        return Ending(type: type, narrative: narrative, consequences: consequences)
    }
    
    private func generateNarrative(for type: EndingType, stats: PlayerStats) -> String {
        switch type {
        case .pureHero:
            return """
            You stand at the edge of the wasteland, looking back at the path you've walked. Your hands are clean, your heart pure. You resisted the corruption that consumed so many others.
            
            Kai, once your betrayer, now stands beside you as a true friend. Your forgiveness and compassion changed not just their fate, but the fate of this broken world.
            
            The Ancient One's power still lingers in the air, but you've proven that strength doesn't require corruption. You are a beacon of hope in a world that desperately needs it.
            
            Your journey ends not with conquest, but with healing. The wasteland may never be the same, but neither will you. You've become something greater than yourself - a true hero.
            """
            
        case .corruptedTyrant:
            return """
            The wasteland bows before your power. Ancient magic courses through your veins, and the very air trembles at your command. You are no longer human - you are something more, something terrible.
            
            Kai's betrayal was the final catalyst. Your rage consumed you, and now you rule with an iron fist. Those who oppose you learn the price of defiance. The Ancient One's influence has transformed you into a being of pure power and corruption.
            
            The world is yours to command, but at what cost? Your humanity is gone, replaced by an insatiable hunger for more power. You are the tyrant this world feared, and there is no turning back.
            
            Your journey ends in absolute domination, but you are alone in your victory. Power has consumed everything that made you human.
            """
            
        case .balancedMaster:
            return """
            You've walked the fine line between power and corruption, finding balance where others fell to extremes. Your wisdom and restraint have made you a master of both light and shadow.
            
            You understand that power is a tool, not a master. You've used your abilities to help others while resisting the temptation to dominate. The Ancient One respects your discipline, even if they don't fully understand your choices.
            
            Kai's betrayal taught you valuable lessons about trust and forgiveness. You've learned to be cautious without becoming cynical, strong without becoming cruel.
            
            Your journey ends with you as a master of balance - neither hero nor villain, but something more nuanced. You've found your own path in a world of extremes.
            """
            
        case .mysteriousDisappearance:
            return """
            One day, you simply vanish. No trace remains, no explanation given. The wasteland whispers of your fate - some say you transcended this reality, others believe the Ancient One claimed you for their own purposes.
            
            Your choices led you down a path of increasing power and mystery. The Ancient One's favor grew stronger, and with it came changes you couldn't fully understand. Perhaps you became something beyond human comprehension.
            
            Kai searches for you, but finds only questions. Your disappearance becomes a legend, a mystery that will haunt this world for generations to come.
            
            Your journey ends in mystery, leaving behind only speculation and wonder. You've become a story, a myth, a question mark in the annals of this broken world.
            """
            
        case .tragicSacrifice:
            return """
            You gave everything to save others. Your final act of compassion and courage cost you your life, but it changed the fate of this world forever.
            
            Facing an impossible choice, you chose to sacrifice yourself rather than let others suffer. Your death was not in vain - it inspired others to be better, to fight for what's right even when the cost is everything.
            
            Kai mourns your loss, but carries on your legacy. Your sacrifice becomes a beacon of hope in a world that desperately needs heroes willing to pay the ultimate price.
            
            Your journey ends in tragedy, but your sacrifice ensures that others may live to see a better world. You are remembered not for how you lived, but for how you died - as a true hero.
            """
            
        case .ancientOneChosen:
            return """
            The Ancient One has chosen you as their successor. You now wield power beyond mortal comprehension, but the transformation has changed you fundamentally.
            
            Your corruption and ambition caught the Ancient One's attention. They saw in you the potential to become something greater than human - a being of pure power and purpose. You've transcended mortality, but at the cost of your humanity.
            
            Kai and others fear you now, and with good reason. You are no longer one of them - you are something else entirely. The Ancient One's power flows through you, and you see the world through eyes that are no longer human.
            
            Your journey ends in apotheosis. You have become the Ancient One's chosen, a being of pure power and purpose. The world will never be the same.
            """
            
        case .kaiBetrayal:
            return """
            Kai's betrayal was your undoing. Despite your best efforts, their treachery destroyed everything you had built. The trust you placed in them became your greatest weakness.
            
            The signs were there, but you chose to ignore them. Kai's loyalty was never truly yours - they served their own agenda from the beginning. When the moment came, they struck without hesitation.
            
            Your journey ends in betrayal and loss. Kai's treachery has cost you everything - your power, your allies, your hope. You are left alone in a world that has proven itself unworthy of trust.
            
            The wasteland claims another victim, not through corruption or power, but through the simple act of trusting the wrong person.
            """
            
        case .nayaRedemption:
            return """
            You helped Naya find redemption, and together you forged a new path forward. Your compassion and understanding changed not just her fate, but the fate of this broken world.
            
            When others would have condemned Naya for her past actions, you chose to see the potential for good within her. Your forgiveness and guidance helped her overcome her own darkness and find a new purpose.
            
            Together, you've become a force for healing in this wounded world. Your partnership proves that redemption is possible, even in the darkest of times.
            
            Your journey ends in partnership and hope. You and Naya have shown that even in a world of corruption and betrayal, compassion and understanding can still triumph.
            """
        }
    }
    
    private func generateConsequences(for type: EndingType, stats: PlayerStats) -> [String] {
        var consequences: [String] = []
        
        // Add stat-based consequences
        if stats.corruption > 70 {
            consequences.append("High corruption has permanently altered your soul")
        }
        if stats.compassion > 80 {
            consequences.append("Your compassion has inspired others to be better")
        }
        if stats.ancientOneFavor > 80 {
            consequences.append("The Ancient One's favor has granted you immense power")
        }
        if stats.kaiLoyalty < -50 {
            consequences.append("Kai's betrayal has left deep scars")
        }
        
        // Add choice-based consequences
        if stats.majorChoices["embrace_magic"] != nil {
            consequences.append("You embraced ancient magic, changing your destiny")
        }
        if stats.majorChoices["forgive_kai"] != nil {
            consequences.append("Your forgiveness of Kai showed true strength")
        }
        if stats.majorChoices["rage_against_kai"] != nil {
            consequences.append("Your rage against Kai consumed your better nature")
        }
        
        return consequences
    }
    
    func resetEndings() {
        currentEnding = nil
        unlockedEndings = []
    }
} 
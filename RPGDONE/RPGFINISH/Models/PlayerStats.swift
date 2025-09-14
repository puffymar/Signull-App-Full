import Foundation

enum Gender: String, CaseIterable, Codable {
    case man = "Man"
    case woman = "Woman"
}

enum StatType: String, Codable, CaseIterable {
    case health = "health"
    case strength = "strength"
    case intelligence = "intelligence"
    case charisma = "charisma"
    case magic = "magic"
    case hunger = "hunger"
    case weather = "weather"
    case compassion = "compassion"
    case corruption = "corruption"
    case sanity = "sanity"
    case dreamAlignment = "dreamAlignment"
    case resolve = "resolve"
    case empathy = "empathy"
    case energy = "energy"
    case kaiLoyalty = "kaiLoyalty"
    case nayaTrust = "nayaTrust"
    case ancientOneFavor = "ancientOneFavor"
    case money = "money"
    case morality = "morality"
    case courage = "courage"
    case adaptability = "adaptability"
    case wisdom = "wisdom"
    case enemiesSpared = "enemiesSpared"
    case enemiesDefeated = "enemiesDefeated"
    case enemiesKilled = "enemiesKilled"
    case humility = "humility"
    
    var description: String {
        switch self {
        case .health: return "Health"
        case .strength: return "Strength"
        case .intelligence: return "Intelligence"
        case .charisma: return "Charisma"
        case .magic: return "Magic"
        case .hunger: return "Hunger"
        case .weather: return "Weather"
        case .compassion: return "Compassion"
        case .corruption: return "Corruption"
        case .sanity: return "Sanity"
        case .dreamAlignment: return "Dream Alignment"
        case .resolve: return "Resolve"
        case .empathy: return "Empathy"
        case .energy: return "Energy"
        case .kaiLoyalty: return "Kai Loyalty"
        case .nayaTrust: return "Naya Trust"
        case .ancientOneFavor: return "Ancient One Favor"
        case .money: return "Money"
        case .morality: return "Morality"
        case .courage: return "Courage"
        case .adaptability: return "Adaptability"
        case .wisdom: return "Wisdom"
        case .enemiesSpared: return "Enemies Spared"
        case .enemiesDefeated: return "Enemies Defeated"
        case .enemiesKilled: return "Enemies Killed"
        case .humility: return "Humility"
        }
    }
}

// WeatherType is defined in GameState.swift

enum MagicTestResult: String, CaseIterable, Codable {
    case null = "Null"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case exceptional = "Exceptional"
}

struct PlayerStats: Codable {
    // MARK: - Core Stats
    var playerName: String = ""
    var health: Int = 100
    var strength: Int = 50
    var intelligence: Int = 50
    var charisma: Int = 50
    var magic: Int = 50
    var hunger: Int = 100
    var weather: Int = 50
    
    // MARK: - Psychological Stats
    var sanity: Int = 100
    var corruption: Int = 0
    var dreamAlignment: Int = 0
    var realityBending: Int = 0
    
    // MARK: - Social Stats
    var compassion: Int = 50
    var resolve: Int = 50
    var empathy: Int = 50
    
    // MARK: - Magic System
    var magicTestResult: MagicTestResult?
    var hasCompletedMagicTest: Bool = false
    var magicAffinity: Int = 50
    
    // MARK: - Exploration & Progress
    var hasExploredMarkets: Bool = false
    var hasMetTraveler: Bool = false
    var currentWeather: WeatherType = .clear
    
    // MARK: - Traits & Abilities
    var traits: [Trait] = []
    var abilities: [Ability] = []
    
    // MARK: - Relationship Tracking
    var relationshipLevels: [String: Int] = [:]
    var betrayalRisks: [String: Int] = [:]
    
    // MARK: - Progression Tracking
    var majorChoices: [String: String] = [:]
    var unlockedSecrets: Set<String> = []
    var achievements: Set<String> = []
    
    // MARK: - Chapter-Specific Stats
    var chapterProgress: [Int: ChapterProgress] = [:]
    
    // MARK: - Cult & Betrayal System
    var cultInfluence: Int = 0
    var shadowKnowledge: Int = 0
    
    // MARK: - Dream & Reality System
    var dreamFragments: Int = 0
    var realityShards: Int = 0
    
    // MARK: - Combat & Route System
    var currentRoute: CombatRoute = .tactical
    var routeProgress: [CombatRoute: Int] = [:]
    var enemiesSpared: Int = 0
    var enemiesDefeated: Int = 0
    var enemiesKilled: Int = 0
    
    // MARK: - Additional Stats
    var energy: Int = 100
    var kaiLoyalty: Int = 0
    var nayaTrust: Int = 0
    var ancientOneFavor: Int = 0
    var money: Double = 50.0
    var morality: Double = 50.0
    var courage: Int = 50
    var adaptability: Int = 50
    var agility: Int = 50
    
    // MARK: - Corruption Events
    var corruptionEvents: [String] = []
    
    init() {
        setupDefaultRelationships()
        setupChapterProgress()
        setupRouteProgress()
    }
    
    // MARK: - Stat Modification Methods
    
    mutating func modifyHealth(_ change: Int) {
        health = max(0, min(100, health + change))
    }
    
    mutating func modifyStrength(_ change: Int) {
        strength = max(0, min(100, strength + change))
    }
    
    mutating func modifyIntelligence(_ change: Int) {
        intelligence = max(0, min(100, intelligence + change))
    }
    
    mutating func modifyCharisma(_ change: Int) {
        charisma = max(0, min(100, charisma + change))
    }
    
    mutating func modifyMagic(_ change: Int) {
        magic = max(0, min(100, magic + change))
    }
    
    mutating func modifySanity(_ change: Int) {
        sanity = max(0, min(100, sanity + change))
    }
    
    mutating func modifyCorruption(_ change: Int) {
        corruption = max(0, min(100, corruption + change))
    }
    
    mutating func modifyDreamAlignment(_ change: Int) {
        dreamAlignment = max(-100, min(100, dreamAlignment + change))
    }
    
    mutating func modifyRealityBending(_ change: Int) {
        realityBending = max(0, min(100, realityBending + change))
    }
    
    mutating func modifyCompassion(_ change: Int) {
        compassion = max(0, min(100, compassion + change))
    }
    
    mutating func modifyResolve(_ change: Int) {
        resolve = max(0, min(100, resolve + change))
    }
    
    mutating func modifyEmpathy(_ change: Int) {
        empathy = max(0, min(100, empathy + change))
    }
    
    // MARK: - Relationship Methods
    
    mutating func modifyRelationship(with character: String, trust: Int, betrayal: Int = 0) {
        if relationshipLevels[character] == nil {
            relationshipLevels[character] = 0
        }
        if betrayalRisks[character] == nil {
            betrayalRisks[character] = 0
        }
        
        relationshipLevels[character]? += trust
        betrayalRisks[character]? += betrayal
    }
    
    func getRelationshipLevel(with character: String) -> Int {
        return relationshipLevels[character] ?? 0
    }
    
    func getBetrayalRisk(with character: String) -> Int {
        return betrayalRisks[character] ?? 0
    }
    
    // MARK: - Ability & Trait Methods
    
    mutating func addAbility(_ ability: Ability) {
        if !abilities.contains(where: { $0.id == ability.id }) {
            abilities.append(ability)
        }
    }
    
    mutating func addTrait(_ trait: Trait) {
        if !traits.contains(trait) {
            traits.append(trait)
        }
    }
    
    func hasAbility(_ abilityType: AbilityType) -> Bool {
        return abilities.contains(where: { $0.type == abilityType && $0.isUnlocked })
    }
    
    func hasTrait(_ trait: Trait) -> Bool {
        return traits.contains(trait)
    }
    
    // MARK: - Progression Methods
    
    mutating func recordChoice(_ choiceId: String, choice: String) {
        majorChoices[choiceId] = choice
    }
    
    mutating func unlockSecret(_ secret: String) {
        unlockedSecrets.insert(secret)
    }
    
    mutating func unlockAchievement(_ achievement: String) {
        achievements.insert(achievement)
    }
    
    // MARK: - Chapter Progress Methods
    
    mutating func setChapterProgress(_ chapter: Int, progress: ChapterProgress) {
        chapterProgress[chapter] = progress
    }
    
    func getChapterProgress(_ chapter: Int) -> ChapterProgress? {
        return chapterProgress[chapter]
    }
    
    // MARK: - Cult & Betrayal Methods
    
    mutating func modifyCultInfluence(_ change: Int) {
        cultInfluence = max(0, min(100, cultInfluence + change))
    }
    
    mutating func modifyShadowKnowledge(_ change: Int) {
        shadowKnowledge = max(0, min(100, shadowKnowledge + change))
    }
    
    // MARK: - Dream & Reality Methods
    
    mutating func addDreamFragment() {
        dreamFragments += 1
    }
    
    mutating func addRealityShard() {
        realityShards += 1
    }
    
    // MARK: - Combat & Route Methods
    
    mutating func setCurrentRoute(_ route: CombatRoute) {
        currentRoute = route
    }
    
    mutating func incrementRouteProgress(for route: CombatRoute) {
        routeProgress[route, default: 0] += 1
    }
    
    mutating func incrementEnemiesSpared() {
        enemiesSpared += 1
    }
    
    mutating func incrementEnemiesDefeated() {
        enemiesDefeated += 1
    }
    
    mutating func incrementEnemiesKilled() {
        enemiesKilled += 1
    }
    
    // MARK: - Additional Stat Modification Methods
    
    mutating func modifyEnergy(_ change: Int) {
        energy = max(0, min(100, energy + change))
    }
    
    mutating func modifyKaiLoyalty(_ change: Int) {
        kaiLoyalty = max(0, min(100, kaiLoyalty + change))
    }
    
    mutating func modifyNayaTrust(_ change: Int) {
        nayaTrust = max(0, min(100, nayaTrust + change))
    }
    
    mutating func modifyAncientOneFavor(_ change: Int) {
        ancientOneFavor = max(0, min(100, ancientOneFavor + change))
    }
    
    mutating func modifyMoney(_ change: Double) {
        money += change
    }
    
    mutating func modifyMorality(_ change: Double) {
        morality = max(0.0, min(100.0, morality + change))
    }
    
    mutating func modifyCourage(_ change: Int) {
        courage = max(0, min(100, courage + change))
    }
    
    mutating func modifyAdaptability(_ change: Int) {
        adaptability = max(0, min(100, adaptability + change))
    }
    
    mutating func modifyAgility(_ change: Int) {
        agility = max(0, min(100, agility + change))
    }
    
    mutating func modifyWisdom(_ change: Int) {
        // Note: wisdom is not a stored property, so we'll use resolve as a proxy
        resolve = max(0, min(100, resolve + change))
    }
    
    // MARK: - Corruption Event Methods
    
    mutating func addCorruptionEvent(_ event: String) {
        corruptionEvents.append(event)
    }
    
    // MARK: - Consequence Application Methods
    
    mutating func applyConsequence(_ consequence: Consequence) {
        switch consequence.type {
        case .stat:
            if let statType = StatType(rawValue: consequence.target) {
                applyStatChange(statType, value: consequence.value)
            }
        case .ability:
            // Handle ability unlocking
            break
        case .choice:
            // Handle choice consequences
            break
        case .route:
            // Handle route changes
            break
        case .secret:
            // Handle secret unlocking
            unlockSecret(consequence.target)
        case .time:
            // Handle time-based consequences
            break
        case .location:
            // Handle location-based consequences
            break
        case .unlock:
            // Handle unlocking content
            break
        case .reveal:
            // Handle revealing content
            break
        case .statChange:
            // Handle stat changes
            if let statType = StatType(rawValue: consequence.target) {
                applyStatChange(statType, value: consequence.value)
            }
        case .endingInfluence:
            // Handle ending influence
            break
        case .worldState:
            // Handle world state changes
            break
        case .environmental:
            // Handle environmental consequences
            break
        case .heal:
            // Handle healing
            break
        case .debuff:
            // Handle debuffs
            break
        case .buff:
            // Handle buffs
            break
        case .status:
            // Handle status effects
            break
        }
    }
    
    mutating func applyStatChange(_ stat: StatType, value: Int) {
        switch stat {
        case .health:
            modifyHealth(value)
        case .strength:
            modifyStrength(value)
        case .intelligence:
            modifyIntelligence(value)
        case .charisma:
            modifyCharisma(value)
        case .magic:
            modifyMagic(value)
        case .hunger:
            modifyHunger(value)
        case .weather:
            modifyWeather(value)
        case .compassion:
            modifyCompassion(value)
        case .corruption:
            modifyCorruption(value)
        case .sanity:
            modifySanity(value)
        case .dreamAlignment:
            modifyDreamAlignment(value)
        case .resolve:
            modifyResolve(value)
        case .empathy:
            modifyEmpathy(value)
        case .energy:
            modifyEnergy(value)
        case .kaiLoyalty:
            modifyKaiLoyalty(value)
        case .nayaTrust:
            modifyNayaTrust(value)
        case .ancientOneFavor:
            modifyAncientOneFavor(value)
        case .money:
            modifyMoney(Double(value))
        case .morality:
            modifyMorality(Double(value))
        case .courage:
            modifyCourage(value)
        case .adaptability:
            modifyAdaptability(value)
        case .wisdom:
            modifyWisdom(value)
        case .enemiesSpared:
            if value > 0 {
                for _ in 0..<value {
                    incrementEnemiesSpared()
                }
            }
        case .enemiesDefeated:
            if value > 0 {
                for _ in 0..<value {
                    incrementEnemiesDefeated()
                }
            }
        case .enemiesKilled:
            if value > 0 {
                for _ in 0..<value {
                    incrementEnemiesKilled()
                }
            }
        case .humility:
            // Humility is not a stored stat, so we'll use compassion as a proxy
            compassion = max(0, min(100, compassion + value))
        }
    }
    
    // MARK: - Additional Stat Modification Methods
    
    mutating func modifyHunger(_ change: Int) {
        hunger = max(0, min(100, hunger + change))
    }
    
    mutating func modifyWeather(_ change: Int) {
        weather = max(0, min(100, weather + change))
    }
    
    // MARK: - Stat Check Methods
    
    mutating func clampStats() {
        // Clamp all stats to valid ranges
        health = max(0, min(100, health))
        strength = max(0, min(100, strength))
        intelligence = max(0, min(100, intelligence))
        charisma = max(0, min(100, charisma))
        magic = max(0, min(100, magic))
        hunger = max(0, min(100, hunger))
        weather = max(0, min(100, weather))
        sanity = max(0, min(100, sanity))
        corruption = max(0, min(100, corruption))
        dreamAlignment = max(-100, min(100, dreamAlignment))
        realityBending = max(0, min(100, realityBending))
        compassion = max(0, min(100, compassion))
        resolve = max(0, min(100, resolve))
        empathy = max(0, min(100, empathy))
        magicAffinity = max(0, min(100, magicAffinity))
        energy = max(0, min(100, energy))
        kaiLoyalty = max(0, min(100, kaiLoyalty))
        nayaTrust = max(0, min(100, nayaTrust))
        ancientOneFavor = max(0, min(100, ancientOneFavor))
        morality = max(0.0, min(100.0, morality))
        courage = max(0, min(100, courage))
        adaptability = max(0, min(100, adaptability))
        agility = max(0, min(100, agility))
        cultInfluence = max(0, min(100, cultInfluence))
        shadowKnowledge = max(0, min(100, shadowKnowledge))
    }
    
    func canUseAbility(_ abilityType: AbilityType) -> Bool {
        switch abilityType {
        case .divineEcho:
            return intelligence >= 90
        case .dreamphase:
            return dreamAlignment >= 50
        case .realityShifter:
            return magic >= 80
        case .emberTongue:
            return magic >= 60
        case .nullfoot:
            return strength >= 70
        case .echoMemory:
            return intelligence >= 70
        case .shadowStep:
            return agility >= 60
        case .mindReader:
            return empathy >= 60
        case .fireBreath:
            return magic >= 50
        case .stealthMaster:
            return agility >= 80
        case .loreEcho:
            return intelligence >= 60
        case .timeSlip:
            return intelligence >= 75
        case .spiritWalk:
            return magic >= 65
        case .crystalSight:
            return magic >= 55
        case .nightVision:
            return intelligence >= 40
        case .waterBreathing:
            return strength >= 50
        case .stoneSkin:
            return strength >= 60
        case .windWalker:
            return agility >= 50
        case .lightningReflexes:
            return agility >= 70
        case .ironWill:
            return resolve >= 60
        case .basicHealing:
            return magic >= 30
        case .minorStrength:
            return strength >= 40
        case .simpleMagic:
            return magic >= 40
        case .basicStealth:
            return agility >= 30
        case .minorSpeed:
            return agility >= 40
        case .simpleWisdom:
            return intelligence >= 40
        }
    }
    
    func getStatThreshold(_ stat: StatType) -> Int {
        switch stat {
        case .health:
            return health
        case .strength:
            return strength
        case .intelligence:
            return intelligence
        case .charisma:
            return charisma
        case .magic:
            return magic
        case .hunger:
            return hunger
        case .weather:
            return weather
        case .compassion:
            return compassion
        case .corruption:
            return corruption
        case .sanity:
            return sanity
        case .dreamAlignment:
            return dreamAlignment
        case .resolve:
            return resolve
        case .empathy:
            return empathy
        case .energy:
            return energy
        case .kaiLoyalty:
            return kaiLoyalty
        case .nayaTrust:
            return nayaTrust
        case .ancientOneFavor:
            return ancientOneFavor
        case .money:
            return Int(money)
        case .morality:
            return Int(morality)
        case .courage:
            return courage
        case .adaptability:
            return adaptability
        case .wisdom:
            return resolve // Use resolve as proxy for wisdom
        case .enemiesSpared:
            return enemiesSpared
        case .enemiesDefeated:
            return enemiesDefeated
        case .enemiesKilled:
            return enemiesKilled
        case .humility:
            // Humility is not a stored stat, so we'll use compassion as a proxy
            return compassion
        }
    }
    
    // MARK: - Stat Access Methods
    
    func getStatValue(_ statName: String) -> Int {
        switch statName.lowercased() {
        case "health": return health
        case "strength": return strength
        case "intelligence": return intelligence
        case "charisma": return charisma
        case "magic": return magic
        case "hunger": return hunger
        case "weather": return weather
        case "compassion": return compassion
        case "corruption": return corruption
        case "sanity": return sanity
        case "dreamalignment": return dreamAlignment
        case "resolve": return resolve
        case "empathy": return empathy
        case "energy": return energy
        case "kailoyalty": return kaiLoyalty
        case "nayatrust": return nayaTrust
        case "ancientonefavor": return ancientOneFavor
        case "money": return Int(money)
        case "morality": return Int(morality)
        case "courage": return courage
        case "adaptability": return adaptability
        case "enemiesspared": return enemiesSpared
        case "enemiesdefeated": return enemiesDefeated
        case "enemieskilled": return enemiesKilled
        case "humility": return compassion // Use compassion as proxy for humility
        default: return 0
        }
    }
    
    // MARK: - Private Setup Methods
    
    private mutating func setupDefaultRelationships() {
        let defaultCharacters = ["Teacher", "Asher", "LoyalFriend", "Saboteur", "QuietGenius", "Recruiter", "CultLeader"]
        
        for character in defaultCharacters {
            relationshipLevels[character] = 0
            betrayalRisks[character] = 0
        }
    }
    
    private mutating func setupChapterProgress() {
        for chapter in 1...10 {
            chapterProgress[chapter] = ChapterProgress()
        }
    }
    
    private mutating func setupRouteProgress() {
        for route in CombatRoute.allCases {
            routeProgress[route] = 0
        }
    }
}

// MARK: - Supporting Types

struct ChapterProgress: Codable {
    var isCompleted: Bool = false
    var choices: [String: String] = [:]
    var secrets: Set<String> = []
    var relationships: [String: Int] = [:]
    var sanityChanges: Int = 0
    var corruptionChanges: Int = 0
} 
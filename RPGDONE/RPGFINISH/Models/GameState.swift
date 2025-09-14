import Foundation
import SwiftUI

// MARK: - Story Route System
enum StoryRoute: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case neutral = "neutral"
    case chaos = "chaos"
    case order = "order"
    // Added for compatibility
    case corruption = "corruption"
    case redemption = "redemption"
    case balance = "balance"
    case power = "power"
    case sacrifice = "sacrifice"
    case transcendence = "transcendence"
    
    var description: String {
        switch self {
        case .light: return "Path of Light and Hope"
        case .dark: return "Path of Darkness and Power"
        case .neutral: return "Path of Balance"
        case .chaos: return "Path of Chaos and Freedom"
        case .order: return "Path of Order and Control"
        case .corruption: return "Path of Corruption"
        case .redemption: return "Path of Redemption"
        case .balance: return "Path of Balance"
        case .power: return "Path of Power"
        case .sacrifice: return "Path of Sacrifice"
        case .transcendence: return "Path of Transcendence"
        }
    }
}

// MARK: - Requirement and Consequence Types
public enum RequirementType: String, Codable {
    case stat, ability, choice, route, relationship, secret, morality, knowledge, deception, quest, power, trust
}

enum ConsequenceType: String, Codable {
    case stat, ability, choice, route, secret, time, location, unlock, reveal
    // Added for compatibility
    case statChange, endingInfluence, worldState, environmental, heal, debuff, buff, status
}

// MARK: - Path Requirements
enum ComparisonOperator: String, Codable {
    case greaterThan = ">"
    case lessThan = "<"
    case equal = "=="
    case greaterThanOrEqual = ">="
    case lessThanOrEqual = "<="
    case notEqual = "!="
    
    func compareInts(lhs: Int, rhs: Int) -> Bool {
        switch self {
        case .greaterThan: return lhs > rhs
        case .lessThan: return lhs < rhs
        case .equal: return lhs == rhs
        case .greaterThanOrEqual: return lhs >= rhs
        case .lessThanOrEqual: return lhs <= rhs
        case .notEqual: return lhs != rhs
        }
    }
}

struct PathRequirement: Codable {
    let type: RequirementType
    let value: String
    let threshold: Int
    let operatorType: ComparisonOperator
    let isOptional: Bool
}

// MARK: - Route Consequences
struct RouteConsequence: Codable {
    let type: ConsequenceType
    let target: String
    let value: Int
    let isPermanent: Bool
    let unlocksSecret: String?
    let affectsEnding: Bool?
}

// MARK: - Combat Route System
enum CombatRoute: String, Codable, CaseIterable {
    case aggressive = "aggressive"
    case defensive = "defensive"
    case tactical = "tactical"
    case stealth = "stealth"
    case diplomatic = "diplomatic"
    // Added for compatibility
    case pacifist = "pacifist"
    case neutral = "neutral"
    case genocide = "genocide"
    
    var description: String {
        switch self {
        case .aggressive: return "Aggressive Combat"
        case .defensive: return "Defensive Combat"
        case .tactical: return "Tactical Combat"
        case .stealth: return "Stealth Combat"
        case .diplomatic: return "Diplomatic Combat"
        case .pacifist: return "Pacifist Approach"
        case .neutral: return "Neutral Approach"
        case .genocide: return "Genocide Route"
        }
    }
}

// MARK: - Environmental Interaction System
enum InteractionType: String, Codable, CaseIterable {
    case examine, take, use, read, touch, speak, meditate, listen, observe, experience, mourn, track
    
    var description: String {
        switch self {
        case .examine: return "Examine the environment for clues and secrets"
        case .take: return "Take an item from the environment"
        case .use: return "Use an item or object"
        case .read: return "Read text or inscriptions"
        case .touch: return "Touch or interact with an object"
        case .speak: return "Speak to someone or something"
        case .meditate: return "Meditate or reflect"
        case .listen: return "Listen carefully to the sounds around you"
        case .observe: return "Observe the environment for patterns and details"
        case .experience: return "Experience the raw power of this place"
        case .mourn: return "Pay respects to the fallen"
        case .track: return "Track signs of recent activity"
        }
    }
}

// MARK: - Weather & Time Types
enum WeatherType: String, Codable, CaseIterable {
    case clear, cloudy, foggy, windy, hot, cold, humid, dry, magical, cursed
    case rainy, freezing, stormy, mystical, storm
    
    var description: String {
        switch self {
        case .clear: return "Clear skies"
        case .cloudy: return "Cloudy weather"
        case .foggy: return "Foggy conditions"
        case .windy: return "Windy conditions"
        case .hot: return "Hot weather"
        case .cold: return "Cold weather"
        case .humid: return "Humid weather"
        case .dry: return "Dry weather"
        case .magical: return "Magical atmosphere"
        case .cursed: return "Cursed atmosphere"
        case .rainy: return "Rainy weather"
        case .freezing: return "Freezing weather"
        case .stormy: return "Stormy weather"
        case .mystical: return "Mystical atmosphere"
        case .storm: return "Stormy weather"
        }
    }
}

enum TimeOfDay: String, Codable, CaseIterable {
    case dawn, morning, noon, afternoon, evening, dusk, night, midnight
    
    var description: String {
        switch self {
        case .dawn: return "Dawn"
        case .morning: return "Morning"
        case .noon: return "Noon"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .dusk: return "Dusk"
        case .night: return "Night"
        case .midnight: return "Midnight"
        }
    }
}

// MARK: - Visual Effects
enum VisualEffect: String, Codable, CaseIterable {
    case none, glow, sparkle, shadow, mist, light, dark, color, pulse, wave
    // Added for compatibility
    case corruption, redemption
    
    var description: String {
        switch self {
        case .none: return "No effect"
        case .glow: return "Glowing effect"
        case .sparkle: return "Sparkling effect"
        case .shadow: return "Shadow effect"
        case .mist: return "Misty effect"
        case .light: return "Light effect"
        case .dark: return "Dark effect"
        case .color: return "Color effect"
        case .pulse: return "Pulsing effect"
        case .wave: return "Wave effect"
        case .corruption: return "Corruption effect"
        case .redemption: return "Redemption effect"
        }
    }
}

// MARK: - Effect Types
enum EffectType: String, Codable, CaseIterable {
    case stat = "stat"
    case ability = "ability"
    case choice = "choice"
    case route = "route"
    case secret = "secret"
    case time = "time"
    case location = "location"
    case environmental = "environmental"
    // Added for compatibility
    case heal = "heal"
    case debuff = "debuff"
    case buff = "buff"
    case status = "status"
}

enum EffectTarget: String, Codable, CaseIterable {
    case player = "player"
    case ally = "ally"
    case enemy = "enemy"
    case environment = "environment"
    case story = "story"
    case world = "world"
    // Added for compatibility
    case `self` = "self"
}

struct EnvironmentalEffect: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let type: EffectType
    let target: EffectTarget
    let value: Int
    let duration: TimeInterval?
    let requirements: [ChoiceRequirement]
    
    init(id: String, name: String, description: String, type: EffectType, target: EffectTarget, value: Int, duration: TimeInterval? = nil, requirements: [ChoiceRequirement] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.target = target
        self.value = value
        self.duration = duration
        self.requirements = requirements
    }
}

// MARK: - Weather and Time Effects
struct WeatherEffect: Codable {
    let type: WeatherType
    let intensity: Double
    let duration: TimeInterval
    let effects: [String]
}

struct TimeEffect: Codable {
    let type: TimeOfDay
    let duration: TimeInterval
    let effects: [String]
}

struct EnvironmentModifier: Codable {
    let statBonus: [StatType: Int]
    let abilityBonus: [String: Int]
    let routePoints: Int
}

// MARK: - Combat Environment
struct CombatEnvironment: Codable {
    let hazards: [EnvironmentalHazard]
    let advantages: [EnvironmentalAdvantage]
    let interactables: [String]
    let weatherEffect: WeatherEffect?
    let timeEffect: TimeEffect?
    let routeModifiers: [StoryRoute: EnvironmentModifier]
    
    init(hazards: [EnvironmentalHazard] = [], advantages: [EnvironmentalAdvantage] = [], interactables: [String] = [], weatherEffect: WeatherEffect? = nil, timeEffect: TimeEffect? = nil, routeModifiers: [StoryRoute: EnvironmentModifier] = [:]) {
        self.hazards = hazards
        self.advantages = advantages
        self.interactables = interactables
        self.weatherEffect = weatherEffect
        self.timeEffect = timeEffect
        self.routeModifiers = routeModifiers
    }
}

struct EnvironmentalHazard: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let damage: Int
    let trigger: HazardTrigger
    let avoidable: Bool
}

enum HazardTrigger: String, Codable {
    case turnStart, turnEnd, movement, action, random
}

enum CombatState: String, Codable {
    case none, active, victory, defeat, fled
}

struct EnvironmentalAdvantage: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let bonus: [StatType: Int]
    let condition: String?
}

// MARK: - Combat Styles
enum CombatStyle: String, Codable, CaseIterable {
    case assassin, healer, guardian, warrior, mage, rogue, archer, support, tank, unknown
}

enum Rarity: String, Codable, CaseIterable {
    case common, rare, epic, legendary, mythic
}

// MARK: - Complex Betrayal System
struct BetrayalEvent {
    let id: String
    let betrayer: String
    let trigger: BetrayalTrigger
    let consequences: [BetrayalConsequence]
    let isPreventable: Bool
    let preventionRequirements: [PathRequirement]
    let warningSigns: [String]
    let aftermath: String
}

enum BetrayalTrigger: String, Codable {
    case lowLoyalty, highCorruption, routeConflict, secretDiscovery, timeBased, choiceBased, statThreshold
}

struct BetrayalConsequence {
    let type: BetrayalConsequenceType
    let target: String
    let value: Int
    let isPermanent: Bool
    let affectsEnding: Bool
}

enum BetrayalConsequenceType: String, Codable {
    case statLoss, relationshipBreak, routeLock, secretReveal, combatPenalty, endingChange
}

// MARK: - Unique Route Scenes
struct RouteScene {
    let id: String
    let route: StoryRoute
    let chapter: Int
    let title: String
    let narrative: String
    let choices: [RouteChoice]
    let requirements: [PathRequirement]
    let isSecret: Bool
    let affectsEnding: Bool
    let ambientAudio: String?
    let visualEffect: VisualEffect?
}

struct RouteChoice {
    let id: String
    let text: String
    let consequences: [RouteConsequence]
    let requirements: [PathRequirement]
    let isHidden: Bool
    let affectsRoute: Bool
}

// MARK: - Enhanced Combat Variety
struct AdvancedCombatEncounter {
    let id: String
    let title: String
    let narrative: String
    let enemies: [AdvancedEnemy]
    let allies: [Ally]?
    let environment: CombatEnvironment
    let victoryConditions: [VictoryCondition]
    let defeatConditions: [DefeatCondition]
    let isRouteSpecific: Bool
    let affectsEnding: Bool
}

struct AdvancedEnemy {
    let name: String
    let health: Int
    let maxHealth: Int
    let abilities: [AdvancedEnemyAbility]
    let weaknesses: [StatType]
    let resistances: [StatType]
    let personality: EnemyPersonality
    let backstory: String
    let canBeSpared: Bool
    let sparingConsequences: [Consequence]
    let routeAffinity: [CombatRoute: Int]
}

struct AdvancedEnemyAbility {
    let name: String
    let description: String
    let damage: Int
    let effect: AdvancedAbilityEffect
    let cooldown: Int
    let trigger: AbilityTrigger
    let condition: String?
}

struct AdvancedAbilityEffect {
    let type: EffectType
    let target: EffectTarget
    let magnitude: Int
    let duration: Int
    let secondaryEffect: SecondaryEffect?
}

struct SecondaryEffect {
    let type: EffectType
    let probability: Double
    let magnitude: Int
    let duration: Int
}

enum AbilityTrigger: String, Codable {
    case turnStart, turnEnd, healthThreshold, allyDeath, playerAction, environmental, random
}

// These types are already defined above with Codable conformance

struct VictoryCondition {
    let type: VictoryType
    let target: String
    let value: Int
    let isOptional: Bool
}

enum VictoryType: String, Codable {
    case defeatAll, spareAll, reachLocation, completeObjective, surviveTurns, achieveRoute
}

struct DefeatCondition {
    let type: DefeatType
    let target: String
    let value: Int
}

enum DefeatType: String, Codable {
    case healthZero, sanityZero, corruptionMax, timeLimit, allyDeath, routeFailure
}

// MARK: - Secrets System
struct Secret {
    let id: String
    let name: String
    let description: String
    let location: String
    let requirements: [PathRequirement]
    let consequences: [SecretConsequence]
    let isRouteSpecific: Bool
    let affectsEnding: Bool
}

struct SecretConsequence: Codable {
    let type: SecretConsequenceType
    let target: String
    let value: Int
    let isPermanent: Bool
    let unlocksPath: String?
}

enum SecretConsequenceType: String, Codable {
    case statBonus, routePoints, secretUnlock, endingInfluence, combatAdvantage, storyReveal
    // Added for compatibility
    case allyRecruit
}

// MARK: - Ally System
struct Ally: Codable, Identifiable {
    let id: String
    let name: String
    let personality: AllyPersonality
    let abilities: [AllyAbility]
    let loyalty: Int
    let maxLoyalty: Int
    let betrayalRisk: Int
    let romancePotential: Int
    let backstory: String
    let secrets: [String]
    let routeAffinity: [StoryRoute: Int]
    let combatStyle: CombatStyle
    let dialogueOptions: [String: [String]]
}

enum AllyPersonality: String, Codable {
    case loyal, cautious, ambitious, mysterious, conflicted, fanatical
    // Added for compatibility
    case peaceful, aggressive
}

struct AllyAbility: Codable {
    let name: String
    let description: String
    let effect: AllyAbilityEffect
    let cooldown: Int
    let loyaltyRequirement: Int
}

struct AllyAbilityEffect: Codable {
    let type: EffectType
    let target: EffectTarget
    let magnitude: Int
    let duration: Int
    let condition: String?
}

// MARK: - Enemy Personality
enum EnemyPersonality: String, Codable {
    case aggressive, defensive, cunning, honorable, chaotic, calculating
    // Added for compatibility
    case methodical
}

// MARK: - Accessibility Settings
struct AccessibilitySettings: Codable {
    var textSize: TextSize = .medium
    var highContrast: Bool = false
    var colorBlindFriendly: Bool = false
    var screenReaderSupport: Bool = false
    var audioDescriptions: Bool = false
    var reduceMotion: Bool = false
    var disableAnimations: Bool = false
    var largeTouchTargets: Bool = false
    var voiceControlSupport: Bool = false
}

enum TextSize: String, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var stats = PlayerStats()
    @Published var currentChapter = 1
    @Published var currentScene = 0
    @Published var weather = WeatherType.clear
    @Published var timeOfDay = TimeOfDay.morning
    @Published var currentRoute: StoryRoute = .neutral
    @Published var unlockedRoutes: Set<StoryRoute> = [.neutral]
    @Published var completedInteractions: Set<String> = []
    @Published var accessibilitySettings = AccessibilitySettings()
    @Published var environmentalInteractions: [EnvironmentalInteraction] = []
    @Published var availableInteractions: [InteractableObject] = []
    @Published var currentCombat: CombatEncounter?
    @Published var combatTurn: Int = 1
    @Published var availableActions: [CombatAction] = []
    @Published var enemyHealth: Int = 100
    @Published var combatState: CombatState = .none
    @Published var currentInteraction: EnvironmentalInteraction?
    @Published var showingInteraction = false
    
    // MARK: - Game Flow Properties
    @Published var isBroken: Bool = false
    @Published var showingNewGameInit: Bool = false
    @Published var hasStartedGame: Bool = false
    @Published var hasCompletedTutorial: Bool = false
    @Published var showingIntro: Bool = false
    @Published var showingBlackTransition: Bool = false
    @Published var showingMainMenu: Bool = false
    @Published var dayCount: Int = 1
    @Published var relationships: [Relationship] = []
    @Published var abilityManager = AbilityManager.shared
    @Published var showingCharacterCreation: Bool = false
    @Published var showingAIStories: Bool = false
    @Published var showingDiscoverAIStories: Bool = false
    @Published var showingSettings: Bool = false
    @Published var showingStoryView: Bool = false
    @Published var showingAchievements: Bool = false
    @Published var showingCommunity: Bool = false
    @Published var selectedStory: StoryOption?
    
    // MARK: - Audio and Visual Settings
    @Published var audioVolume: Double = 0.7
    @Published var musicEnabled: Bool = true
    @Published var musicVolume: Double = 0.6
    @Published var soundEffectsVolume: Double = 0.5
    @Published var dayNightCycle: Bool = true
    @Published var smoothTransitions: Bool = true
    @Published var visualEffectsEnabled: Bool = true
    @Published var weatherEffects: Bool = true
    @Published var atmosphericBlending: Bool = true
    @Published var dynamicLighting: Bool = true
    @Published var particleEffects: Bool = true
    @Published var responsiveUI: Bool = true
    @Published var optimizedPerformance: Bool = true
    @Published var memoryEfficient: Bool = true
    
    // --- Added for compatibility with ChapterView.swift ---
    @Published var routePoints: [String: Int] = [:]
    @Published var majorChoices: [String: String] = [:]
    @Published var discoveredPaths: Set<String> = []
    @Published var discoveredSecrets: Set<String> = []
    @Published var triggeredBetrayals: Set<String> = []
    @Published var preventedBetrayals: Set<String> = []
    @Published var discoveredRouteScenes: Set<String> = []
    @Published var discoveredObjects: Set<String> = []
    @Published var previousChoices: Set<String> = []
    @Published var allyLoyalty: [String: Int] = [:]
    @Published var currentMood: String = ""
    @Published var location: String = ""
    @Published var activeAllies: [String] = []
    
    // MARK: - Day/Night System
    @Published var currentTimeOfDay: TimeOfDay = .morning
    @Published var currentParagraph: Int = 1
    @Published var dayNightCycleEnabled: Bool = true
    @Published var timeProgressionRate: Double = 1.0
    // --- End compatibility additions ---
    
    // MARK: - Initialization
    init() {
        loadGameState()
        setupEnvironmentalInteractions()
    }
    
    // MARK: - Environmental Interactions
    private func setupEnvironmentalInteractions() {
        environmentalInteractions = [
            EnvironmentalInteraction(
                id: "examine_ruins",
                title: "Examine Ancient Ruins",
                description: "Look closely at the weathered stones for hidden markings",
                type: .examine,
                consequences: [Consequence(stat: .magic, change: 5)]
            ),
            EnvironmentalInteraction(
                id: "listen_wind",
                title: "Listen to the Wind",
                description: "Close your eyes and listen to the whispers carried by the wind",
                type: .listen,
                consequences: [Consequence(stat: .intelligence, change: 3)]
            ),
            EnvironmentalInteraction(
                id: "touch_crystal",
                title: "Touch the Crystal",
                description: "Feel the energy pulsing through the ancient crystal",
                type: .touch,
                consequences: [Consequence(stat: .magic, change: 8)]
            ),
            EnvironmentalInteraction(
                id: "meditate_here",
                title: "Meditate Here",
                description: "Find inner peace in this sacred place",
                type: .meditate,
                consequences: [Consequence(stat: .wisdom, change: 5)]
            )
        ]
    }
    
    func triggerEnvironmentalInteraction(_ interaction: EnvironmentalInteraction) async {
        currentInteraction = interaction
        showingInteraction = true
        
        // Apply consequences
        for consequence in interaction.consequences {
            stats.applyConsequence(consequence)
        }
        
        // Mark as completed
        completedInteractions.insert(interaction.id)
        
        // Trigger haptic feedback
        HapticManager.shared.impact(.medium)
    }
    
    // MARK: - Route Management
    func unlockRoute(_ route: StoryRoute) {
        unlockedRoutes.insert(route)
        saveGameState()
    }
    
    func setCurrentRoute(_ route: StoryRoute) {
        currentRoute = route
        saveGameState()
    }
    
    // MARK: - Weather and Time Management
    func changeWeather(_ newWeather: WeatherType) {
        weather = newWeather
        saveGameState()
    }
    
    func changeTimeOfDay(_ newTime: TimeOfDay) {
        timeOfDay = newTime
        currentTimeOfDay = newTime
        saveGameState()
    }
    
    // MARK: - Day/Night System Management
    func advanceTimeOfDay() {
        switch currentTimeOfDay {
        case .dawn:
            currentTimeOfDay = .morning
        case .morning:
            currentTimeOfDay = .noon
        case .noon:
            currentTimeOfDay = .afternoon
        case .afternoon:
            currentTimeOfDay = .evening
        case .evening:
            currentTimeOfDay = .dusk
        case .dusk:
            currentTimeOfDay = .night
        case .night:
            currentTimeOfDay = .midnight
        case .midnight:
            currentTimeOfDay = .dawn
            dayCount += 1
        }
        saveGameState()
    }
    
    func setTimeOfDay(_ time: TimeOfDay) {
        currentTimeOfDay = time
        timeOfDay = time
        saveGameState()
    }
    
    func incrementParagraph() {
        currentParagraph += 1
        saveGameState()
    }
    
    func resetParagraph() {
        currentParagraph = 1
        saveGameState()
    }
    
    // MARK: - Accessibility
    func updateAccessibilitySettings(_ settings: AccessibilitySettings) {
        accessibilitySettings = settings
        saveGameState()
    }
    
    // MARK: - Persistence
    private func saveGameState() {
        // Implementation for saving game state
    }
    
    private func loadGameState() {
        // Implementation for loading game state
    }
    
    func loadGameFromSaveData(_ saveData: SaveData) {
        stats = saveData.playerStats
        currentChapter = saveData.currentChapter
        currentScene = saveData.currentScene
        weather = saveData.currentWeather
        timeOfDay = saveData.currentTimeOfDay
        currentTimeOfDay = saveData.currentTimeOfDay
        currentParagraph = saveData.currentParagraph
        currentRoute = saveData.currentRoute
        unlockedRoutes = saveData.unlockedRoutes
        completedInteractions = saveData.completedInteractions
        accessibilitySettings = saveData.accessibilitySettings
        dayCount = saveData.dayCount
        relationships = saveData.relationships
        hasStartedGame = true
        showingNewGameInit = false
    }
    
    func completeNewGameInit() {
        showingCharacterCreation = true
        showingNewGameInit = false
        hasCompletedTutorial = false // Only set true after character creation
        hasStartedGame = false // Only set true after character creation
        // Initialize any other new game state
        currentChapter = 1
        currentScene = 0
        dayCount = 1
    }
    
    // MARK: - Reset Functions
    func resetGame() {
        stats = PlayerStats()
        currentChapter = 1
        currentScene = 0
        weather = .clear
        timeOfDay = .morning
        currentRoute = .neutral
        unlockedRoutes = [.neutral]
        completedInteractions.removeAll()
        accessibilitySettings = AccessibilitySettings()
        showingCharacterCreation = false
        saveGameState()
    }
    
    func performCompleteReset() {
        // Reset all game state
        stats = PlayerStats()
        currentChapter = 1
        currentScene = 0
        weather = .clear
        timeOfDay = .morning
        currentRoute = .neutral
        unlockedRoutes = [.neutral]
        completedInteractions.removeAll()
        accessibilitySettings = AccessibilitySettings()
        
        // Reset all game flow states
        isBroken = false
        showingNewGameInit = false
        hasStartedGame = false
        hasCompletedTutorial = false
        showingIntro = false
        showingBlackTransition = false
        showingMainMenu = false
        showingCharacterCreation = false
        showingAIStories = false
        showingSettings = false
        
        // Reset day and relationships
        dayCount = 1
        relationships.removeAll()
        
        // Reset all tracking data
        routePoints.removeAll()
        majorChoices.removeAll()
        discoveredPaths.removeAll()
        discoveredSecrets.removeAll()
        triggeredBetrayals.removeAll()
        preventedBetrayals.removeAll()
        discoveredRouteScenes.removeAll()
        discoveredObjects.removeAll()
        previousChoices.removeAll()
        allyLoyalty.removeAll()
        activeAllies.removeAll()
        
        // Reset current state
        currentTimeOfDay = .morning
        currentParagraph = 1
        currentMood = ""
        location = ""
        
        // Reset audio settings to defaults
        musicEnabled = true
        musicVolume = 0.6
        soundEffectsVolume = 0.5
        audioVolume = 0.7
        
        // Reset visual settings to defaults
        dayNightCycle = true
        smoothTransitions = true
        visualEffectsEnabled = true
        weatherEffects = true
        atmosphericBlending = true
        dynamicLighting = true
        particleEffects = true
        responsiveUI = true
        optimizedPerformance = true
        memoryEfficient = true
        
        // Clear all save data
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
        
        // Reset achievement manager
        AchievementManager.shared.resetAllAchievements()
        
        // Reset ending calculator
        EndingCalculator.shared.resetEndings()
        
        print("🎮 Complete reset performed - all data cleared")
    }
    
    func startNewPlaythrough() {
        resetGame()
        // Additional setup for new playthrough
    }
    
    func startNewGame() {
        // Manual reset to avoid any flash issues
        stats = PlayerStats()
        currentChapter = 1
        currentScene = 0
        weather = .clear
        timeOfDay = .morning
        currentRoute = .neutral
        unlockedRoutes = [.neutral]
        completedInteractions.removeAll()
        accessibilitySettings = AccessibilitySettings()
        
        // Set new game states
        hasStartedGame = false
        showingNewGameInit = true
        showingCharacterCreation = false
        showingIntro = false
        showingMainMenu = false
        
        print("🎮 startNewGame() called - hasStartedGame: \(hasStartedGame), showingNewGameInit: \(showingNewGameInit)")
    }
    
    // MARK: - Stat Modification Wrappers
    func modifyHealth(_ change: Int) {
        var s = stats
        s.modifyHealth(change)
        stats = s
    }
    func modifyStrength(_ change: Int) {
        var s = stats
        s.modifyStrength(change)
        stats = s
    }
    func modifyIntelligence(_ change: Int) {
        var s = stats
        s.modifyIntelligence(change)
        stats = s
    }
    func modifyCharisma(_ change: Int) {
        var s = stats
        s.modifyCharisma(change)
        stats = s
    }
    func modifyMagic(_ change: Int) {
        var s = stats
        s.modifyMagic(change)
        stats = s
    }
    func modifyHunger(_ change: Int) {
        var s = stats
        s.modifyHunger(change)
        stats = s
    }
    func modifyCompassion(_ change: Int) {
        var s = stats
        s.modifyCompassion(change)
        stats = s
    }
    func modifyResolve(_ change: Int) {
        var s = stats
        s.modifyResolve(change)
        stats = s
    }
    func modifyEmpathy(_ change: Int) {
        var s = stats
        s.modifyEmpathy(change)
        stats = s
    }
    func modifyEnergy(_ change: Int) {
        var s = stats
        s.modifyEnergy(change)
        stats = s
    }
    func modifyKaiLoyalty(_ change: Int) {
        var s = stats
        s.modifyKaiLoyalty(change)
        stats = s
    }
    func modifyNayaTrust(_ change: Int) {
        var s = stats
        s.modifyNayaTrust(change)
        stats = s
    }
    func modifyAncientOneFavor(_ change: Int) {
        var s = stats
        s.modifyAncientOneFavor(change)
        stats = s
    }
    func modifyMoney(_ change: Double) {
        var s = stats
        s.modifyMoney(change)
        stats = s
    }
    func modifyMorality(_ change: Double) {
        var s = stats
        s.modifyMorality(change)
        stats = s
    }
    func modifyCourage(_ change: Int) {
        var s = stats
        s.modifyCourage(change)
        stats = s
    }
    func modifyAdaptability(_ change: Int) {
        var s = stats
        s.modifyAdaptability(change)
        stats = s
    }
    // --- Add stub methods for compatibility ---
    func unlockAchievement(_ id: String) { print("Achievement unlocked: \(id)") }
    func unlockEnding(_ id: String) { print("Ending unlocked: \(id)") }
    func discoverAlternatePath(_ id: String) { discoveredPaths.insert(id) }
    func discoverPath(_ path: BranchingPath) { discoveredPaths.insert(path.id) }
    func triggerBetrayalEvent(_ id: String) { triggeredBetrayals.insert(id) }
    func discoverRouteScene(_ id: String) { discoveredRouteScenes.insert(id) }
    func discoverSecret(_ id: String) { discoveredSecrets.insert(id) }
    func getRelationshipLevel(with id: String) -> Int { return relationships.first(where: { $0.id == id })?.value ?? 0 }
    func modifyStat(_ stat: String, by value: Int) { stats.modifyStat(stat, by: value) }
    func addRoutePoints(_ points: Int, for route: StoryRoute) { routePoints[route.rawValue, default: 0] += points }
    func recordRouteDecision(choice: String, route: StoryRoute) { majorChoices[choice] = route.rawValue }
    func getRoutePoints(for route: StoryRoute) -> Int { return routePoints[route.rawValue] ?? 0 }
    func getRoutePoints(forKey key: String) -> Int { return routePoints[key] ?? 0 }
    // --- End stub methods ---
    
    func nextChapter() {
        // Stub implementation
        if currentChapter < 10 {
            currentChapter += 1
        }
    }
    
    // MARK: - Missing Methods for ChapterView
    
    func applyConsequence(_ consequence: Consequence) {
        switch consequence.type {
        case .stat:
            stats.modifyStat(consequence.target, by: consequence.value)
        case .ability:
            // Handle ability consequences
            print("Ability consequence: \(consequence.target) + \(consequence.value)")
        case .choice:
            // Handle choice consequences
            print("Choice consequence: \(consequence.target)")
        case .route:
            // Handle route consequences
            print("Route consequence: \(consequence.target)")
        case .secret:
            // Handle secret consequences
            print("Secret consequence: \(consequence.target)")
        case .time:
            // Handle time consequences
            print("Time consequence: \(consequence.target)")
        case .location:
            // Handle location consequences
            print("Location consequence: \(consequence.target)")
        case .environmental:
            // Handle environmental consequences
            print("Environmental consequence: \(consequence.target)")
        case .heal:
            stats.modifyHealth(consequence.value)
        case .debuff:
            // Handle debuff consequences
            print("Debuff consequence: \(consequence.target)")
        case .buff:
            // Handle buff consequences
            print("Buff consequence: \(consequence.target)")
        case .status:
            // Handle status consequences
            print("Status consequence: \(consequence.target)")
        case .unlock:
            // Handle unlock consequences
            print("Unlock consequence: \(consequence.target)")
        case .reveal:
            // Handle reveal consequences
            print("Reveal consequence: \(consequence.target)")
        case .statChange:
            // Handle statChange consequences
            print("StatChange consequence: \(consequence.target)")
        case .endingInfluence:
            // Handle endingInfluence consequences
            print("EndingInfluence consequence: \(consequence.target)")
        case .worldState:
            // Handle worldState consequences
            print("WorldState consequence: \(consequence.target)")
        }
    }
    
    func shouldTriggerBetrayal() -> Bool {
        // Simple betrayal trigger logic
        return stats.corruption > 70 || stats.sanity < 30
    }
    
    func getAvailableRouteScene() -> RouteScene? {
        // Return nil for now - implement proper route scene logic later
        return nil
    }
    
    func getAvailableSecret() -> Secret? {
        // Return nil for now - implement proper secret logic later
        return nil
    }
    
    func hasAbility(_ ability: Ability) -> Bool {
        return stats.abilities.contains { $0.type == ability.type }
    }
    
    func getStatValue(_ statName: String) -> Int {
        return stats.getStatValue(statName)
    }
    
    func interactWithObject(_ objectId: String) -> Consequence? {
        // Simple interaction logic
        return Consequence(stat: .intelligence, change: 1)
    }
    
    func findSecret(_ secret: String) {
        // Simple secret finding logic
        print("Secret found: \(secret)")
    }
    
    // MARK: - Combat System Stub
    func performCombatAction(_ action: CombatAction) -> CombatResult {
        // TODO: Implement combat logic
        return .continue
    }
}

// MARK: - Missing Types

struct Relationship: Codable {
    let id: String
    let name: String
    let value: Int
    let maxValue: Int
    let type: RelationshipType
}

enum RelationshipType: String, Codable {
    case friendship, romance, rivalry, mentorship, alliance, enmity
}

struct CombatAction: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let damage: Int
    let cost: Int
    let type: CombatActionType
    let requirements: [ChoiceRequirement]
    let effects: [StoryEffect]
    
    init(id: String, name: String, description: String, damage: Int, cost: Int, type: CombatActionType, requirements: [ChoiceRequirement] = [], effects: [StoryEffect] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.damage = damage
        self.cost = cost
        self.type = type
        self.requirements = requirements
        self.effects = effects
    }
}

enum CombatActionType: String, Codable {
    case attack, defend, special, item, flee, ability, environmental, dialogue
}

struct InteractableObject: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let type: InteractionType
    let consequences: [Consequence]
    let requirements: [ChoiceRequirement]
}

// PathConsequence
struct PathConsequence: Codable {
    let type: PathConsequenceType
    let target: String
    let value: Int
    let isPermanent: Bool
    let affectsRoute: Bool
}

enum PathConsequenceType: String, Codable {
    case stat, route, choice, ability, secret
}

struct BranchingPath: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let requirements: [PathRequirement]
    let consequences: [PathConsequence]
    let affectsEnding: Bool
    let unlockCondition: RequirementType?
    let unlockMethod: UnlockMethod?
    let isSecret: Bool?
}

enum UnlockCondition: String, Codable {
    case stat, choice, exploration, time, achievement, secret
}

enum UnlockMethod: String, Codable {
    case exploration, combat, dialogue, puzzle, event
}

struct AdvancedEnding: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let requirements: [EndingRequirement]
    let consequences: [EndingConsequence]
    let isSecret: Bool
    let routeSpecific: StoryRoute?
    let rarity: Rarity?
}

// EndingRequirement and EndingConsequence
struct EndingRequirement: Codable {
    let type: RequirementType
    let target: String
    let value: Int
    let operatorType: ComparisonOperator
}

struct EndingConsequence: Codable {
    let type: ConsequenceType
    let target: String
    let value: Int
    let isPermanent: Bool
}

enum EnemyType: String, Codable {
    case human, beast, undead, demon, construct, elemental
}

enum CombatResult {
    case victory
    case defeat
    case `continue`
    case fled
} 

extension StoryRoute {
    static var isolation: StoryRoute { .neutral } // fallback, or add real case if needed
}

extension PlayerStats {
    mutating func modifyStat(_ stat: String, by value: Int) {
        // Implement stat modification by string name
        switch stat.lowercased() {
        case "health": modifyHealth(value)
        case "strength": modifyStrength(value)
        case "intelligence": modifyIntelligence(value)
        case "charisma": modifyCharisma(value)
        case "magic": modifyMagic(value)
        case "hunger": modifyHunger(value)
        case "compassion": modifyCompassion(value)
        case "resolve": modifyResolve(value)
        case "empathy": modifyEmpathy(value)
        case "energy": modifyEnergy(value)
        case "kailoyalty": modifyKaiLoyalty(value)
        case "nayatrust": modifyNayaTrust(value)
        case "ancientonefavor": modifyAncientOneFavor(value)
        case "courage": modifyCourage(value)
        case "adaptability": modifyAdaptability(value)
        default: break
        }
    }
} 
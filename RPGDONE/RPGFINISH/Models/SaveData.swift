import Foundation

struct SaveData: Codable {
    let playerStats: PlayerStats
    let currentChapter: Int
    let currentScene: Int
    let hasStartedGame: Bool
    let hasCompletedTutorial: Bool
    let isBroken: Bool
    let currentTimeOfDay: TimeOfDay
    let currentParagraph: Int
    let currentWeather: WeatherType
    let currentRoute: StoryRoute
    let unlockedRoutes: Set<StoryRoute>
    let completedInteractions: Set<String>
    let accessibilitySettings: AccessibilitySettings
    let dayCount: Int
    let relationships: [Relationship]
    let abilities: [Ability]
    let saveDate: Date
    
    init(playerStats: PlayerStats, gameState: GameState) {
        self.playerStats = playerStats
        self.currentChapter = gameState.currentChapter
        self.currentScene = gameState.currentScene
        self.hasStartedGame = gameState.hasStartedGame
        self.hasCompletedTutorial = gameState.hasCompletedTutorial
        self.isBroken = gameState.isBroken
        self.currentTimeOfDay = gameState.timeOfDay
        self.currentParagraph = gameState.currentParagraph
        self.currentWeather = gameState.weather
        self.currentRoute = gameState.currentRoute
        self.unlockedRoutes = gameState.unlockedRoutes
        self.completedInteractions = gameState.completedInteractions
        self.accessibilitySettings = gameState.accessibilitySettings
        self.dayCount = gameState.dayCount
        self.relationships = gameState.relationships
        self.abilities = AbilityManager.shared.unlockedAbilities
        self.saveDate = Date()
    }
} 
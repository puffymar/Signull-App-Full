import Foundation
import SwiftUI

// MARK: - Environmental Interaction System

struct EnvironmentalInteraction: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let type: InteractionType
    let consequences: [Consequence]
    let requirements: [ChoiceRequirement]
    
    init(id: String, title: String, description: String, type: InteractionType, consequences: [Consequence], requirements: [ChoiceRequirement] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.consequences = consequences
        self.requirements = requirements
    }
}

// MARK: - Core Chapter Models

struct Chapter: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let scenes: [StoryScene]
    let choices: [Choice]
    let requirements: [ChoiceRequirement]
    let consequences: [Consequence]
    let weather: WeatherType
    let timeOfDay: TimeOfDay
    let atmosphericEffect: VisualEffect
    let audioId: String?
    let estimatedDuration: TimeInterval
    
    init(id: Int, title: String, description: String, scenes: [StoryScene], choices: [Choice], requirements: [ChoiceRequirement] = [], consequences: [Consequence] = [], weather: WeatherType = .clear, timeOfDay: TimeOfDay = .morning, atmosphericEffect: VisualEffect = .none, audioId: String? = nil, estimatedDuration: TimeInterval = 1800) {
        self.id = id
        self.title = title
        self.description = description
        self.scenes = scenes
        self.choices = choices
        self.requirements = requirements
        self.consequences = consequences
        self.weather = weather
        self.timeOfDay = timeOfDay
        self.atmosphericEffect = atmosphericEffect
        self.audioId = audioId
        self.estimatedDuration = estimatedDuration
    }
}

struct StoryScene: Codable, Identifiable {
    let id: String
    let title: String
    let narrative: String
    let choices: [Choice]
    let consequences: [Consequence]
    let weather: WeatherType?
    let timeOfDay: TimeOfDay?
    let atmosphericEffect: VisualEffect?
    let audioId: String?
    let estimatedDuration: TimeInterval
    
    init(id: String, title: String, narrative: String, choices: [Choice] = [], consequences: [Consequence] = [], weather: WeatherType? = nil, timeOfDay: TimeOfDay? = nil, atmosphericEffect: VisualEffect? = nil, audioId: String? = nil, estimatedDuration: TimeInterval = 300) {
        self.id = id
        self.title = title
        self.narrative = narrative
        self.choices = choices
        self.consequences = consequences
        self.weather = weather
        self.timeOfDay = timeOfDay
        self.atmosphericEffect = atmosphericEffect
        self.audioId = audioId
        self.estimatedDuration = estimatedDuration
    }
}

struct Choice: Codable, Identifiable {
    let id: String
    let text: String
    let consequences: [Consequence]
    let requirements: [ChoiceRequirement]
    let nextSceneId: String?
    let nextChapterId: Int?
    let audioId: String?
    
    init(id: String, text: String, consequences: [Consequence] = [], requirements: [ChoiceRequirement] = [], nextSceneId: String? = nil, nextChapterId: Int? = nil, audioId: String? = nil) {
        self.id = id
        self.text = text
        self.consequences = consequences
        self.requirements = requirements
        self.nextSceneId = nextSceneId
        self.nextChapterId = nextChapterId
        self.audioId = audioId
    }
}

struct ChoiceRequirement: Codable {
    let type: RequirementType
    let target: String
    let value: Int
    let operatorType: ComparisonOperator
    
    init(type: RequirementType, target: String, value: Int, operatorType: ComparisonOperator = .greaterThanOrEqual) {
        self.type = type
        self.target = target
        self.value = value
        self.operatorType = operatorType
    }
}

struct Consequence: Codable {
    let type: ConsequenceType
    let target: String
    let value: Int
    let description: String?
    
    init(type: ConsequenceType = .stat, target: String, value: Int, description: String? = nil) {
        self.type = type
        self.target = target
        self.value = value
        self.description = description
    }
    
    // Convenience initializer for stat changes
    init(stat: StatType, change: Int) {
        self.type = .stat
        self.target = stat.rawValue
        self.value = change
        self.description = "\(change > 0 ? "+" : "")\(change) \(stat.rawValue)"
    }
}

// MARK: - Combat System

struct CombatEncounter: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let enemies: [Enemy]
    let allies: [Ally]
    let environment: CombatEnvironment
    let consequences: [Consequence]
    let requirements: [ChoiceRequirement]
    let estimatedDuration: TimeInterval
    
    init(id: String, title: String, description: String, enemies: [Enemy] = [], allies: [Ally] = [], environment: CombatEnvironment = CombatEnvironment(hazards: [], advantages: [], interactables: [], weatherEffect: nil, timeEffect: nil, routeModifiers: [:]), consequences: [Consequence] = [], requirements: [ChoiceRequirement] = [], estimatedDuration: TimeInterval = 600) {
        self.id = id
        self.title = title
        self.description = description
        self.enemies = enemies
        self.allies = allies
        self.environment = environment
        self.consequences = consequences
        self.requirements = requirements
        self.estimatedDuration = estimatedDuration
    }
}

struct Enemy: Codable, Identifiable {
    let id: String
    let name: String
    let health: Int
    let maxHealth: Int
    let attack: Int
    let defense: Int
    let abilities: [EnemyAbility]
    let weaknesses: [String]
    let resistances: [String]
    let description: String
    
    init(id: String, name: String, health: Int, maxHealth: Int, attack: Int, defense: Int, abilities: [EnemyAbility] = [], weaknesses: [String] = [], resistances: [String] = [], description: String = "") {
        self.id = id
        self.name = name
        self.health = health
        self.maxHealth = maxHealth
        self.attack = attack
        self.defense = defense
        self.abilities = abilities
        self.weaknesses = weaknesses
        self.resistances = resistances
        self.description = description
    }
}

struct EnemyAbility: Codable {
    let name: String
    let description: String
    let damage: Int
    let effects: [String]
    let cooldown: Int
}

// Ally, AllyPersonality, AllyAbility, and CombatEnvironment are defined in GameState.swift

// MARK: - Chapter Content Manager

class ChapterContentManager: ObservableObject {
    @Published var chapters: [Chapter] = []
    
    init() {
        loadChapters()
    }
    
    private func loadChapters() {
        chapters = createDefaultChapters()
    }
    
    func getChapter(_ id: Int) -> Chapter? {
        return chapters.first { $0.id == id }
    }
    
    func getNextChapter(_ currentId: Int) -> Chapter? {
        return chapters.first { $0.id == currentId + 1 }
    }
    
    // MARK: - Default Chapter Creation
    
    private func createDefaultChapters() -> [Chapter] {
        return [
            createChapterOne(),
            createChapterTwo(),
            createChapterThree(),
            createChapterFour(),
            createChapterFive(),
            createChapterSix(),
            createChapterSeven(),
            createChapterEight(),
            createChapterNine(),
            createChapterTen()
        ]
    }
    
    private func createChapterOne() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch1_intro",
                title: "The Wasteland",
                narrative: "You wake in a desolate wasteland, the ruins of an ancient civilization stretching as far as the eye can see. The air is thick with dust and the scent of decay. Your teacher's lifeless body lies nearby, a victim of the cataclysm that destroyed this world.",
                choices: [
                    Choice(id: "explore_ruins", text: "Explore the ruins ahead", consequences: [Consequence(stat: .magic, change: 10)]),
                    Choice(id: "seek_shelter", text: "Seek shelter in the nearby cave", consequences: [Consequence(stat: .courage, change: 15)]),
                    Choice(id: "mourn_teacher", text: "Take time to mourn your teacher", consequences: [Consequence(stat: .wisdom, change: 8)])
                ],
                weather: WeatherType.clear,
                timeOfDay: TimeOfDay.dawn,
                atmosphericEffect: VisualEffect.glow,
                audioId: "wasteland_ambience",
                estimatedDuration: 1800
            )
        ]
        
        return Chapter(
            id: 1,
            title: "The Wasteland",
            description: "Your journey begins in the ruins of a forgotten world.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.clear,
            timeOfDay: TimeOfDay.dawn,
            atmosphericEffect: VisualEffect.glow,
            audioId: "chapter1_theme",
            estimatedDuration: 1800
        )
    }
    
    private func createChapterTwo() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch2_intro",
                title: "The Ancient Temple",
                narrative: "You discover an ancient temple hidden within the wasteland. Its walls are covered in mysterious runes that seem to pulse with an otherworldly energy. The air is thick with anticipation.",
                choices: [
                    Choice(id: "enter_temple", text: "Enter the temple", consequences: [Consequence(stat: .magic, change: 15)]),
                    Choice(id: "study_runes", text: "Study the runes first", consequences: [Consequence(stat: .intelligence, change: 12)]),
                    Choice(id: "circle_temple", text: "Circle the temple to find another entrance", consequences: [Consequence(stat: .courage, change: 10)])
                ],
                weather: WeatherType.mystical,
                timeOfDay: TimeOfDay.dusk,
                atmosphericEffect: VisualEffect.pulse,
                audioId: "temple_ambience",
                estimatedDuration: 2400
            )
        ]
        
        return Chapter(
            id: 2,
            title: "The Ancient Temple",
            description: "An ancient temple holds secrets of the past.",
            scenes: scenes,
            choices: [],
            weather: .mystical,
            timeOfDay: .dusk,
            atmosphericEffect: .pulse,
            audioId: "chapter2_theme",
            estimatedDuration: 2400
        )
    }
    
    private func createChapterThree() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch3_intro",
                title: "The Crystal Caverns",
                narrative: "Deep within the temple, you find yourself in a vast cavern filled with glowing crystals. The air shimmers with magical energy, and you can feel the power of this place coursing through your veins.",
                choices: [
                    Choice(id: "touch_crystal", text: "Touch one of the crystals", consequences: [Consequence(stat: .magic, change: 20)]),
                    Choice(id: "meditate_here", text: "Meditate in this sacred place", consequences: [Consequence(stat: .wisdom, change: 15)]),
                    Choice(id: "explore_deeper", text: "Explore deeper into the caverns", consequences: [Consequence(stat: .courage, change: 18)])
                ],
                weather: WeatherType.mystical,
                timeOfDay: TimeOfDay.night,
                atmosphericEffect: VisualEffect.sparkle,
                audioId: "crystal_ambience",
                estimatedDuration: 2100
            )
        ]
        
        return Chapter(
            id: 3,
            title: "The Crystal Caverns",
            description: "A mystical cavern filled with ancient power.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.mystical,
            timeOfDay: TimeOfDay.night,
            atmosphericEffect: VisualEffect.sparkle,
            audioId: "chapter3_theme",
            estimatedDuration: 2100
        )
    }
    
    private func createChapterFour() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch4_intro",
                title: "The Forgotten Library",
                narrative: "You discover a vast library filled with ancient tomes and scrolls. Knowledge from countless ages past is preserved here, waiting to be discovered by those worthy enough to find it.",
                choices: [
                    Choice(id: "read_tomes", text: "Read the ancient tomes", consequences: [Consequence(stat: .intelligence, change: 25)]),
                    Choice(id: "search_secrets", text: "Search for hidden secrets", consequences: [Consequence(stat: .magic, change: 18)]),
                    Choice(id: "preserve_knowledge", text: "Preserve the knowledge for future generations", consequences: [Consequence(stat: .wisdom, change: 20)])
                ],
                weather: WeatherType.clear,
                timeOfDay: TimeOfDay.morning,
                atmosphericEffect: VisualEffect.glow,
                audioId: "library_ambience",
                estimatedDuration: 2700
            )
        ]
        
        return Chapter(
            id: 4,
            title: "The Forgotten Library",
            description: "Ancient knowledge awaits discovery.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.clear,
            timeOfDay: TimeOfDay.morning,
            atmosphericEffect: VisualEffect.glow,
            audioId: "chapter4_theme",
            estimatedDuration: 2700
        )
    }
    
    private func createChapterFive() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch5_intro",
                title: "The Battlefield",
                narrative: "You emerge onto a vast battlefield where the final battle of the ancient war was fought. The ground is scarred with the remnants of powerful magic, and the air crackles with residual energy.",
                choices: [
                    Choice(id: "investigate_battlefield", text: "Investigate the battlefield", consequences: [Consequence(stat: .intelligence, change: 15)]),
                    Choice(id: "absorb_energy", text: "Absorb the residual energy", consequences: [Consequence(stat: .magic, change: 25)]),
                    Choice(id: "honor_fallen", text: "Honor the fallen warriors", consequences: [Consequence(stat: .wisdom, change: 18)])
                ],
                weather: WeatherType.storm,
                timeOfDay: TimeOfDay.dusk,
                atmosphericEffect: VisualEffect.pulse,
                audioId: "battlefield_ambience",
                estimatedDuration: 2400
            )
        ]
        
        return Chapter(
            id: 5,
            title: "The Battlefield",
            description: "The scars of an ancient war remain.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.storm,
            timeOfDay: TimeOfDay.dusk,
            atmosphericEffect: VisualEffect.pulse,
            audioId: "chapter5_theme",
            estimatedDuration: 2400
        )
    }
    
    private func createChapterSix() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch6_intro",
                title: "The Floating Islands",
                narrative: "You discover a series of floating islands suspended in the sky by ancient magic. The islands are connected by bridges of light, and each one seems to hold a different aspect of the world's power.",
                choices: [
                    Choice(id: "explore_islands", text: "Explore the floating islands", consequences: [Consequence(stat: .courage, change: 20)]),
                    Choice(id: "study_magic", text: "Study the floating magic", consequences: [Consequence(stat: .magic, change: 22)]),
                    Choice(id: "map_islands", text: "Map the island network", consequences: [Consequence(stat: .intelligence, change: 18)])
                ],
                weather: WeatherType.clear,
                timeOfDay: TimeOfDay.noon,
                atmosphericEffect: VisualEffect.sparkle,
                audioId: "floating_islands_ambience",
                estimatedDuration: 3000
            )
        ]
        
        return Chapter(
            id: 6,
            title: "The Floating Islands",
            description: "Islands float in the sky, defying gravity.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.clear,
            timeOfDay: TimeOfDay.noon,
            atmosphericEffect: VisualEffect.sparkle,
            audioId: "chapter6_theme",
            estimatedDuration: 3000
        )
    }
    
    private func createChapterSeven() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch7_intro",
                title: "The Time Rift",
                narrative: "You encounter a rift in time itself, where past, present, and future converge. The air shimmers with temporal energy, and you can see glimpses of different timelines playing out before your eyes.",
                choices: [
                    Choice(id: "enter_rift", text: "Enter the time rift", consequences: [Consequence(stat: .magic, change: 30)]),
                    Choice(id: "observe_timelines", text: "Observe the different timelines", consequences: [Consequence(stat: .intelligence, change: 25)]),
                    Choice(id: "meditate_rift", text: "Meditate at the rift's edge", consequences: [Consequence(stat: .wisdom, change: 22)])
                ],
                weather: WeatherType.mystical,
                timeOfDay: TimeOfDay.midnight,
                atmosphericEffect: VisualEffect.wave,
                audioId: "time_rift_ambience",
                estimatedDuration: 2700
            )
        ]
        
        return Chapter(
            id: 7,
            title: "The Time Rift",
            description: "Time itself bends and warps here.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.mystical,
            timeOfDay: TimeOfDay.midnight,
            atmosphericEffect: VisualEffect.wave,
            audioId: "chapter7_theme",
            estimatedDuration: 2700
        )
    }
    
    private func createChapterEight() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch8_intro",
                title: "The Heart of Darkness",
                narrative: "You descend into the heart of darkness, where the source of the world's corruption lies. The air is thick with malevolent energy, and every step forward requires immense courage and determination.",
                choices: [
                    Choice(id: "face_darkness", text: "Face the darkness head-on", consequences: [Consequence(stat: .courage, change: 35)]),
                    Choice(id: "use_light", text: "Use your inner light to guide you", consequences: [Consequence(stat: .magic, change: 28)]),
                    Choice(id: "find_balance", text: "Seek balance between light and dark", consequences: [Consequence(stat: .wisdom, change: 30)])
                ],
                weather: WeatherType.storm,
                timeOfDay: TimeOfDay.night,
                atmosphericEffect: VisualEffect.shadow,
                audioId: "darkness_ambience",
                estimatedDuration: 3300
            )
        ]
        
        return Chapter(
            id: 8,
            title: "The Heart of Darkness",
            description: "The source of corruption awaits.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.storm,
            timeOfDay: TimeOfDay.night,
            atmosphericEffect: VisualEffect.shadow,
            audioId: "chapter8_theme",
            estimatedDuration: 3300
        )
    }
    
    private func createChapterNine() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch9_intro",
                title: "The Summit of Creation",
                narrative: "You reach the summit of creation, where the very fabric of reality is woven. Here, you can see the threads of existence and understand the true nature of the world and your place within it.",
                choices: [
                    Choice(id: "weave_reality", text: "Learn to weave reality itself", consequences: [Consequence(stat: .magic, change: 40)]),
                    Choice(id: "understand_existence", text: "Seek to understand existence", consequences: [Consequence(stat: .intelligence, change: 35)]),
                    Choice(id: "find_purpose", text: "Discover your true purpose", consequences: [Consequence(stat: .wisdom, change: 38)])
                ],
                weather: WeatherType.mystical,
                timeOfDay: TimeOfDay.dawn,
                atmosphericEffect: VisualEffect.light,
                audioId: "summit_ambience",
                estimatedDuration: 3600
            )
        ]
        
        return Chapter(
            id: 9,
            title: "The Summit of Creation",
            description: "The pinnacle of existence awaits.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.mystical,
            timeOfDay: TimeOfDay.dawn,
            atmosphericEffect: VisualEffect.light,
            audioId: "chapter9_theme",
            estimatedDuration: 3600
        )
    }
    
    private func createChapterTen() -> Chapter {
        let scenes = [
            StoryScene(
                id: "ch10_intro",
                title: "The Final Choice",
                narrative: "You stand at the threshold of the final choice. The fate of the world and your own destiny hang in the balance. Every decision you've made has led you to this moment, and now you must choose the path forward.",
                choices: [
                    Choice(id: "save_world", text: "Save the world and sacrifice yourself", consequences: [Consequence(stat: .wisdom, change: 50)]),
                    Choice(id: "rule_world", text: "Rule the world with absolute power", consequences: [Consequence(stat: .magic, change: 50)]),
                    Choice(id: "transcend", text: "Transcend existence itself", consequences: [Consequence(stat: .intelligence, change: 50)])
                ],
                weather: WeatherType.mystical,
                timeOfDay: TimeOfDay.dawn,
                atmosphericEffect: VisualEffect.light,
                audioId: "final_choice_ambience",
                estimatedDuration: 4200
            )
        ]
        
        return Chapter(
            id: 10,
            title: "The Final Choice",
            description: "The ultimate decision awaits.",
            scenes: scenes,
            choices: [],
            weather: WeatherType.mystical,
            timeOfDay: TimeOfDay.dawn,
            atmosphericEffect: VisualEffect.light,
            audioId: "chapter10_theme",
            estimatedDuration: 4200
        )
    }
} 
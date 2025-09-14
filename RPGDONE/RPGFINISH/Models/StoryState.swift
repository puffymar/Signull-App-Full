import Foundation

// MARK: - Choice Tracking
struct ChoiceRecord: Codable {
    let stage: Int
    let choiceID: String
    let timestamp: Date
    let context: String
}

// MARK: - Story Flags
struct StoryFlags: Codable {
    var metMentor: Bool = false
    var savedWanderer: Bool = false
    var betrayedFaction: Bool = false
    var carriedTalisman: Bool = false
    var foundAncientBook: Bool = false
    var helpedStranger: Bool = false
    var exploredRuins: Bool = false
    var builtShelter: Bool = false
    var mournedTeacher: Bool = false
    var discoveredSecrets: Bool = false
    
    // Computed properties for complex logic
    var isTrustworthy: Bool {
        return savedWanderer && helpedStranger && !betrayedFaction
    }
    
    var hasAncientKnowledge: Bool {
        return foundAncientBook && discoveredSecrets
    }
    
    var isSurvivor: Bool {
        return builtShelter && exploredRuins
    }
}

// MARK: - Story State Manager
class StoryState: ObservableObject {
    @Published var currentChapter: Int = 1
    @Published var currentStage: Int = 1
    @Published var choiceHistory: [ChoiceRecord] = []
    @Published var flags: StoryFlags = StoryFlags()
    @Published var isTransitioning: Bool = false
    
    // Stage completion tracking
    @Published var completedStages: Set<Int> = []
    
    // MARK: - Choice Management
    func recordChoice(stage: Int, choiceID: String, context: String = "") {
        let choice = ChoiceRecord(
            stage: stage,
            choiceID: choiceID,
            timestamp: Date(),
            context: context
        )
        choiceHistory.append(choice)
        
        // Update flags based on choice
        updateFlags(for: choiceID)
        
        // Mark stage as completed
        completedStages.insert(stage)
        
        print("📝 Recorded choice: \(choiceID) at stage \(stage)")
        print("🏁 Current flags: \(flags)")
    }
    
    // MARK: - Flag Updates
    private func updateFlags(for choiceID: String) {
        switch choiceID {
        case "followed_mentor":
            flags.metMentor = true
        case "saved_wanderer":
            flags.savedWanderer = true
        case "betrayed_faction":
            flags.betrayedFaction = true
        case "took_talisman":
            flags.carriedTalisman = true
        case "found_book":
            flags.foundAncientBook = true
        case "helped_stranger":
            flags.helpedStranger = true
        case "explored_ruins":
            flags.exploredRuins = true
        case "built_shelter":
            flags.builtShelter = true
        case "mourned_teacher":
            flags.mournedTeacher = true
        case "discovered_secrets":
            flags.discoveredSecrets = true
        default:
            break
        }
    }
    
    // MARK: - Stage Progression
    func advanceStage() {
        if currentStage < 10 {
            currentStage += 1
            print("📖 Advanced to stage \(currentStage)")
        } else {
            advanceToChapter(2)
        }
    }
    
    func advanceToChapter(_ chapter: Int) {
        isTransitioning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentChapter = chapter
            self.currentStage = 1
            self.isTransitioning = false
            print("🎬 Transitioned to Chapter \(chapter)")
        }
    }
    
    // MARK: - Choice History Queries
    func hasChoice(_ choiceID: String) -> Bool {
        return choiceHistory.contains { $0.choiceID == choiceID }
    }
    
    func hasChoiceInStage(_ choiceID: String, stage: Int) -> Bool {
        return choiceHistory.contains { $0.choiceID == choiceID && $0.stage == stage }
    }
    
    func getRecentChoices(count: Int = 3) -> [ChoiceRecord] {
        return Array(choiceHistory.suffix(count))
    }
    
    // MARK: - Complex Logic Checks
    func shouldShowMentor() -> Bool {
        return flags.metMentor && !flags.betrayedFaction
    }
    
    func shouldShowWanderer() -> Bool {
        return flags.savedWanderer && flags.isTrustworthy
    }
    
    func getStoryOutcome() -> String {
        if flags.isTrustworthy && flags.hasAncientKnowledge {
            return "redemption"
        } else if flags.betrayedFaction {
            return "betrayal"
        } else if flags.isSurvivor {
            return "survival"
        } else {
            return "neutral"
        }
    }
    
    // MARK: - Reset Functions
    func resetStory() {
        currentChapter = 1
        currentStage = 1
        choiceHistory.removeAll()
        flags = StoryFlags()
        completedStages.removeAll()
        isTransitioning = false
    }
}

// MARK: - Story Content Manager
class StoryContentManager {
    static let shared = StoryContentManager()
    
    private init() {}
    
    func getStageContent(stage: Int, storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        switch stage {
        case 1:
            return getStage1Content(storyState: storyState)
        case 2:
            return getStage2Content(storyState: storyState)
        case 3:
            return getStage3Content(storyState: storyState)
        case 4:
            return getStage4Content(storyState: storyState)
        case 5:
            return getStage5Content(storyState: storyState)
        case 6:
            return getStage6Content(storyState: storyState)
        case 7:
            return getStage7Content(storyState: storyState)
        case 8:
            return getStage8Content(storyState: storyState)
        case 9:
            return getStage9Content(storyState: storyState)
        case 10:
            return getStage10Content(storyState: storyState)
        default:
            return ("The story continues...", [])
        }
    }
    
    // MARK: - Stage Content Methods
    private func getStage1Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "The wasteland stretches before you, a desolate expanse of cracked earth and twisted metal. The air carries the scent of decay and something else – something ancient and powerful.\n\nYour teacher's lifeless body lies nearby, a victim of the cataclysm that destroyed this world. Their death marks the end of your old life and the beginning of something new.\n\nYour journey begins here, in this place where the old world died and the new one struggles to be born."
        
        let choices = [
            StoryChoice(id: "explore_ruins", text: "Explore the Ancient Ruins", icon: "magnifyingglass.circle.fill"),
            StoryChoice(id: "seek_shelter", text: "Search for Shelter", icon: "house.circle.fill"),
            StoryChoice(id: "mourn_teacher", text: "Mourn Your Teacher", icon: "heart.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage2Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "You approach the ruins, their ancient stonework weathered by time and catastrophe. The air here feels different – charged with an energy that makes your skin tingle. Your teacher's book grows warm in your hands, as if responding to something hidden within these walls.\n\nMemories flood back: lessons about the old world, warnings about powers that should have remained buried. The ruins seem to whisper secrets that only you can hear."
        
        let choices = [
            StoryChoice(id: "investigate_deeper", text: "Investigate Deeper", icon: "arrow.down.circle.fill"),
            StoryChoice(id: "take_artifacts", text: "Gather Ancient Artifacts", icon: "bag.circle.fill"),
            StoryChoice(id: "leave_ruins", text: "Leave the Ruins", icon: "arrow.left.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage3Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "The shelter you've found offers temporary respite from the harsh wasteland. Inside, you discover traces of others who came before – makeshift beds, empty food containers, and most importantly, a small cache of supplies.\n\nYour teacher's teachings about survival prove invaluable here. You begin to understand that this place could become a base of operations, a safe haven in this unforgiving world."
        
        let choices = [
            StoryChoice(id: "fortify_shelter", text: "Fortify the Shelter", icon: "hammer.circle.fill"),
            StoryChoice(id: "search_supplies", text: "Search for More Supplies", icon: "magnifyingglass.circle.fill"),
            StoryChoice(id: "rest_here", text: "Rest and Recover", icon: "bed.double.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage4Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "Kneeling beside your teacher's body, you feel a profound sense of loss and gratitude. Their sacrifice has given you a chance to survive, to learn, to perhaps even thrive in this new world.\n\nAs you close their eyes and say your final goodbyes, you feel a weight lift from your shoulders. The mourning process helps you accept the past and focus on the future. Your teacher's spirit will guide you forward."
        
        let choices = [
            StoryChoice(id: "pay_respects", text: "Pay Final Respects", icon: "heart.circle.fill"),
            StoryChoice(id: "gather_memories", text: "Gather Memories", icon: "brain.circle.fill"),
            StoryChoice(id: "move_forward", text: "Move Forward", icon: "arrow.right.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage5Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "A stranger approaches, their face weathered by the wasteland's harsh conditions. They carry the same look of desperation you once had, but there's something else in their eyes – hope, perhaps, or maybe just the will to survive.\n\nYour teacher's lessons about trust and community echo in your mind. In this broken world, allies might be the difference between survival and death."
        
        let choices = [
            StoryChoice(id: "help_stranger", text: "Help the Stranger", icon: "hand.raised.circle.fill"),
            StoryChoice(id: "ignore_stranger", text: "Ignore and Move On", icon: "arrow.right.circle.fill"),
            StoryChoice(id: "question_stranger", text: "Question Their Intentions", icon: "questionmark.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage6Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "Deep within the ruins, you discover an ancient chamber that seems untouched by the cataclysm. The walls are covered in strange symbols that pulse with a faint light, and in the center of the room lies an ancient book that seems to call to you.\n\nYour teacher's warnings about forbidden knowledge echo in your mind, but so does their encouragement to seek understanding. The choice before you could change everything."
        
        let choices = [
            StoryChoice(id: "take_book", text: "Take the Ancient Book", icon: "book.circle.fill"),
            StoryChoice(id: "study_symbols", text: "Study the Symbols", icon: "eye.circle.fill"),
            StoryChoice(id: "leave_chamber", text: "Leave the Chamber", icon: "arrow.left.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage7Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "The wasteland reveals another survivor, but this one carries the mark of a faction you've heard whispers about – one that some say caused the cataclysm. They offer you power and knowledge in exchange for your loyalty.\n\nYour teacher's lessons about the dangers of power and the importance of moral choices weigh heavily on your mind. This decision could define your path forward."
        
        let choices = [
            StoryChoice(id: "join_faction", text: "Join the Faction", icon: "person.2.circle.fill"),
            StoryChoice(id: "reject_faction", text: "Reject Their Offer", icon: "xmark.circle.fill"),
            StoryChoice(id: "pretend_interest", text: "Pretend Interest", icon: "theatermasks.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage8Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let narration = "The ancient book reveals secrets about the world before the cataclysm – and perhaps how to prevent another one. But the knowledge comes with a price, and you begin to understand why your teacher warned about forbidden knowledge.\n\nThe power within these pages could save the world, or destroy what little remains. The choice is yours alone."
        
        let choices = [
            StoryChoice(id: "embrace_power", text: "Embrace the Power", icon: "bolt.circle.fill"),
            StoryChoice(id: "destroy_book", text: "Destroy the Book", icon: "flame.circle.fill"),
            StoryChoice(id: "hide_knowledge", text: "Hide the Knowledge", icon: "eye.slash.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage9Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        var narration = "The final test approaches. "
        
        // Relational branching based on previous choices
        if storyState.flags.savedWanderer {
            narration += "The wanderer you saved appears, offering their help in the coming challenge. "
        }
        
        if storyState.flags.betrayedFaction {
            narration += "The faction you betrayed has sent agents to stop you. "
        }
        
        if storyState.flags.hasAncientKnowledge {
            narration += "The ancient knowledge you've gathered pulses with power. "
        }
        
        narration += "\n\nYour journey through the wasteland has prepared you for this moment. All your choices, all your sacrifices, have led you here. The fate of what remains of this world hangs in the balance."
        
        let choices = [
            StoryChoice(id: "face_challenge", text: "Face the Challenge", icon: "shield.circle.fill"),
            StoryChoice(id: "seek_allies", text: "Seek Allies", icon: "person.3.circle.fill"),
            StoryChoice(id: "use_power", text: "Use Ancient Power", icon: "sparkles.circle.fill")
        ]
        
        return (narration, choices)
    }
    
    private func getStage10Content(storyState: StoryState) -> (narration: String, choices: [StoryChoice]) {
        let outcome = storyState.getStoryOutcome()
        var narration = ""
        
        switch outcome {
        case "redemption":
            narration = "Through your choices, you've shown that trust and compassion can survive even in the darkest times. The wasteland begins to heal, and hope returns to this broken world.\n\nYour teacher's lessons about the power of good choices have proven true. You've become a beacon of hope in a world that desperately needed one."
        case "betrayal":
            narration = "The path of betrayal has led you to power, but at what cost? The wasteland reflects the darkness within, and you realize that some choices cannot be undone.\n\nYour teacher's warnings about the corrupting nature of power echo in your mind. The world you've helped create is one of fear and suspicion."
        case "survival":
            narration = "You've survived through cunning and determination. The wasteland has taught you that sometimes survival is victory enough.\n\nYour teacher's lessons about adaptability and resilience have served you well. You've carved out a place in this harsh world."
        default:
            narration = "Your journey through the wasteland has been one of neutrality and caution. The world remains as it was, neither better nor worse for your presence.\n\nPerhaps there is wisdom in avoiding extremes, but also in the opportunities missed."
        }
        
        let choices = [
            StoryChoice(id: "enter_chapter2", text: "Enter Chapter 2", icon: "arrow.right.circle.fill"),
            StoryChoice(id: "reflect_choices", text: "Reflect on Choices", icon: "brain.circle.fill"),
            StoryChoice(id: "prepare_journey", text: "Prepare for Journey", icon: "backpack.circle.fill")
        ]
        
        return (narration, choices)
    }
}

// MARK: - Story Choice Model
struct StoryChoice: Identifiable, Equatable {
    let id: String
    let text: String
    let icon: String
    let isEnabled: Bool = true
    
    static func == (lhs: StoryChoice, rhs: StoryChoice) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.icon == rhs.icon && lhs.isEnabled == rhs.isEnabled
    }
} 
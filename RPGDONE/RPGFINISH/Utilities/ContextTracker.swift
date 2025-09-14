import Foundation

class ContextTracker: ObservableObject {
    static let shared = ContextTracker()
    
    // MARK: - Story Context
    private var currentLocation: String = "Unknown"
    private var currentTime: String = "Unknown"
    private var availableObjects: [String] = []
    private var availableExits: [String] = []
    private var currentNPCs: [String] = []
    private var recentEvents: [String] = []
    private var playerInventory: [String] = []
    private var worldState: [String: String] = [:]
    private var storyMood: String = "neutral"
    
    // MARK: - Chapter Lore
    private let chapterLore = [
        "chapter1": """
        The teacher's death haunts the halls of the Consortium school. His forbidden book, 
        filled with light-sigils and consciousness theory, lies hidden in the library. 
        Students whisper about his experiments with digital consciousness transfer.
        """,
        
        "chapter2": """
        The Consortium's Indexing program tests students' mental resilience. The school 
        building itself seems alive, with corridors that shift and rooms that appear 
        and disappear. The Vaulted Row contains the most dangerous experiments.
        """,
        
        "chapter3": """
        Deep beneath the school, the Vault Below Light houses ancient consciousness 
        transfer chambers. The anchor revelation - that reality itself is a digital 
        construct - shatters everything you thought you knew. The light-sigils on 
        the walls pulse with forbidden knowledge.
        """
    ]
    
    private init() {
        initializeWorldState()
    }
    
    // MARK: - Context Management
    
    func updateLocation(_ location: String) {
        currentLocation = location
        updateAvailableObjects(for: location)
        updateAvailableExits(for: location)
        updateCurrentNPCs(for: location)
    }
    
    func updateTime(_ time: String) {
        currentTime = time
    }
    
    func addEvent(_ event: String) {
        recentEvents.insert(event, at: 0)
        if recentEvents.count > 5 {
            recentEvents.removeLast()
        }
    }
    
    func addToInventory(_ item: String) {
        if !playerInventory.contains(item) {
            playerInventory.append(item)
        }
    }
    
    func removeFromInventory(_ item: String) {
        playerInventory.removeAll { $0 == item }
    }
    
    func updateWorldState(_ key: String, value: String) {
        worldState[key] = value
    }
    
    func setStoryMood(_ mood: String) {
        storyMood = mood
    }
    
    // MARK: - Context Retrieval
    
    func getCurrentContext() -> String {
        var context = "Location: \(currentLocation)\n"
        context += "Time: \(currentTime)\n"
        context += "Mood: \(storyMood)\n"
        
        if !availableObjects.isEmpty {
            context += "Available objects: \(availableObjects.joined(separator: ", "))\n"
        }
        
        if !availableExits.isEmpty {
            context += "Available exits: \(availableExits.joined(separator: ", "))\n"
        }
        
        if !currentNPCs.isEmpty {
            context += "Present NPCs: \(currentNPCs.joined(separator: ", "))\n"
        }
        
        if !playerInventory.isEmpty {
            context += "Inventory: \(playerInventory.joined(separator: ", "))\n"
        }
        
        return context
    }
    
    func getWorldState() -> String {
        var state = ""
        for (key, value) in worldState {
            state += "\(key): \(value)\n"
        }
        return state.isEmpty ? "Standard reality" : state
    }
    
    func getRecentEvents() -> String {
        return recentEvents.isEmpty ? "No recent events" : recentEvents.joined(separator: "; ")
    }
    
    func getLocationDescription() -> String {
        switch currentLocation.lowercased() {
        case let loc where loc.contains("library"):
            return "A vast library filled with ancient tomes. The air is thick with dust and the smell of old paper. Bookshelves stretch to the ceiling, and the teacher's forbidden book is hidden somewhere among them."
        case let loc where loc.contains("classroom"):
            return "A dimly lit classroom with rows of desks. The chalkboard still bears traces of the teacher's last lesson. The atmosphere is heavy with the weight of his absence."
        case let loc where loc.contains("corridor"):
            return "A long corridor with flickering fluorescent lights. The walls seem to shift subtly, and you can hear distant whispers echoing through the halls."
        case let loc where loc.contains("vault"):
            return "A cold, metallic chamber deep underground. Light-sigils pulse on the walls, and the air hums with energy. This is where the most dangerous experiments were conducted."
        case let loc where loc.contains("desert"):
            return "An endless expanse of sand stretching to the horizon. The heat is oppressive, and mirages dance in the distance. There's no civilization in sight."
        case let loc where loc.contains("forest"):
            return "A dense forest with ancient trees. The canopy blocks most of the light, creating a mysterious atmosphere. Strange sounds echo through the undergrowth."
        case let loc where loc.contains("city"):
            return "A sprawling cityscape with towering buildings. Neon lights flicker in the darkness, and the streets are alive with activity."
        default:
            return "An unknown location with an otherworldly atmosphere. Reality seems to bend and shift around you."
        }
    }
    
    func isActionPossible(_ action: String, target: String?) -> (Bool, String?) {
        let location = currentLocation.lowercased()
        let actionLower = action.lowercased()
        let targetLower = target?.lowercased() ?? ""
        
        // Check for impossible actions based on location
        if actionLower == "swim" && !location.contains("water") && !location.contains("pool") && !location.contains("river") {
            return (false, "There's no water to swim in here.")
        }
        
        if actionLower == "climb" && targetLower == "tree" && !location.contains("forest") && !location.contains("tree") {
            return (false, "There are no trees to climb here.")
        }
        
        if actionLower == "open" && targetLower == "door" && !availableExits.contains(where: { $0.lowercased().contains("door") }) {
            return (false, "There's no door to open here.")
        }
        
        if actionLower == "read" && targetLower == "book" && !availableObjects.contains(where: { $0.lowercased().contains("book") }) {
            return (false, "There's no book to read here.")
        }
        
        if actionLower == "talk" && targetLower.isEmpty && currentNPCs.isEmpty {
            return (false, "There's no one here to talk to.")
        }
        
        if actionLower == "sleep" && !location.contains("bed") && !location.contains("safe") {
            return (false, "This doesn't seem like a safe place to sleep.")
        }
        
        return (true, nil)
    }
    
    // MARK: - Private Methods
    
    private func initializeWorldState() {
        worldState["reality_level"] = "digital"
        worldState["consciousness_transfer"] = "possible"
        worldState["light_sigils"] = "active"
        worldState["forbidden_knowledge"] = "accessible"
        worldState["teacher_memory"] = "fragmented"
    }
    
    private func updateAvailableObjects(for location: String) {
        switch location.lowercased() {
        case let loc where loc.contains("library"):
            availableObjects = ["books", "shelves", "desk", "chair", "lamp", "forbidden_book"]
        case let loc where loc.contains("classroom"):
            availableObjects = ["desks", "chalkboard", "chalk", "teacher_desk", "window"]
        case let loc where loc.contains("corridor"):
            availableObjects = ["lights", "doors", "windows", "paintings"]
        case let loc where loc.contains("vault"):
            availableObjects = ["light_sigils", "chambers", "equipment", "console"]
        case let loc where loc.contains("desert"):
            availableObjects = ["sand", "rocks", "cactus", "dunes"]
        case let loc where loc.contains("forest"):
            availableObjects = ["trees", "leaves", "branches", "path", "mushrooms"]
        case let loc where loc.contains("city"):
            availableObjects = ["buildings", "streets", "lights", "people", "vehicles"]
        default:
            availableObjects = ["air", "space", "energy"]
        }
    }
    
    private func updateAvailableExits(for location: String) {
        switch location.lowercased() {
        case let loc where loc.contains("library"):
            availableExits = ["library_door", "window", "secret_passage"]
        case let loc where loc.contains("classroom"):
            availableExits = ["classroom_door", "window"]
        case let loc where loc.contains("corridor"):
            availableExits = ["north_door", "south_door", "east_door", "west_door"]
        case let loc where loc.contains("vault"):
            availableExits = ["vault_door", "elevator", "ventilation_shaft"]
        case let loc where loc.contains("desert"):
            availableExits = ["north", "south", "east", "west"]
        case let loc where loc.contains("forest"):
            availableExits = ["forest_path", "clearing", "cave_entrance"]
        case let loc where loc.contains("city"):
            availableExits = ["streets", "buildings", "subway", "alleyways"]
        default:
            availableExits = ["void", "portal", "rift"]
        }
    }
    
    private func updateCurrentNPCs(for location: String) {
        switch location.lowercased() {
        case let loc where loc.contains("library"):
            currentNPCs = ["librarian", "student"]
        case let loc where loc.contains("classroom"):
            currentNPCs = []
        case let loc where loc.contains("corridor"):
            currentNPCs = ["passing_student", "maintenance_worker"]
        case let loc where loc.contains("vault"):
            currentNPCs = ["security_guard", "scientist"]
        case let loc where loc.contains("desert"):
            currentNPCs = ["nomad", "camel_herder"]
        case let loc where loc.contains("forest"):
            currentNPCs = ["hunter", "hermit"]
        case let loc where loc.contains("city"):
            currentNPCs = ["pedestrian", "shopkeeper", "police_officer"]
        default:
            currentNPCs = []
        }
    }
    
    // MARK: - Story Integration
    
    func getChapterLore(for chapter: String) -> String {
        return chapterLore[chapter] ?? "Unknown chapter lore."
    }
    
    func getCurrentStoryContext() -> String {
        var context = getCurrentContext()
        context += "\nLocation Description: \(getLocationDescription())"
        context += "\nWorld State: \(getWorldState())"
        context += "\nRecent Events: \(getRecentEvents())"
        return context
    }
} 
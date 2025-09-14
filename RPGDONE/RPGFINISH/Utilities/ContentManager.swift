import Foundation
import Combine

// MARK: - Content Manager
class ContentManager: ObservableObject {
    static let shared = ContentManager()
    
    // Content caches
    private var chapterContentCache: [Int: ChapterContent] = [:]
    private var choiceContentCache: [String: ChoiceContent] = [:]
    private var audioContentCache: [String: AudioContent] = [:]
    
    // Performance tracking
    private var contentLoadTimes: [String: TimeInterval] = [:]
    private var cacheHits = 0
    private var cacheMisses = 0
    
    // Background processing
    private let contentQueue = DispatchQueue(label: "com.rpgfinish.content", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupPreloading()
    }
    
    // MARK: - Content Loading
    
    func loadChapterContent(_ chapterNumber: Int) -> ChapterContent {
        // Check cache first
        if let cached = chapterContentCache[chapterNumber] {
            if type(of: cached.choices) != Array<String>.self {
                print("[ERROR] ChapterContent.choices is not an array for chapter \(chapterNumber). Clearing cache and returning empty choices.")
                chapterContentCache.removeAll()
                return ChapterContent(
                    id: cached.id,
                    title: cached.title,
                    text: cached.text,
                    choices: [],
                    weather: cached.weather,
                    timeOfDay: cached.timeOfDay,
                    audioId: cached.audioId
                )
            }
            cacheHits += 1
            return cached
        }
        cacheMisses += 1
        let startTime = Date()
        let content = createChapterContent(for: chapterNumber)
        if type(of: content.choices) != Array<String>.self {
            print("[ERROR] ChapterContent.choices is not an array for chapter \(chapterNumber) (creation). Returning empty choices.")
            chapterContentCache[chapterNumber] = ChapterContent(
                id: content.id,
                title: content.title,
                text: content.text,
                choices: [],
                weather: content.weather,
                timeOfDay: content.timeOfDay,
                audioId: content.audioId
            )
            return chapterContentCache[chapterNumber]!
        }
        chapterContentCache[chapterNumber] = content
        contentLoadTimes["chapter_\(chapterNumber)"] = Date().timeIntervalSince(startTime)
        return content
    }
    
    func loadChoiceContent(_ choiceId: String) -> ChoiceContent {
        if let cached = choiceContentCache[choiceId] {
            cacheHits += 1
            return cached
        }
        
        cacheMisses += 1
        let content = createChoiceContent(for: choiceId)
        choiceContentCache[choiceId] = content
        return content
    }
    
    func preloadAudioContent(_ audioIds: [String]) {
        contentQueue.async { [weak self] in
            for audioId in audioIds {
                if self?.audioContentCache[audioId] == nil {
                    let content = self?.createAudioContent(for: audioId)
                    DispatchQueue.main.async {
                        self?.audioContentCache[audioId] = content
                    }
                }
            }
        }
    }
    
    // MARK: - Content Creation
    
    private func createChapterContent(for chapterNumber: Int) -> ChapterContent {
        let content: ChapterContent
        switch chapterNumber {
        case 1:
            content = ChapterContent(
                id: "chapter_1",
                title: "The Wasteland",
                text: """
                The wasteland stretches before you, a desolate expanse of cracked earth and twisted metal that seems to breathe with its own malevolent life. The air carries the scent of decay and something else - something ancient and powerful that makes your skin crawl.
                
                Your teacher's lifeless body lies nearby, their robes still smoking from the cataclysm that destroyed this world. Their death marks the end of your old life and the beginning of something new. In their final moments, they pressed something into your hands - a book bound in leather that seems to whisper when you're not looking directly at it.
                
                The horizon is broken by jagged spires of blackened steel, remnants of a civilization that once reached for the stars. Now they reach for nothing but the empty sky. The ground beneath your feet pulses with a rhythm that doesn't match your heartbeat, and you realize this place is alive in ways you can't comprehend.
                
                Your journey begins here, in this place where the old world died and something new struggles to be born. The choices you make will shape not just your destiny, but the fate of this broken world. The book in your hands feels warm, and you swear you can hear it breathing.
                
                What path will you choose in this place where reality itself seems to be unraveling?
                """,
                choices: [
                    "explore_ruins",
                    "seek_shelter", 
                    "mourn_teacher",
                    "examine_book"
                ],
                weather: .clear,
                timeOfDay: .dawn,
                audioId: "chapter_1_ambient"
            )
        case 2:
            content = ChapterContent(
                id: "chapter_2",
                title: "The Indexing",
                text: """
                You arrive at Caelun Verge, the Consortium's outpost city that rises from the wasteland like a mirage of order in chaos. The Index Pillars loom before you - ancient vertical monoliths of obsidian and gold that pulse with inner light, ready to assign your class rank, elemental affinity, and magical potential.
                
                Elite candidates and Consortium officials watch from the shadows, their faces hidden behind masks of polished bone. You feel their eyes on you, assessing, judging, calculating. The air crackles with political tension and hidden agendas that could mean life or death for those who misstep.
                
                As you approach the Index Pillars, you sense the forbidden book in your satchel reacting to the Consortium's magical infrastructure. Something about this place makes it uneasy, and you can feel it shifting against your side like a restless animal. The pillars themselves seem to lean away from you slightly, as if repelled by what you carry.
                
                The indexing ceremony begins with a low hum that builds to a crescendo. Your future hangs in the balance, but you can't shake the feeling that this is about more than just classification. The book's whispers grow louder, and you realize it's trying to tell you something about what's really happening here.
                
                The Consortium's true purpose lies hidden beneath layers of ceremony and tradition. Will you play their game, or will you listen to the book's warnings?
                """,
                choices: [
                    "approach_pillars",
                    "observe_first", 
                    "check_book",
                    "resist_ceremony"
                ],
                weather: .clear,
                timeOfDay: .afternoon,
                audioId: "chapter_2_ambient"
            )
        case 3:
            content = ChapterContent(
                id: "chapter_3",
                title: "The Vault Below Light",
                text: """
                You're led through a sigil elevator that descends beneath the main tower, its walls inscribed with words in a language you suddenly start to read. You shouldn't be able to understand these symbols, but they flow through your mind like water, carrying meanings that make your head ache.
                
                The elevator dims as you descend deeper, and the book pulses once in your satchel, sending a wave of warmth through your chest. The deeper you go, the more you realize this isn't just a testing facility - it's a prison for something ancient and terrible.
                
                You arrive in an observation chamber with a one-way mirrored window that reflects nothing but darkness. A masked examiner stands behind the glass, their face hidden behind a mask that seems to shift and change when you're not looking directly at it. You're told to sit in the Threshold Seat - a glowing rune-inscribed chair at the center that hums with restrained power.
                
                "We're going to initiate a memory map and draw your latent affinities," the examiner says, their voice distorted by the mask. "Stay very still. And whatever you see — don't speak to it. Don't acknowledge it. Don't let it know you can see it."
                
                Of course, the book activates itself mid-test, and suddenly you're not just being tested - you're being hunted by something that lives in the spaces between thoughts.
                """,
                choices: [
                    "do_nothing",
                    "touch_book",
                    "whisper_to_book",
                    "resist_testing"
                ],
                weather: .clear,
                timeOfDay: .night,
                audioId: "chapter_3_ambient"
            )
        case 4:
            content = ChapterContent(
                id: "chapter_4",
                title: "The Final Test",
                text: """
                The Consortium's final evaluation chamber stretches before you, a vast space that seems to exist in multiple dimensions at once. This is where they determine whether you're worthy of their highest classification - or if you're something else entirely, something they've been hunting for centuries.
                
                The air hums with ancient magic that tastes like copper and ozone, and you can feel the weight of all your previous choices pressing down like a physical force. The forbidden book in your satchel seems to pulse in time with your heartbeat, and you realize it's not just reacting to the magic - it's harmonizing with it.
                
                A voice echoes through the chamber, coming from everywhere and nowhere: "Show us what you truly are. Demonstrate your worthiness. Or reveal your true nature. The choice is yours, but the consequences will be eternal."
                
                This is the moment that will define your path forward, but you can't shake the feeling that this isn't just a test - it's a trap. The book's whispers have grown into a chorus, and you're starting to understand what it's been trying to tell you all along.
                
                The Consortium doesn't want to classify you. They want to control you. And they're willing to destroy you to do it.
                """,
                choices: [
                    "demonstrate_worth",
                    "reveal_truth",
                    "resist_testing",
                    "embrace_book"
                ],
                weather: .clear,
                timeOfDay: .night,
                audioId: "chapter_4_ambient"
            )
        case 5:
            content = ChapterContent(
                id: "chapter_5",
                title: "The Forest of Whispers",
                text: """
                You find yourself in a dense forest where the trees whisper secrets in languages that died before humans learned to speak. The air is thick with ancient magic that makes your skin tingle and your thoughts race. Every step forward reveals new mysteries, and you realize this forest is alive in ways that defy comprehension.
                
                The trees themselves seem to watch you, their bark shifting to reveal faces that disappear when you look directly at them. Ancient markings carved into their trunks tell stories of civilizations long past, civilizations that reached heights of power that would make the Consortium look like children playing with toys.
                
                The forest is alive with hidden dangers and forgotten treasures, but the greatest danger might be the forest itself. It's hungry, and it's been waiting for someone like you for a very long time. The book in your satchel feels heavier here, as if it's being pulled toward something deep in the forest's heart.
                
                You must navigate this treacherous path, choosing between safety and discovery, between caution and boldness. But remember - in a place like this, sometimes the safest path is the most dangerous one.
                
                The forest has its own rules, and breaking them could mean becoming part of the forest forever.
                """,
                choices: [
                    "follow_path",
                    "explore_deep",
                    "seek_shelter",
                    "listen_to_whispers"
                ],
                weather: .foggy,
                timeOfDay: .dusk,
                audioId: "chapter_5_ambient"
            )
        case 6:
            content = ChapterContent(
                id: "chapter_6",
                title: "The City of Broken Dreams",
                text: """
                The city rises before you like a nightmare made manifest, its towers reaching toward a sky that seems to bleed. This was once a place of wonder and innovation, but now it's a monument to hubris and the price of reaching too high.
                
                The streets are lined with the remnants of a civilization that tried to become gods, and failed. Their machines still hum with power, but it's a power that's gone mad, twisting and corrupting everything it touches. The air crackles with electricity that doesn't follow the laws of physics.
                
                You can feel the city's pain, its anger, its hunger. It's alive, but it's dying, and it wants to take everything with it. The book in your satchel pulses with recognition, as if it knows this place, as if it was born here.
                
                The city's inhabitants are shadows of what they once were, their bodies twisted by the same power they tried to control. They wander the streets like ghosts, their minds trapped in endless loops of memory and regret.
                
                But there's something else here too - something that's been waiting for you. Something that knows what you carry, and what you're capable of becoming.
                """,
                choices: [
                    "explore_towers",
                    "help_shadows",
                    "seek_power",
                    "escape_city"
                ],
                weather: .stormy,
                timeOfDay: .night,
                audioId: "chapter_6_ambient"
            )
        case 7:
            content = ChapterContent(
                id: "chapter_7",
                title: "The Library of Lost Souls",
                text: """
                The library stretches before you like a cathedral to knowledge, its shelves reaching toward a ceiling that seems to exist in another dimension. This is where the Consortium keeps its secrets, where the knowledge of a thousand civilizations is stored in books that whisper and scream and sing.
                
                But this isn't just a library - it's a prison. The books aren't just books, they're souls, trapped in pages and bound in leather made from their own skin. They've been here for centuries, waiting for someone who can hear their voices, someone who can set them free.
                
                The air is thick with the weight of all that knowledge, all those souls, all those secrets. You can feel them pressing against your mind, trying to share their stories, their pain, their wisdom. The book in your satchel resonates with them, as if it's calling them home.
                
                The librarian is a figure of shadow and light, their form shifting between human and something else entirely. They've been here since the library was built, and they know every secret, every soul, every story.
                
                But they also know what you carry, and what it means. The library has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "read_forbidden",
                    "free_souls",
                    "seek_knowledge",
                    "escape_library"
                ],
                weather: .clear,
                timeOfDay: .night,
                audioId: "chapter_7_ambient"
            )
        case 8:
            content = ChapterContent(
                id: "chapter_8",
                title: "The Arena of Trials",
                text: """
                The arena rises before you like a coliseum built by giants, its walls carved from stone that seems to bleed when you touch it. This is where the Consortium tests its most promising candidates, where they separate the wheat from the chaff, the strong from the weak.
                
                But this isn't just a test of strength or skill - it's a test of will, of spirit, of the ability to survive in a world that wants you dead. The arena is alive, and it's hungry, and it's been waiting for someone like you for a very long time.
                
                The other candidates are scattered throughout the arena, each one carrying their own secrets, their own pain, their own reasons for being here. Some of them are your enemies, some are your allies, and some are something in between.
                
                The Consortium's judges watch from their thrones high above, their faces hidden behind masks that seem to shift and change. They're not just judging your performance - they're judging your worth, your potential, your destiny.
                
                But there's something else in the arena too, something that doesn't belong here, something that's been waiting for you. The book in your satchel pulses with recognition, and you realize this isn't just a test - it's a trap.
                """,
                choices: [
                    "fight_alone",
                    "form_alliance",
                    "seek_truth",
                    "escape_arena"
                ],
                weather: .clear,
                timeOfDay: .afternoon,
                audioId: "chapter_8_ambient"
            )
        case 9:
            content = ChapterContent(
                id: "chapter_9",
                title: "The Temple of Forgotten Gods",
                text: """
                The temple rises from the earth like a prayer made manifest, its walls covered in symbols that seem to move when you're not looking directly at them. This is where the old gods went to die, where they left behind their power and their wisdom for those brave enough to claim it.
                
                But the gods aren't really dead - they're sleeping, dreaming, waiting for someone who can wake them up. The temple is their dream, and you're walking through it, carrying something that makes them restless.
                
                The air is thick with the weight of divine power, power that's been sleeping for millennia, power that's starting to wake up. You can feel it pressing against your mind, trying to share its secrets, its memories, its desires.
                
                The temple's guardians are statues that come to life when you approach, their stone bodies cracking and shifting as they rise from their eternal slumber. They've been waiting for you, and they have questions that need answers.
                
                But there's something else in the temple too, something that doesn't belong here, something that's been waiting for you. The book in your satchel pulses with recognition, and you realize this isn't just a temple - it's a prison.
                """,
                choices: [
                    "wake_gods",
                    "seek_wisdom",
                    "escape_temple",
                    "embrace_power"
                ],
                weather: .clear,
                timeOfDay: .dawn,
                audioId: "chapter_9_ambient"
            )
        case 10:
            content = ChapterContent(
                id: "chapter_10",
                title: "The Labyrinth of Memory",
                text: """
                The labyrinth stretches before you like a maze built from memories, its walls shifting and changing as you walk through them. This is where the Consortium keeps its most dangerous secrets, where they store the memories of those who knew too much.
                
                But the labyrinth isn't just a storage facility - it's alive, and it's hungry, and it's been feeding on the memories of the Consortium's enemies for centuries. The walls are made from their pain, their fear, their despair.
                
                You can feel their memories pressing against your mind, trying to share their stories, their secrets, their warnings. Some of them are recent, some are ancient, and some are from times that haven't happened yet.
                
                The labyrinth's guardian is a figure of shadow and light, their form shifting between human and something else entirely. They've been here since the labyrinth was built, and they know every secret, every memory, every story.
                
                But they also know what you carry, and what it means. The labyrinth has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "explore_memories",
                    "seek_truth",
                    "escape_labyrinth",
                    "embrace_memories"
                ],
                weather: .foggy,
                timeOfDay: .night,
                audioId: "chapter_10_ambient"
            )
        case 11:
            content = ChapterContent(
                id: "chapter_11",
                title: "The Tower of Ascension",
                text: """
                The tower rises before you like a spear thrust into the heart of the sky, its walls covered in symbols that pulse with inner light. This is where the Consortium's most powerful members ascend to godhood, where they leave behind their humanity and become something else entirely.
                
                But the tower isn't just a place of ascension - it's a place of sacrifice, where the Consortium feeds on the souls of those who fail to ascend, using their power to fuel their own transformation. The air is thick with the screams of the damned, their voices echoing through the tower's endless corridors.
                
                You can feel their pain, their anger, their despair. They're trapped here, their souls bound to the tower, their power feeding the Consortium's endless hunger. Some of them are recent, some are ancient, and some are from times that haven't happened yet.
                
                The tower's guardian is a figure of pure light, their form shifting between human and something else entirely. They've been here since the tower was built, and they know every secret, every sacrifice, every story.
                
                But they also know what you carry, and what it means. The tower has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "ascend_tower",
                    "free_souls",
                    "escape_tower",
                    "embrace_ascension"
                ],
                weather: .clear,
                timeOfDay: .dawn,
                audioId: "chapter_11_ambient"
            )
        case 12:
            content = ChapterContent(
                id: "chapter_12",
                title: "The Void Between Worlds",
                text: """
                The void stretches before you like an ocean of nothingness, its depths filled with things that shouldn't exist, things that can't exist, things that exist only in the spaces between thoughts. This is where the Consortium's experiments went wrong, where they opened doors that should have remained closed.
                
                But the void isn't just empty space - it's alive, and it's hungry, and it's been feeding on the souls of those who ventured too deep. The air is thick with the whispers of things that shouldn't be, their voices echoing through the void's endless depths.
                
                You can feel their presence, their hunger, their desire. They want to consume you, to make you part of them, to use your power to break free from the void and into the world beyond.
                
                The void's guardian is a figure of pure darkness, their form shifting between human and something else entirely. They've been here since the void was created, and they know every secret, every horror, every story.
                
                But they also know what you carry, and what it means. The void has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "explore_void",
                    "seek_truth",
                    "escape_void",
                    "embrace_void"
                ],
                weather: .clear,
                timeOfDay: .night,
                audioId: "chapter_12_ambient"
            )
        case 13:
            content = ChapterContent(
                id: "chapter_13",
                title: "The Heart of the Consortium",
                text: """
                The heart of the Consortium beats before you like a living thing, its chambers filled with the power of a thousand souls, its walls covered in symbols that pulse with inner light. This is where the Consortium's true power lies, where they control the fate of the world.
                
                But the heart isn't just a source of power - it's a prison, where the Consortium keeps the souls of those who opposed them, using their power to fuel their endless hunger. The air is thick with the screams of the damned, their voices echoing through the heart's endless chambers.
                
                You can feel their pain, their anger, their despair. They're trapped here, their souls bound to the heart, their power feeding the Consortium's endless hunger. Some of them are recent, some are ancient, and some are from times that haven't happened yet.
                
                The heart's guardian is a figure of pure power, their form shifting between human and something else entirely. They've been here since the heart was created, and they know every secret, every sacrifice, every story.
                
                But they also know what you carry, and what it means. The heart has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "destroy_heart",
                    "free_souls",
                    "escape_heart",
                    "embrace_power"
                ],
                weather: .stormy,
                timeOfDay: .night,
                audioId: "chapter_13_ambient"
            )
        case 14:
            content = ChapterContent(
                id: "chapter_14",
                title: "The Threshold of Reality",
                text: """
                The threshold stretches before you like a door between worlds, its surface covered in symbols that seem to move when you're not looking directly at them. This is where reality itself begins to break down, where the laws of physics become suggestions rather than rules.
                
                But the threshold isn't just a door - it's a test, where the universe itself judges those who would change it, where it decides whether they're worthy of the power they seek. The air is thick with the weight of possibility, with the promise of what could be and the fear of what might be.
                
                You can feel the universe watching you, assessing you, judging you. It knows what you carry, and what you're capable of becoming. It knows that you could change everything, or destroy everything, or become everything.
                
                The threshold's guardian is a figure of pure possibility, their form shifting between human and something else entirely. They've been here since the beginning of time, and they know every secret, every possibility, every story.
                
                But they also know what you carry, and what it means. The threshold has been waiting for you, and now that you're here, nothing will ever be the same.
                """,
                choices: [
                    "cross_threshold",
                    "seek_truth",
                    "escape_threshold",
                    "embrace_possibility"
                ],
                weather: .clear,
                timeOfDay: .dawn,
                audioId: "chapter_14_ambient"
            )
        case 15:
            content = ChapterContent(
                id: "chapter_15",
                title: "The End of All Things",
                text: """
                The end stretches before you like a horizon that never ends, its depths filled with the echoes of all that was, all that is, and all that will be. This is where everything converges, where all paths lead, where all stories end and begin again.
                
                But the end isn't just an ending - it's a beginning, where the old world dies and the new world is born, where the cycle of creation and destruction begins again. The air is thick with the weight of eternity, with the promise of what could be and the fear of what might be.
                
                You can feel the universe watching you, waiting for you, needing you. It knows what you carry, and what you're capable of becoming. It knows that you could change everything, or destroy everything, or become everything.
                
                The end's guardian is a figure of pure eternity, their form shifting between human and something else entirely. They've been here since the beginning of time, and they know every secret, every possibility, every story.
                
                But they also know what you carry, and what it means. The end has been waiting for you, and now that you're here, nothing will ever be the same.
                
                This is where your story ends, and where it begins again.
                """,
                choices: [
                    "embrace_end",
                    "seek_truth",
                    "escape_end",
                    "become_everything"
                ],
                weather: .clear,
                timeOfDay: .dawn,
                audioId: "chapter_15_ambient"
            )
        default:
            content = ChapterContent(
                id: "chapter_\(chapterNumber)",
                title: "Unknown Chapter",
                text: "This chapter has not been written yet.",
                choices: ["continue"],
                weather: .clear,
                timeOfDay: .morning,
                audioId: "continue_sound"
            )
        }
        return content
    }
    
    private func createChoiceContent(for choiceId: String) -> ChoiceContent {
        switch choiceId {
        // Chapter 1: The Wasteland
        case "explore_ruins":
            return ChoiceContent(
                id: choiceId,
                text: "Explore the ruins ahead",
                consequences: [Consequence(stat: .magic, change: 10)],
                audioId: "explore_sound"
            )
        case "seek_shelter":
            return ChoiceContent(
                id: choiceId,
                text: "Seek shelter in the nearby cave",
                consequences: [Consequence(stat: .courage, change: 15)],
                audioId: "cave_sound"
            )
        case "mourn_teacher":
            return ChoiceContent(
                id: choiceId,
                text: "Mourn your fallen teacher",
                consequences: [Consequence(stat: .compassion, change: 15)],
                audioId: "mourning_sound"
            )
        case "examine_book":
            return ChoiceContent(
                id: choiceId,
                text: "Examine the book in your satchel",
                consequences: [Consequence(stat: .intelligence, change: 10)],
                audioId: "examine_sound"
            )
        
        // Chapter 2: The Indexing
        case "approach_pillars":
            return ChoiceContent(
                id: choiceId,
                text: "Approach the Index Pillars directly",
                consequences: [Consequence(stat: .courage, change: 10)],
                audioId: "approach_sound"
            )
        case "observe_first":
            return ChoiceContent(
                id: choiceId,
                text: "Observe the ceremony first",
                consequences: [Consequence(stat: .intelligence, change: 15)],
                audioId: "observe_sound"
            )
        case "check_book":
            return ChoiceContent(
                id: choiceId,
                text: "Check the forbidden book's reaction",
                consequences: [Consequence(stat: .magic, change: 20)],
                audioId: "book_sound"
            )
        case "resist_ceremony":
            return ChoiceContent(
                id: choiceId,
                text: "Resist the ceremony and the Consortium's control",
                consequences: [Consequence(stat: .resolve, change: 20)],
                audioId: "resist_sound"
            )
        
        // Chapter 3: The Vault Below Light
        case "do_nothing":
            return ChoiceContent(
                id: choiceId,
                text: "Do nothing - stay completely still",
                consequences: [Consequence(stat: .resolve, change: 15)],
                audioId: "still_sound"
            )
        case "touch_book":
            return ChoiceContent(
                id: choiceId,
                text: "Touch the book in your satchel",
                consequences: [Consequence(stat: .magic, change: 25)],
                audioId: "touch_sound"
            )
        case "whisper_to_book":
            return ChoiceContent(
                id: choiceId,
                text: "Whisper to the book",
                consequences: [Consequence(stat: .intelligence, change: 20)],
                audioId: "whisper_sound"
            )
        case "resist_testing":
            return ChoiceContent(
                id: choiceId,
                text: "Resist the Consortium's testing entirely",
                consequences: [Consequence(stat: .corruption, change: 25)],
                audioId: "resist_sound"
            )
        
        // Chapter 4: The Final Test
        case "demonstrate_worth":
            return ChoiceContent(
                id: choiceId,
                text: "Demonstrate your worthiness to the Consortium",
                consequences: [Consequence(stat: .resolve, change: 20)],
                audioId: "demonstrate_sound"
            )
        case "reveal_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Reveal your true nature as an anchor",
                consequences: [Consequence(stat: .magic, change: 30)],
                audioId: "reveal_sound"
            )
        case "embrace_book":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the book's power and become one with it",
                consequences: [Consequence(stat: .corruption, change: 30)],
                audioId: "embrace_sound"
            )
        
        // Chapter 5: The Forest of Whispers
        case "follow_path":
            return ChoiceContent(
                id: choiceId,
                text: "Follow the winding path through the forest",
                consequences: [Consequence(stat: .courage, change: 15)],
                audioId: "path_sound"
            )
        case "explore_deep":
            return ChoiceContent(
                id: choiceId,
                text: "Venture deep into the forest's heart",
                consequences: [Consequence(stat: .magic, change: 25)],
                audioId: "explore_sound"
            )
        case "listen_to_whispers":
            return ChoiceContent(
                id: choiceId,
                text: "Listen to the forest's ancient whispers",
                consequences: [Consequence(stat: .intelligence, change: 20)],
                audioId: "whisper_sound"
            )
        
        // Chapter 6: The City of Broken Dreams
        case "explore_towers":
            return ChoiceContent(
                id: choiceId,
                text: "Explore the twisted towers of the city",
                consequences: [Consequence(stat: .courage, change: 20)],
                audioId: "tower_sound"
            )
        case "help_shadows":
            return ChoiceContent(
                id: choiceId,
                text: "Try to help the city's shadow inhabitants",
                consequences: [Consequence(stat: .compassion, change: 25)],
                audioId: "help_sound"
            )
        case "seek_power":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the city's corrupted power for yourself",
                consequences: [Consequence(stat: .corruption, change: 30)],
                audioId: "power_sound"
            )
        case "escape_city":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the city's grasp",
                consequences: [Consequence(stat: .resolve, change: 20)],
                audioId: "escape_sound"
            )
        
        // Chapter 7: The Library of Lost Souls
        case "read_forbidden":
            return ChoiceContent(
                id: choiceId,
                text: "Read the forbidden knowledge in the library",
                consequences: [Consequence(stat: .intelligence, change: 30)],
                audioId: "read_sound"
            )
        case "free_souls":
            return ChoiceContent(
                id: choiceId,
                text: "Attempt to free the trapped souls",
                consequences: [Consequence(stat: .compassion, change: 30)],
                audioId: "free_sound"
            )
        case "seek_knowledge":
            return ChoiceContent(
                id: choiceId,
                text: "Seek specific knowledge about your destiny",
                consequences: [Consequence(stat: .intelligence, change: 25)],
                audioId: "knowledge_sound"
            )
        case "escape_library":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the library's grasp",
                consequences: [Consequence(stat: .resolve, change: 20)],
                audioId: "escape_sound"
            )
        
        // Chapter 8: The Arena of Trials
        case "fight_alone":
            return ChoiceContent(
                id: choiceId,
                text: "Face the arena's challenges alone",
                consequences: [Consequence(stat: .courage, change: 25)],
                audioId: "fight_sound"
            )
        case "form_alliance":
            return ChoiceContent(
                id: choiceId,
                text: "Form an alliance with other candidates",
                consequences: [Consequence(stat: .compassion, change: 20)],
                audioId: "alliance_sound"
            )
        case "seek_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the truth behind the arena's purpose",
                consequences: [Consequence(stat: .intelligence, change: 25)],
                audioId: "truth_sound"
            )
        case "escape_arena":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the arena entirely",
                consequences: [Consequence(stat: .resolve, change: 25)],
                audioId: "escape_sound"
            )
        
        // Chapter 9: The Temple of Forgotten Gods
        case "wake_gods":
            return ChoiceContent(
                id: choiceId,
                text: "Attempt to wake the sleeping gods",
                consequences: [Consequence(stat: .magic, change: 35)],
                audioId: "wake_sound"
            )
        case "seek_wisdom":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the wisdom of the forgotten gods",
                consequences: [Consequence(stat: .intelligence, change: 30)],
                audioId: "wisdom_sound"
            )
        case "escape_temple":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the temple's grasp",
                consequences: [Consequence(stat: .resolve, change: 20)],
                audioId: "escape_sound"
            )
        case "embrace_power":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the divine power for yourself",
                consequences: [Consequence(stat: .corruption, change: 35)],
                audioId: "power_sound"
            )
        
        // Chapter 10: The Labyrinth of Memory
        case "explore_memories":
            return ChoiceContent(
                id: choiceId,
                text: "Explore the memories stored in the labyrinth",
                consequences: [Consequence(stat: .intelligence, change: 30)],
                audioId: "memory_sound"
            )
        case "seek_memory_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the truth hidden in the memories",
                consequences: [Consequence(stat: .intelligence, change: 25)],
                audioId: "truth_sound"
            )
        case "escape_labyrinth":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the labyrinth's grasp",
                consequences: [Consequence(stat: .resolve, change: 25)],
                audioId: "escape_sound"
            )
        case "embrace_memories":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the memories and become one with them",
                consequences: [Consequence(stat: .corruption, change: 30)],
                audioId: "embrace_sound"
            )
        
        // Chapter 11: The Tower of Ascension
        case "ascend_tower":
            return ChoiceContent(
                id: choiceId,
                text: "Attempt to ascend to godhood yourself",
                consequences: [Consequence(stat: .magic, change: 40)],
                audioId: "ascend_sound"
            )
        case "escape_tower":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the tower's grasp",
                consequences: [Consequence(stat: .resolve, change: 25)],
                audioId: "escape_sound"
            )
        case "embrace_ascension":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the path of ascension",
                consequences: [Consequence(stat: .corruption, change: 40)],
                audioId: "ascend_sound"
            )
        
        // Chapter 12: The Void Between Worlds
        case "explore_void":
            return ChoiceContent(
                id: choiceId,
                text: "Explore the depths of the void",
                consequences: [Consequence(stat: .courage, change: 30)],
                audioId: "void_sound"
            )
        case "seek_void_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the truth about the void's nature",
                consequences: [Consequence(stat: .intelligence, change: 30)],
                audioId: "truth_sound"
            )
        case "escape_void":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the void's grasp",
                consequences: [Consequence(stat: .resolve, change: 30)],
                audioId: "escape_sound"
            )
        case "embrace_void":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the void and become one with it",
                consequences: [Consequence(stat: .corruption, change: 45)],
                audioId: "void_sound"
            )
        
        // Chapter 13: The Heart of the Consortium
        case "destroy_heart":
            return ChoiceContent(
                id: choiceId,
                text: "Attempt to destroy the Consortium's heart",
                consequences: [Consequence(stat: .courage, change: 40)],
                audioId: "destroy_sound"
            )
        case "escape_heart":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the heart's grasp",
                consequences: [Consequence(stat: .resolve, change: 30)],
                audioId: "escape_sound"
            )
        case "embrace_power":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the heart's power for yourself",
                consequences: [Consequence(stat: .corruption, change: 50)],
                audioId: "power_sound"
            )
        
        // Chapter 14: The Threshold of Reality
        case "cross_threshold":
            return ChoiceContent(
                id: choiceId,
                text: "Cross the threshold and change reality itself",
                consequences: [Consequence(stat: .magic, change: 50)],
                audioId: "threshold_sound"
            )
        case "seek_reality_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the truth about reality's nature",
                consequences: [Consequence(stat: .intelligence, change: 40)],
                audioId: "truth_sound"
            )
        case "escape_threshold":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the threshold's grasp",
                consequences: [Consequence(stat: .resolve, change: 35)],
                audioId: "escape_sound"
            )
        case "embrace_possibility":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the infinite possibilities",
                consequences: [Consequence(stat: .corruption, change: 55)],
                audioId: "possibility_sound"
            )
        
        // Chapter 15: The End of All Things
        case "embrace_end":
            return ChoiceContent(
                id: choiceId,
                text: "Embrace the end and become part of eternity",
                consequences: [Consequence(stat: .magic, change: 60)],
                audioId: "eternity_sound"
            )
        case "seek_final_truth":
            return ChoiceContent(
                id: choiceId,
                text: "Seek the final truth about existence",
                consequences: [Consequence(stat: .intelligence, change: 50)],
                audioId: "truth_sound"
            )
        case "escape_end":
            return ChoiceContent(
                id: choiceId,
                text: "Try to escape the end's grasp",
                consequences: [Consequence(stat: .resolve, change: 40)],
                audioId: "escape_sound"
            )
        case "become_everything":
            return ChoiceContent(
                id: choiceId,
                text: "Become everything and nothing at once",
                consequences: [Consequence(stat: .corruption, change: 100)],
                audioId: "everything_sound"
            )
        
        // Legacy Chapter 4 choices (keeping for compatibility)
        case "pacifist_approach":
            return ChoiceContent(
                id: choiceId,
                text: "Try to resolve the conflict peacefully",
                consequences: [Consequence(stat: .compassion, change: 20)],
                audioId: "pacifist_sound"
            )
        case "neutral_approach":
            return ChoiceContent(
                id: choiceId,
                text: "Take a neutral stance",
                consequences: [Consequence(stat: .intelligence, change: 15)],
                audioId: "neutral_sound"
            )
        case "genocide_approach":
            return ChoiceContent(
                id: choiceId,
                text: "Eliminate all threats aggressively",
                consequences: [Consequence(stat: .corruption, change: 30)],
                audioId: "aggressive_sound"
            )
        
        // Legacy choices (keeping for compatibility)
        case "trust_kai":
            return ChoiceContent(
                id: choiceId,
                text: "Trust Kai's offer of help",
                consequences: [Consequence(stat: .kaiLoyalty, change: 20)],
                audioId: "trust_sound"
            )
        case "distrust_kai":
            return ChoiceContent(
                id: choiceId,
                text: "Keep your distance from Kai",
                consequences: [Consequence(stat: .kaiLoyalty, change: -10)],
                audioId: "distrust_sound"
            )
        case "observe_carefully":
            return ChoiceContent(
                id: choiceId,
                text: "Observe Kai carefully before deciding",
                consequences: [Consequence(stat: .intelligence, change: 10)],
                audioId: "observe_sound"
            )
        case "forgive_kai":
            return ChoiceContent(
                id: choiceId,
                text: "Try to understand and forgive Kai",
                consequences: [Consequence(stat: .compassion, change: 15)],
                audioId: "forgive_sound"
            )
        case "rage_against_kai":
            return ChoiceContent(
                id: choiceId,
                text: "Give in to anger and vengeance",
                consequences: [Consequence(stat: .corruption, change: 25)],
                audioId: "rage_sound"
            )
        case "cold_revenge":
            return ChoiceContent(
                id: choiceId,
                text: "Plan cold, calculated revenge",
                consequences: [Consequence(stat: .corruption, change: 15)],
                audioId: "revenge_sound"
            )
        default:
            return ChoiceContent(
                id: choiceId,
                text: "Continue",
                consequences: [],
                audioId: "default_sound"
            )
        }
    }
    
    private func createAudioContent(for audioId: String) -> AudioContent {
        return AudioContent(
            id: audioId,
            fileName: audioId,
            volume: 0.7,
            loop: true
        )
    }
    
    // MARK: - Preloading
    
    private func setupPreloading() {
        // Preload first few chapters
        contentQueue.async { [weak self] in
            for chapter in 1...3 {
                _ = self?.loadChapterContent(chapter)
            }
            
            // Preload common audio
            let commonAudioIds = [
                "chapter_1_ambient",
                "chapter_2_ambient", 
                "chapter_3_ambient",
                "explore_sound",
                "cave_sound",
                "lights_sound"
            ]
            self?.preloadAudioContent(commonAudioIds)
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        chapterContentCache.removeAll()
        choiceContentCache.removeAll()
        audioContentCache.removeAll()
        contentLoadTimes.removeAll()
        cacheHits = 0
        cacheMisses = 0
    }
    
    func clearCaches() {
        clearCache()
    }
    
    func getCacheStats() -> CacheStats {
        return CacheStats(
            chapterCacheSize: chapterContentCache.count,
            choiceCacheSize: choiceContentCache.count,
            audioCacheSize: audioContentCache.count,
            cacheHits: cacheHits,
            cacheMisses: cacheMisses,
            averageLoadTime: contentLoadTimes.values.reduce(0, +) / Double(max(contentLoadTimes.count, 1))
        )
    }
    
    func clearChapterCache() {
        print("[DEBUG] ContentManager: Clearing chapterContentCache")
        chapterContentCache.removeAll()
    }
    
    // MARK: - Memory Management
    
    func optimizeMemory() {
        // Keep only essential content in memory
        let essentialChapters = Set([1, 2]) // Current and next chapter
        let nonEssentialChapters = chapterContentCache.keys.filter { !essentialChapters.contains($0) }
        
        for chapter in nonEssentialChapters {
            chapterContentCache.removeValue(forKey: chapter)
        }
        
        // Clear old audio content
        let essentialAudio = Set(["chapter_1_ambient", "chapter_2_ambient"])
        let nonEssentialAudio = audioContentCache.keys.filter { !essentialAudio.contains($0) }
        
        for audioId in nonEssentialAudio {
            audioContentCache.removeValue(forKey: audioId)
        }
    }
}

// MARK: - Advanced Content Manager
class AdvancedContentManager: ObservableObject {
    static let shared = AdvancedContentManager()
    
    @Published var branchingPaths: [BranchingPath] = []
    @Published var allies: [Ally] = []
    @Published var betrayalEvents: [BetrayalEvent] = []
    @Published var routeScenes: [RouteScene] = []
    @Published var secrets: [Secret] = []
    @Published var advancedEndings: [AdvancedEnding] = []
    @Published var advancedCombatEncounters: [AdvancedCombatEncounter] = []
    
    private init() {
        loadAllContent()
    }
    
    private func loadAllContent() {
        createBranchingPaths()
        createAllies()
        createBetrayalEvents()
        createRouteScenes()
        createSecrets()
        createAdvancedEndings()
        createAdvancedCombat()
    }
    
    // MARK: - Branching Paths
    private func createBranchingPaths() {
        branchingPaths = [
            // Corruption Path
            BranchingPath(
                id: "corruption_embrace",
                name: "Embrace the Darkness",
                description: "Give in to the corruption and embrace your dark power",
                requirements: [
                    PathRequirement(type: .stat, value: "corruption", threshold: 30, operatorType: .greaterThan, isOptional: false)
                ],
                consequences: [
                    PathConsequence(type: .stat, target: "corruption", value: 20, isPermanent: true, affectsRoute: true),
                    PathConsequence(type: .route, target: "corruption", value: 25, isPermanent: true, affectsRoute: true)
                ],
                affectsEnding: true,
                unlockCondition: .stat,
                unlockMethod: .exploration,
                isSecret: false
            ),
            
            BranchingPath(
                id: "redemption_path",
                name: "Path of Redemption",
                description: "Seek to overcome the corruption and find inner peace",
                requirements: [
                    PathRequirement(type: .stat, value: "compassion", threshold: 40, operatorType: .greaterThan, isOptional: false)
                ],
                consequences: [
                    PathConsequence(type: .stat, target: "compassion", value: 15, isPermanent: true, affectsRoute: true),
                    PathConsequence(type: .route, target: "redemption", value: 20, isPermanent: true, affectsRoute: true)
                ],
                affectsEnding: true,
                unlockCondition: .stat,
                unlockMethod: .exploration,
                isSecret: false
            )
        ]
    }
    
    // MARK: - Allies
    private func createAllies() {
        allies = [
            // Kai - The Mysterious Traveler
            Ally(
                id: "kai",
                name: "Kai",
                personality: .mysterious,
                abilities: [
                    AllyAbility(
                        name: "Shadow Step",
                        description: "Teleport through shadows to avoid detection",
                        effect: AllyAbilityEffect(type: .buff, target: .ally, magnitude: 15, duration: 3, condition: "stealth"),
                        cooldown: 5,
                        loyaltyRequirement: 30
                    ),
                    AllyAbility(
                        name: "Ancient Knowledge",
                        description: "Share forbidden knowledge about the world",
                        effect: AllyAbilityEffect(type: .buff, target: .self, magnitude: 10, duration: 2, condition: "intelligence"),
                        cooldown: 3,
                        loyaltyRequirement: 50
                    )
                ],
                loyalty: 60,
                maxLoyalty: 100,
                betrayalRisk: 40,
                romancePotential: 70,
                backstory: "A mysterious traveler who claims to know the ancient secrets of this world. Their true motives remain unclear, but they offer valuable knowledge and companionship.",
                secrets: ["true_identity", "ancient_one_connection", "betrayal_plan"],
                routeAffinity: [.corruption: 20, .balance: 30, .transcendence: 40],
                combatStyle: .assassin,
                dialogueOptions: [
                    "trust": ["I trust you completely", "I want to know more about you", "Let's work together"],
                    "distrust": ["I don't trust you", "What are you hiding?", "Stay away from me"],
                    "romance": ["I feel something special between us", "You're beautiful", "I want to be with you"]
                ]
            ),
            
            // Naya - The Healer
            Ally(
                id: "naya",
                name: "Naya",
                personality: .peaceful,
                abilities: [
                    AllyAbility(
                        name: "Healing Touch",
                        description: "Restore health and remove negative effects",
                        effect: AllyAbilityEffect(type: .heal, target: .ally, magnitude: 25, duration: 1, condition: nil),
                        cooldown: 4,
                        loyaltyRequirement: 20
                    ),
                    AllyAbility(
                        name: "Purify Corruption",
                        description: "Reduce corruption and restore sanity",
                        effect: AllyAbilityEffect(type: .debuff, target: .enemy, magnitude: 10, duration: 2, condition: "corruption"),
                        cooldown: 6,
                        loyaltyRequirement: 60
                    )
                ],
                loyalty: 80,
                maxLoyalty: 100,
                betrayalRisk: 10,
                romancePotential: 60,
                backstory: "A gentle healer who believes in the power of compassion and forgiveness. She seeks to heal the wounds of the world and bring peace to all.",
                secrets: ["healing_power_source", "past_trauma", "hidden_strength"],
                routeAffinity: [.redemption: 50, .sacrifice: 40, .balance: 30],
                combatStyle: .healer,
                dialogueOptions: [
                    "healing": ["Teach me to heal", "How do you do it?", "Can you help me?"],
                    "peace": ["Let's find a peaceful solution", "Violence isn't the answer", "We can do better"],
                    "romance": ["You have a beautiful soul", "I admire your compassion", "You make me want to be better"]
                ]
            ),
            
            // Asher - The Warrior
            Ally(
                id: "asher",
                name: "Asher",
                personality: .aggressive,
                abilities: [
                    AllyAbility(
                        name: "Berserker Rage",
                        description: "Increase damage and attack speed",
                        effect: AllyAbilityEffect(type: .buff, target: .self, magnitude: 20, duration: 3, condition: "combat"),
                        cooldown: 5,
                        loyaltyRequirement: 40
                    ),
                    AllyAbility(
                        name: "Shield Wall",
                        description: "Protect allies from damage",
                        effect: AllyAbilityEffect(type: .buff, target: .ally, magnitude: 15, duration: 2, condition: "defense"),
                        cooldown: 4,
                        loyaltyRequirement: 50
                    )
                ],
                loyalty: 70,
                maxLoyalty: 100,
                betrayalRisk: 20,
                romancePotential: 50,
                backstory: "A fierce warrior who believes in strength and honor. He fights for what he believes is right and protects those he cares about.",
                secrets: ["warrior_code", "past_battles", "honor_quest"],
                routeAffinity: [.power: 40, .balance: 30, .sacrifice: 20],
                combatStyle: .guardian,
                dialogueOptions: [
                    "strength": ["Show me how to fight", "What makes a warrior?", "Teach me your ways"],
                    "honor": ["What is honor to you?", "How do you choose your battles?", "What do you fight for?"],
                    "romance": ["You're incredibly strong", "I admire your courage", "You make me feel safe"]
                ]
            )
        ]
    }
    
    // MARK: - Betrayal Events
    private func createBetrayalEvents() {
        betrayalEvents = [
            // Kai's Betrayal
            BetrayalEvent(
                id: "kai_betrayal",
                betrayer: "kai",
                trigger: .lowLoyalty,
                consequences: [
                    BetrayalConsequence(type: .statLoss, target: "health", value: 30, isPermanent: false, affectsEnding: true),
                    BetrayalConsequence(type: .relationshipBreak, target: "kai", value: -100, isPermanent: true, affectsEnding: true),
                    BetrayalConsequence(type: .routeLock, target: "redemption", value: 1, isPermanent: true, affectsEnding: true)
                ],
                isPreventable: true,
                preventionRequirements: [
                    PathRequirement(type: .stat, value: "empathy", threshold: 70, operatorType: .greaterThan, isOptional: false),
                    PathRequirement(type: .choice, value: "forgive_kai", threshold: 1, operatorType: .equal, isOptional: false)
                ],
                warningSigns: [
                    "Kai seems distant and preoccupied",
                    "You notice Kai speaking in hushed tones",
                    "Kai's loyalty has been decreasing",
                    "Ancient symbols appear in Kai's belongings"
                ],
                aftermath: "Kai's betrayal has left deep scars. The trust you placed in them has been shattered, and you must now face the consequences of their treachery."
            ),
            
            // Naya's Secret
            BetrayalEvent(
                id: "naya_secret",
                betrayer: "naya",
                trigger: .secretDiscovery,
                consequences: [
                    BetrayalConsequence(type: .secretReveal, target: "healing_power_source", value: 1, isPermanent: true, affectsEnding: false),
                    BetrayalConsequence(type: .statLoss, target: "sanity", value: 15, isPermanent: false, affectsEnding: true)
                ],
                isPreventable: true,
                preventionRequirements: [
                    PathRequirement(type: .stat, value: "compassion", threshold: 80, operatorType: .greaterThan, isOptional: false),
                    PathRequirement(type: .relationship, value: "naya", threshold: 90, operatorType: .greaterThan, isOptional: false)
                ],
                warningSigns: [
                    "Naya's healing seems to come at a cost",
                    "You notice strange symbols in her healing",
                    "Naya becomes more secretive about her past",
                    "The healing leaves you feeling uneasy"
                ],
                aftermath: "Naya's secret has been revealed. Her healing power comes from a dark source, but your compassion has helped her find a better path."
            )
        ]
    }
    
    // MARK: - Route Scenes
    private func createRouteScenes() {
        routeScenes = [
            // Corruption Route Scene
            RouteScene(
                id: "corruption_ritual",
                route: .corruption,
                chapter: 5,
                title: "The Dark Ritual",
                narrative: "In the depths of the ancient temple, you find a ritual circle that promises immense power. The corruption within you resonates with the dark energy here.",
                choices: [
                    RouteChoice(
                        id: "embrace_corruption",
                        text: "Embrace the corruption fully",
                        consequences: [
                            RouteConsequence(type: .statChange, target: "corruption", value: 25, isPermanent: true, unlocksSecret: "dark_mastery", affectsEnding: true)
                        ],
                        requirements: [
                            PathRequirement(type: .stat, value: "corruption", threshold: 40, operatorType: .greaterThan, isOptional: false)
                        ],
                        isHidden: false,
                        affectsRoute: true
                    ),
                    RouteChoice(
                        id: "resist_corruption",
                        text: "Resist the temptation",
                        consequences: [
                            RouteConsequence(type: .statChange, target: "resolve", value: 15, isPermanent: true, unlocksSecret: "inner_strength", affectsEnding: true)
                        ],
                        requirements: [],
                        isHidden: false,
                        affectsRoute: true
                    )
                ],
                requirements: [
                    PathRequirement(type: .route, value: "corruption", threshold: 30, operatorType: .greaterThan, isOptional: false)
                ],
                isSecret: true,
                affectsEnding: true,
                ambientAudio: "dark_ritual",
                visualEffect: .corruption
            ),
            
            // Redemption Route Scene
            RouteScene(
                id: "redemption_sacrifice",
                route: .redemption,
                chapter: 7,
                title: "The Ultimate Sacrifice",
                narrative: "You stand before the ancient evil, knowing that the only way to save others is to sacrifice your own power and life force.",
                choices: [
                    RouteChoice(
                        id: "complete_sacrifice",
                        text: "Complete the sacrifice",
                        consequences: [
                            RouteConsequence(type: .endingInfluence, target: "redemption_ending", value: 50, isPermanent: true, unlocksSecret: "heroic_sacrifice", affectsEnding: true)
                        ],
                        requirements: [
                            PathRequirement(type: .stat, value: "compassion", threshold: 90, operatorType: .greaterThan, isOptional: false)
                        ],
                        isHidden: false,
                        affectsRoute: true
                    ),
                    RouteChoice(
                        id: "partial_sacrifice",
                        text: "Sacrifice some power",
                        consequences: [
                            RouteConsequence(type: .endingInfluence, target: "balanced_ending", value: 25, isPermanent: true, unlocksSecret: "moderate_hero", affectsEnding: true)
                        ],
                        requirements: [],
                        isHidden: false,
                        affectsRoute: true
                    )
                ],
                requirements: [
                    PathRequirement(type: .route, value: "redemption", threshold: 40, operatorType: .greaterThan, isOptional: false)
                ],
                isSecret: true,
                affectsEnding: true,
                ambientAudio: "sacred_ritual",
                visualEffect: .redemption
            )
        ]
    }
    
    // MARK: - Secrets
    private func createSecrets() {
        secrets = [
            Secret(
                id: "ancient_one_truth",
                name: "The Ancient One's True Nature",
                description: "The Ancient One is not what it seems. It's a being of pure consciousness, neither good nor evil, seeking understanding through mortal experiences.",
                location: "Dream Realm",
                requirements: [
                    PathRequirement(type: .stat, value: "dreamAlignment", threshold: 60, operatorType: .greaterThan, isOptional: false),
                    PathRequirement(type: .ability, value: "dreamWalking", threshold: 1, operatorType: .equal, isOptional: false)
                ],
                consequences: [
                    SecretConsequence(type: .endingInfluence, target: "transcendence_ending", value: 30, isPermanent: true, unlocksPath: "dream_transcendence")
                ],
                isRouteSpecific: true,
                affectsEnding: true
            ),
            
            Secret(
                id: "teacher_survival",
                name: "Teacher's Survival",
                description: "Your teacher didn't actually die. They faked their death to protect you from the Ancient One's attention and have been guiding you from the shadows.",
                location: "Hidden Chamber",
                requirements: [
                    PathRequirement(type: .choice, value: "hear_final_thought", threshold: 1, operatorType: .equal, isOptional: false),
                    PathRequirement(type: .stat, value: "intelligence", threshold: 70, operatorType: .greaterThan, isOptional: false)
                ],
                consequences: [
                    SecretConsequence(type: .allyRecruit, target: "teacher", value: 1, isPermanent: true, unlocksPath: "mentor_return")
                ],
                isRouteSpecific: false,
                affectsEnding: true
            )
        ]
    }
    
    // MARK: - Advanced Endings
    private func createAdvancedEndings() {
        advancedEndings = [
            AdvancedEnding(
                id: "transcendence_ending",
                title: "Transcendence",
                description: "You have transcended the physical realm and become one with the Ancient One, achieving true understanding of existence.",
                requirements: [
                    EndingRequirement(type: .stat, target: "dreamAlignment", value: 80, operatorType: .greaterThan),
                    EndingRequirement(type: .route, target: "transcendence", value: 60, operatorType: .greaterThan),
                    EndingRequirement(type: .secret, target: "ancient_one_truth", value: 1, operatorType: .equal)
                ],
                consequences: [
                    EndingConsequence(type: .worldState, target: "transcendence_achieved", value: 1, isPermanent: true)
                ],
                isSecret: true,
                routeSpecific: .transcendence,
                rarity: .mythic
            ),
            
            AdvancedEnding(
                id: "redemption_ending",
                title: "Redemption Through Sacrifice",
                description: "You sacrifice your power and life to save others, achieving true redemption and becoming a legend of compassion.",
                requirements: [
                    EndingRequirement(type: .stat, target: "compassion", value: 90, operatorType: .greaterThan),
                    EndingRequirement(type: .route, target: "redemption", value: 70, operatorType: .greaterThan),
                    EndingRequirement(type: .choice, target: "complete_sacrifice", value: 1, operatorType: .equal)
                ],
                consequences: [
                    EndingConsequence(type: .worldState, target: "redemption_legend", value: 1, isPermanent: true)
                ],
                isSecret: false,
                routeSpecific: .redemption,
                rarity: .legendary
            ),
            
            AdvancedEnding(
                id: "corruption_ending",
                title: "The Corrupted God",
                description: "You embrace the corruption fully and become a new god of darkness, ruling over the world with absolute power.",
                requirements: [
                    EndingRequirement(type: .stat, target: "corruption", value: 90, operatorType: .greaterThan),
                    EndingRequirement(type: .route, target: "corruption", value: 80, operatorType: .greaterThan),
                    EndingRequirement(type: .choice, target: "embrace_corruption", value: 1, operatorType: .equal)
                ],
                consequences: [
                    EndingConsequence(type: .worldState, target: "corruption_rule", value: 1, isPermanent: true)
                ],
                isSecret: false,
                routeSpecific: .corruption,
                rarity: .epic
            )
        ]
    }
    
    // MARK: - Advanced Combat
    private func createAdvancedCombat() {
        advancedCombatEncounters = [
            AdvancedCombatEncounter(
                id: "ancient_one_confrontation",
                title: "Confrontation with the Ancient One",
                narrative: "You stand before the Ancient One, a being of pure consciousness that has shaped the destiny of countless worlds. This is not a battle of strength, but of will and understanding.",
                enemies: [
                    AdvancedEnemy(
                        name: "The Ancient One",
                        health: 200,
                        maxHealth: 200,
                        abilities: [
                            AdvancedEnemyAbility(
                                name: "Reality Warp",
                                description: "Bend reality to confuse and disorient",
                                damage: 0,
                                effect: AdvancedAbilityEffect(type: .debuff, target: .ally, magnitude: 20, duration: 2, secondaryEffect: SecondaryEffect(type: .status, probability: 0.3, magnitude: 10, duration: 1)),
                                cooldown: 3,
                                trigger: .turnStart,
                                condition: "sanity > 50"
                            ),
                            AdvancedEnemyAbility(
                                name: "Consciousness Merge",
                                description: "Attempt to merge consciousness with the player",
                                damage: 15,
                                effect: AdvancedAbilityEffect(type: .status, target: .ally, magnitude: 25, duration: 3, secondaryEffect: nil),
                                cooldown: 5,
                                trigger: .healthThreshold,
                                condition: "health < 50"
                            )
                        ],
                        weaknesses: [.empathy, .dreamAlignment],
                        resistances: [.strength, .magic],
                        personality: .methodical,
                        backstory: "An ancient consciousness that has existed since the beginning of time, seeking to understand mortal existence through direct interaction.",
                        canBeSpared: true,
                        sparingConsequences: [
                            Consequence(stat: .dreamAlignment, change: 50),
                            Consequence(stat: .intelligence, change: 25)
                        ],
                        routeAffinity: [.pacifist: 100, .neutral: 50, .genocide: -100]
                    )
                ],
                allies: [allies.first(where: { $0.id == "kai" })!],
                environment: CombatEnvironment(
                    hazards: [
                        EnvironmentalHazard(id: "hazard_reality_instability", name: "Reality Instability", description: "Random stat changes due to reality distortion", damage: 10, trigger: .turnEnd, avoidable: true)
                    ],
                    advantages: [
                        EnvironmentalAdvantage(id: "advantage_dream_alignment", name: "Dream Alignment", description: "Increased dream abilities", bonus: [.magic: 15, .intelligence: 10], condition: "dreamAlignment > 50")
                    ],
                    interactables: ["consciousness_pool", "reality_anchor", "truth_mirror"],
                    weatherEffect: WeatherEffect(type: .clear, intensity: 1.0, duration: 300.0, effects: []),
                    timeEffect: TimeEffect(type: .midnight, duration: 300.0, effects: [])
                ),
                victoryConditions: [
                    VictoryCondition(type: .achieveRoute, target: "transcendence", value: 80, isOptional: false)
                ],
                defeatConditions: [
                    DefeatCondition(type: .sanityZero, target: "sanity", value: 0)
                ],
                isRouteSpecific: true,
                affectsEnding: true
            )
        ]
    }
    
    // MARK: - Public Methods
    func getBranchingPath(_ id: String) -> BranchingPath? {
        return branchingPaths.first { $0.id == id }
    }
    
    func getAlly(_ id: String) -> Ally? {
        return allies.first { $0.id == id }
    }
    
    func getBetrayalEvent(_ id: String) -> BetrayalEvent? {
        return betrayalEvents.first { $0.id == id }
    }
    
    func getRouteScene(_ id: String) -> RouteScene? {
        return routeScenes.first { $0.id == id }
    }
    
    func getSecret(_ id: String) -> Secret? {
        return secrets.first { $0.id == id }
    }
    
    func getAdvancedEnding(_ id: String) -> AdvancedEnding? {
        return advancedEndings.first { $0.id == id }
    }
    
    func getAdvancedCombat(_ id: String) -> AdvancedCombatEncounter? {
        return advancedCombatEncounters.first { $0.id == id }
    }
    
    func getAvailableEndings(for gameState: GameState) -> [AdvancedEnding] {
        var availableEndings: [AdvancedEnding] = []
        
        for ending in self.advancedEndings {
            let meetsRequirements = ending.requirements.allSatisfy { requirement in
                let currentValue = gameState.getStatValue(requirement.target)
                switch requirement.operatorType {
                case .greaterThan: return currentValue > requirement.value
                case .lessThan: return currentValue < requirement.value
                case .equal: return currentValue == requirement.value
                case .greaterThanOrEqual: return currentValue >= requirement.value
                case .lessThanOrEqual: return currentValue <= requirement.value
                case .notEqual: return currentValue != requirement.value
                }
            }
            if meetsRequirements {
                availableEndings.append(ending)
            }
        }
        return availableEndings
    }
}

// MARK: - Content Models

struct ChapterContent {
    let id: String
    let title: String
    let text: String
    let choices: [String]
    let weather: WeatherType
    let timeOfDay: TimeOfDay
    let audioId: String
}

struct ChoiceContent {
    let id: String
    let text: String
    let consequences: [Consequence]
    let audioId: String
}

struct AudioContent {
    let id: String
    let fileName: String
    let volume: Float
    let loop: Bool
}

struct CacheStats {
    let chapterCacheSize: Int
    let choiceCacheSize: Int
    let audioCacheSize: Int
    let cacheHits: Int
    let cacheMisses: Int
    let averageLoadTime: TimeInterval
    
    var cacheHitRate: Double {
        let total = cacheHits + cacheMisses
        return total > 0 ? Double(cacheHits) / Double(total) : 0.0
    }
} 
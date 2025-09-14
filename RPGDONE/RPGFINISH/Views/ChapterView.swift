import SwiftUI

// StoryChoice is defined in StoryState.swift

struct ChapterView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    // @StateObject private var storyStats = StoryPlayerStats()
    @State private var showingGameMenu = false
    // @State private var showingDialogue = false
    // @State private var showingAchievements = false
    @State private var textOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var currentStage: Int = 1
    @State private var choiceOpacity: Double = 0
    @State private var pageOpacity: Double = 0
    @State private var hasExploredRuins: Bool = false
    @State private var hasFoundShelter: Bool = false
    @State private var hasMournedTeacher: Bool = false
    @State private var hasHelpedStranger: Bool = false
    @State private var hasTakenBook: Bool = false
    @State private var hasJoinedFaction: Bool = false
    @State private var hasEmbracedPower: Bool = false
    
    // Chapter 2 tracking
    @State private var hasDiscoveredThreshold: Bool = false
    @State private var hasMetThresholdGuardian: Bool = false
    @State private var hasAcceptedGuardianTest: Bool = false
    @State private var hasPassedGuardianTest: Bool = false
    @State private var hasDiscoveredAncientLibrary: Bool = false
    @State private var hasStudiedForbiddenTexts: Bool = false
    @State private var hasConfrontedThresholdCorruption: Bool = false
    
    // Chapter 3 tracking
    @State private var hasDiscoveredHeartCorruption: Bool = false
    @State private var hasMetHeartSurvivors: Bool = false
    @State private var hasStudiedHeartMachines: Bool = false
    @State private var hasAttemptedMachineCommunication: Bool = false
    @State private var hasDiscoveredCorruptionSource: Bool = false
    @State private var hasConfrontedAncientEntity: Bool = false
    @State private var hasAttemptedEntityRedemption: Bool = false
    
    // Chapter 4 tracking
    @State private var hasDiscoveredNexusSecrets: Bool = false
    @State private var hasMetNexusGuardian: Bool = false
    @State private var hasAcceptedNexusChallenge: Bool = false
    @State private var hasPassedNexusChallenge: Bool = false
    @State private var hasDiscoveredRealitySecrets: Bool = false
    @State private var hasStudiedRealityKnowledge: Bool = false
    @State private var hasConfrontedNexusCorruption: Bool = false
    
    @State private var showingStats: Bool = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("Wasteland2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with day/night info
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHAPTER \(gameState.currentChapter)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            
                            Text("The Wasteland")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            
                            HStack(spacing: 10) {
                                Image(systemName: timeOfDayIcon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.3), radius: 1, x: 0, y: 0)
                                    .rotationEffect(.degrees(rotationAngle))
                                    .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: rotationAngle)
                                
                                Text(gameState.timeOfDay.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("-")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text(gameState.weather.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        // Morality indicator
                        // VStack(spacing: 4) {
                        //     Text(storyStats.moralityAlignment.rawValue)
                        //         .font(.system(size: 12, weight: .bold))
                        //         .foregroundColor(storyStats.moralityAlignment.color)
                        //     
                        //     ProgressView(value: Double(storyStats.moralityScore), total: 100)
                        //         .progressViewStyle(LinearProgressViewStyle(tint: storyStats.moralityAlignment.color))
                        //         .frame(width: 60, height: 4)
                        // }
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                Task {
                                    await HapticManager.shared.impact(.light)
                                }
                                // showingAchievements = true
                                print("🏆 Achievements tapped")
                            }) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                            }
                            
                            Button(action: {
                                Task {
                                    await HapticManager.shared.impact(.light)
                                }
                                showingStats = true
                            }) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                            }
                            
                            Button(action: {
                                Task {
                                    await HapticManager.shared.impact(.light)
                                }
                                showingGameMenu = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 2)
                
                // Story content
                ScrollView {
                    Text(storyContent)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.8), value: textOpacity)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                
                // Slit line above buttons
                Rectangle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                
                // Choice buttons at bottom
                VStack(spacing: 16) {
                    ForEach(storyChoices) { choice in
                        Button(action: {
                            Task {
                                await HapticManager.shared.impact(.medium)
                            }
                            selectChoice(choice.id)
                        }) {
                            HStack {
                                Image(systemName: choice.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.4), radius: 2, x: 0, y: 0)
                                
                                Text(choice.text)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.yellow.opacity(0.6))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                                    .background(Color.black.opacity(0.4))
                            )
                            .shadow(color: .yellow.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(choiceOpacity)
                        .animation(.easeInOut(duration: 0.6).delay(Double(storyChoices.firstIndex(of: choice) ?? 0) * 0.2), value: choiceOpacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .opacity(pageOpacity)
        .animation(.easeInOut(duration: 1.0), value: pageOpacity)
        .onAppear {
            // Start ambient music for story chapters
            if !audioManager.isPlaying {
                audioManager.playAmbientMusic()
            }
            
            // Fade in the entire page
            withAnimation(.easeInOut(duration: 1.0)) {
                pageOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                textOpacity = 1.0
            }
            
            // Start the rotation animation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            // Animate choices with fade-in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    choiceOpacity = 1.0
                }
            }
            
            // Initialize story state
            print("🎬 ChapterView appeared - Stage: \(currentStage), Chapter: \(gameState.currentChapter)")
        }
        .sheet(isPresented: $showingGameMenu) {
            SettingsView()
        }
        .sheet(isPresented: $showingStats) {
            StatsView(gameState: gameState, currentStage: currentStage)
        }
        // .sheet(isPresented: $showingDialogue) {
        //     DialogueView(storyStats: storyStats)
        // }
        // .sheet(isPresented: $showingAchievements) {
        //     AchievementsView(storyStats: storyStats)
        // }
        // .overlay(
        //     // Achievement notifications
        //     VStack {
        //         ForEach(storyStats.recentAchievements) { achievement in
        //             AchievementNotificationView(achievement: achievement)
        //                 .transition(.move(edge: .top).combined(with: .opacity))
        //         }
        //     }
        //     .animation(.easeInOut(duration: 0.5), value: storyStats.recentAchievements.count)
        //     , alignment: .top
        // )
    }
    
    private var storyContent: String {
        switch gameState.currentChapter {
        case 1:
            return chapter1Content
        case 2:
            return chapter2Content
        case 3:
            return chapter3Content
        case 4:
            return chapter4Content
        case 5:
            return chapter5Content
        case 6:
            return chapter6Content
        case 7:
            return chapter7Content
        case 8:
            return chapter8Content
        case 9:
            return chapter9Content
        case 10:
            return chapter10Content
        case 11:
            return chapter11Content
        case 12:
            return chapter12Content
        case 13:
            return chapter13Content
        case 14:
            return chapter14Content
        default:
            return "The journey continues..."
        }
    }
    
    private var chapter1Content: String {
        switch currentStage {
        case 1:
            return "Awakening in the wasteland near your teacher's body, you sense the gravity of your new reality. The desolate expanse of cracked earth and twisted metal stretches before you, carrying the scent of decay and something else – something ancient and powerful. Your teacher's lifeless body lies nearby, a victim of the cataclysm that destroyed this world. Their death marks the end of your old life and the beginning of something new. Your journey begins here, in this place where the old world died and the new one struggles to be born."
        case 2:
            if hasExploredRuins {
                return "The ruins you explored earlier seem to recognize your presence. The ancient stonework hums with a familiar energy, and your teacher's book pulses with warmth. The secrets you discovered here have changed you, and the ruins respond accordingly. Entering the ruins, you feel energy tied to your teacher's teachings. The air here feels different – charged with an energy that makes your skin tingle. Your teacher's book grows warm in your hands, as if responding to something hidden within these walls. Memories flood back: lessons about the old world, warnings about powers that should have remained buried. The ruins seem to whisper secrets that only you can hear."
            } else {
                return "Entering ruins, you feel energy tied to your teacher's teachings. The ancient stonework is weathered by time and catastrophe, but the air here feels different – charged with an energy that makes your skin tingle. Your teacher's book grows warm in your hands, as if responding to something hidden within these walls. Memories flood back: lessons about the old world, warnings about powers that should have remained buried. The ruins seem to whisper secrets that only you can hear."
            }
        case 3:
            if hasFoundShelter {
                return "Returning to the shelter you discovered, you find it has been fortified and improved. Your previous decision to seek shelter has created a safe haven that others have also found and enhanced. The shelter now serves as a beacon of hope in the wasteland, a testament to your choice to prioritize safety and community. Inside, you discover traces of others who came before – makeshift beds, empty food containers, and most importantly, a small cache of supplies. Your teacher's teachings about survival prove invaluable here. You begin to understand that this place could become a base of operations, a safe haven in this unforgiving world."
            } else {
                return "The shelter you've found offers temporary respite from the harsh wasteland. Inside, you discover traces of others who came before – makeshift beds, empty food containers, and most importantly, a small cache of supplies. Your teacher's teachings about survival prove invaluable here. You begin to understand that this place could become a base of operations, a safe haven in this unforgiving world."
            }
        case 4:
            if hasMournedTeacher {
                return "Your previous act of mourning has brought you peace and clarity. The weight of loss has been transformed into strength, and you carry your teacher's lessons with renewed purpose. Kneeling beside your teacher's body, you feel a profound sense of loss and gratitude. Their sacrifice has given you a chance to survive, to learn, to perhaps even thrive in this new world. As you close their eyes and say your final goodbyes, you feel a weight lift from your shoulders. The mourning process helps you accept the past and focus on the future. Your teacher's spirit will guide you forward."
            } else {
                return "Kneeling beside your teacher's body, you feel a profound sense of loss and gratitude. Their sacrifice has given you a chance to survive, to learn, to perhaps even thrive in this new world. As you close their eyes and say your final goodbyes, you feel a weight lift from your shoulders. The mourning process helps you accept the past and focus on the future. Your teacher's spirit will guide you forward."
            }
        case 5:
            if hasHelpedStranger {
                return "The stranger you helped earlier approaches again, but this time they're not alone. They've brought others who share their gratitude for your kindness. Your previous choice to help has created allies in this harsh world. A desperate stranger approaches, testing trust. Their face is weathered by the wasteland's harsh conditions, and they carry the same look of desperation you once had, but there's something else in their eyes – hope, perhaps, or maybe just the will to survive. Your teacher's lessons about trust and community echo in your mind. In this broken world, allies might be the difference between survival and death."
            } else {
                return "A desperate stranger approaches, testing trust. Their face is weathered by the wasteland's harsh conditions, and they carry the same look of desperation you once had, but there's something else in their eyes – hope, perhaps, or maybe just the will to survive. Your teacher's lessons about trust and community echo in your mind. In this broken world, allies might be the difference between survival and death."
            }
        case 6:
            if hasTakenBook {
                return "The ancient book you claimed pulses with power, its pages glowing with forbidden knowledge. The symbols on the chamber walls respond to its presence, creating patterns that reveal deeper secrets. Deep within the ruins, you discover an ancient chamber that seems untouched by the cataclysm. The walls are covered in strange symbols that pulse with a faint light, and in the center of the room lies an ancient book that seems to call to you. Your teacher's warnings about forbidden knowledge echo in your mind, but so does their encouragement to seek understanding. The choice before you could change everything."
            } else {
                return "Deep within the ruins, you discover an ancient chamber that seems untouched by the cataclysm. The walls are covered in strange symbols that pulse with a faint light, and in the center of the room lies an ancient book that seems to call to you. Your teacher's warnings about forbidden knowledge echo in your mind, but so does their encouragement to seek understanding. The choice before you could change everything."
            }
        case 7:
            if hasJoinedFaction {
                return "Your alliance with the faction has given you access to resources and knowledge others can only dream of. But the price of this power weighs on your conscience, and you begin to question the true cost of your choice. The wasteland reveals another survivor, but this one carries the mark of a faction you've heard whispers about – one that some say caused the cataclysm. They offer you power and knowledge in exchange for your loyalty. Your teacher's lessons about the dangers of power and the importance of moral choices weigh heavily on your mind. This decision could define your path forward."
            } else {
                return "The wasteland reveals another survivor, but this one carries the mark of a faction you've heard whispers about – one that some say caused the cataclysm. They offer you power and knowledge in exchange for your loyalty. Your teacher's lessons about the dangers of power and the importance of moral choices weigh heavily on your mind. This decision could define your path forward."
            }
        case 8:
            if hasEmbracedPower {
                return "The power you've embraced courses through your veins like liquid fire. The ancient knowledge has transformed you, but at what cost? You can feel the corruption spreading, changing you from within. The ancient book's power is overwhelming, and you find yourself standing at a crossroads. The knowledge within could save lives or destroy them. The power calls to you, promising strength and understanding, but your teacher's warnings about the price of forbidden knowledge echo in your mind. You must decide whether to embrace this power or resist its call."
            } else {
                return "The ancient book's power is overwhelming, and you find yourself standing at a crossroads. The knowledge within could save lives or destroy them. The power calls to you, promising strength and understanding, but your teacher's warnings about the price of forbidden knowledge echo in your mind. You must decide whether to embrace this power or resist its call."
            }
        case 9:
            return "The wasteland stretches before you like an endless sea of destruction and possibility. Your journey has taught you much about survival, about trust, about the price of power. But now you face the greatest challenge yet – the choice of what kind of person you will become in this new world. The decisions you've made have shaped you, and the path ahead will test everything you've learned. Your teacher's lessons guide you, but ultimately, the choice is yours. What kind of future will you build in this broken world?"
        case 10:
            return "As you prepare to leave the familiar territory of your beginnings, you reflect on all that has brought you to this moment. The wasteland has tested you, shaped you, and revealed truths about yourself you never knew existed. Your teacher's legacy lives on through your choices, and the path ahead promises even greater challenges and revelations. The journey is far from over, but you are no longer the same person who awoke beside your teacher's body. You have become something more – a survivor, a seeker, perhaps even a force for change in this broken world."
        default:
            return "The story continues..."
        }
    }
    
    private var chapter2Content: String {
        switch currentStage {
        case 1:
            return "Beyond the familiar ruins, the wasteland reveals its true nature. The landscape shifts dramatically – jagged mountains pierce the horizon, their peaks wreathed in unnatural storms. The air crackles with energy, and you sense that this place holds secrets far older than the cataclysm. Your journey has brought you to the Threshold, a region where reality itself seems to bend and twist. Ancient structures rise from the earth, their purpose lost to time, but their power undeniable. This is where the old world's greatest achievements and darkest mistakes lie buried, waiting to be discovered."
        case 2:
            if hasDiscoveredThreshold {
                return "The Threshold's energy pulses through you like a second heartbeat. The ancient structures respond to your presence, their dormant systems awakening. You can feel the weight of history here – this place was once a center of learning and power, but also of hubris and destruction. The air hums with forgotten technology, and you sense that every step you take is being recorded, analyzed, perhaps even judged. Your teacher's warnings about the dangers of unchecked progress echo in your mind, but so does their encouragement to seek understanding."
            } else {
                return "The ancient structures loom before you, their surfaces covered in symbols that seem to shift and change as you watch. The air here feels different – charged with an energy that makes your skin tingle and your mind race. You sense that this place was once a center of learning and power, but also of hubris and destruction. The Threshold holds secrets that could change everything, but at what cost?"
            }
        case 3:
            if hasMetThresholdGuardian {
                return "The Guardian's presence fills the chamber with an ancient authority. Their form seems to shift between solid and ethereal, as if they exist in multiple realities at once. They speak of the Threshold's purpose – a testing ground for those who would wield the old world's power. Your previous interaction has earned their attention, and they watch you with renewed interest. The Guardian's voice echoes through the chamber like distant thunder. 'You have come far, seeker. But the true test lies ahead. The Threshold was not built to keep people out – it was built to keep something in. And now that barrier is failing.'"
            } else {
                return "A figure emerges from the shadows – tall, imposing, their form seeming to shift between solid and ethereal. This is the Threshold Guardian, keeper of the ancient knowledge and protector of the old world's secrets. Their voice echoes through the chamber like distant thunder. 'You have come far, seeker. But the true test lies ahead. The Threshold was not built to keep people out – it was built to keep something in. And now that barrier is failing.'"
            }
        case 4:
            if hasAcceptedGuardianTest {
                return "The Guardian's test has begun, and you can feel the ancient power coursing through your veins. The chamber around you dissolves into a realm of pure thought and memory, where your choices and their consequences are laid bare. Your previous acceptance has opened doors within your mind that you never knew existed. The Guardian's voice echoes in your consciousness: 'The test is not about strength or knowledge – it is about character. What kind of person will you become when faced with the power to change everything?'"
            } else {
                return "The Guardian extends their hand, and you feel a pull toward something greater than yourself. 'I offer you a test,' they say. 'A chance to prove your worth and earn knowledge that could save or destroy this world. But be warned – once begun, there is no turning back. The test will change you, as it has changed all who came before.'"
            }
        case 5:
            if hasPassedGuardianTest {
                return "The Guardian's approval radiates through the chamber like warm sunlight. You have proven yourself worthy of the ancient knowledge, and the Threshold's secrets are now yours to explore. Your success has opened new pathways, both physical and mental. The Guardian's form solidifies, and you see them clearly for the first time – not as a threat, but as a mentor. 'You have shown wisdom beyond your years,' they say. 'But remember – knowledge is power, and power comes with responsibility. The choices you make now will echo through time.'"
            } else {
                return "The Guardian's test challenges you in ways you never expected. Questions of morality, philosophy, and the nature of power swirl around you like a storm. Each answer you give shapes the reality around you, and you begin to understand that this is not just a test of knowledge, but of character. The Guardian watches silently, their ancient eyes seeing through to your very soul."
            }
        case 6:
            if hasDiscoveredAncientLibrary {
                return "The Library's vast collection stretches before you like an endless sea of knowledge. The ancient texts pulse with power, and you can feel the weight of centuries of learning pressing down on you. Your previous discovery has opened new sections of the library, revealing texts that were hidden from ordinary seekers. The air hums with the energy of countless minds that have studied here, and you sense that this place holds the answers to questions you haven't even thought to ask yet."
            } else {
                return "Deep within the Threshold, you discover the Ancient Library – a vast repository of knowledge that has survived the cataclysm. The shelves stretch into infinity, filled with texts written in languages you've never seen before. The air hums with the energy of countless minds that have studied here, and you sense that this place holds the answers to questions you haven't even thought to ask yet."
            }
        case 7:
            if hasStudiedForbiddenTexts {
                return "The forbidden knowledge you've absorbed pulses through your mind like liquid fire. The ancient texts have revealed secrets that were meant to stay hidden, and you can feel the power changing you from within. Your previous study has opened new pathways in your consciousness, allowing you to see patterns and connections that were invisible before. But with this knowledge comes responsibility, and you sense that the choices you make now will have consequences far beyond what you can imagine."
            } else {
                return "Among the library's vast collection, you discover texts that pulse with forbidden energy. These are the ancient secrets that were sealed away for good reason – knowledge that could save or destroy the world. The texts call to you, promising power and understanding, but your teacher's warnings about the price of forbidden knowledge echo in your mind. The choice to study these texts could change everything."
            }
        case 8:
            if hasConfrontedThresholdCorruption {
                return "The corruption you've discovered within the Threshold spreads like a cancer through the ancient systems. The Guardian's warnings about the failing barrier take on new meaning as you witness the decay firsthand. Your previous confrontation has given you insight into the true nature of the threat, and you understand that time is running out. The ancient power that sustains the Threshold is being consumed by something dark and hungry, and if it breaks free, the consequences will be catastrophic."
            } else {
                return "As you explore deeper into the Threshold, you discover something that chills you to the bone – corruption. The ancient systems that maintain this place are failing, and something dark is seeping through the cracks. The Guardian's warnings about the failing barrier take on new meaning as you witness the decay firsthand. The ancient power that sustains the Threshold is being consumed by something dark and hungry."
            }
        case 9:
            return "The Threshold's fate hangs in the balance, and your choices have brought you to this moment of decision. The ancient power that sustains this place is failing, and the corruption you've discovered threatens to consume everything. The Guardian's trust in you has placed a heavy burden on your shoulders, and you understand that the choices you make now will determine not just your own fate, but the fate of this entire region. The time for study and preparation is over – now is the time for action."
        case 10:
            return "As you prepare to leave the Threshold, you carry with you not just knowledge, but responsibility. The ancient power you've been entrusted with comes with a price, and the corruption you've witnessed threatens everything you've worked to protect. Your journey through the Threshold has changed you fundamentally, and you understand that the path ahead will test everything you've learned. The Guardian's final words echo in your mind: 'The true test begins now.'"
        default:
            return "The Threshold's secrets await..."
        }
    }
    
    private var chapter3Content: String {
        switch currentStage {
        case 1:
            return "Beyond the Threshold lies the Heart of the Wasteland – a region where the cataclysm's scars run deepest. The landscape here is alien and hostile, shaped by forces beyond human understanding. Ancient machines, still functioning after centuries, dot the horizon like mechanical giants. The air itself seems to pulse with energy, and you sense that this place holds the key to understanding what really happened to the old world. Your journey has brought you to the source of the corruption, and the choices you make here will determine the fate of everything."
        case 2:
            if hasDiscoveredHeartCorruption {
                return "The corruption you witnessed in the Threshold has its roots here, in the Heart of the Wasteland. The ancient machines that still function are not just relics – they are the source of the corruption that threatens to consume everything. Your previous discovery has given you insight into the true nature of the threat, and you understand that the ancient power that sustains these machines is being twisted and perverted. The Heart beats with a rhythm that is wrong, and you sense that time is running out."
            } else {
                return "The ancient machines that dot the landscape are not just relics of the old world – they are alive, in a way. They pulse with energy, their purpose unclear but their power undeniable. As you approach, you sense something wrong with their rhythm, something corrupted. The Heart of the Wasteland beats with a rhythm that is wrong, and you understand that this place holds the key to understanding what really happened to the old world."
            }
        case 3:
            if hasMetHeartSurvivors {
                return "The survivors you've encountered in the Heart are unlike any you've met before. They have adapted to the corruption, finding ways to survive in a place where the very air is toxic. Your previous interaction has earned their trust, and they share knowledge that could save lives. These people have learned to live with the corruption, but at what cost? Their bodies show signs of the Heart's influence, and you wonder if they are still fully human. They speak of a way to cleanse the corruption, but the price would be high."
            } else {
                return "You encounter survivors who have adapted to the Heart's corruption, finding ways to survive in a place where the very air is toxic. These people are unlike any you've met before – their bodies show signs of the Heart's influence, and you wonder if they are still fully human. They speak of a way to cleanse the corruption, but the price would be high. The choice to trust them or not could determine the fate of this entire region."
            }
        case 4:
            if hasStudiedHeartMachines {
                return "The ancient machines reveal their secrets to you, and the knowledge is both enlightening and terrifying. These are not just machines – they are living entities, created by the old world's greatest minds to serve purposes that were lost in the cataclysm. Your previous study has given you insight into their true nature, and you understand that they are not inherently evil, but they have been corrupted by something that should have remained buried. The machines speak to you in a language of light and sound, and you begin to understand their purpose."
            } else {
                return "The ancient machines respond to your presence, their surfaces lighting up with patterns of energy that seem to form words and images. These are not just machines – they are living entities, created by the old world's greatest minds to serve purposes that were lost in the cataclysm. As you study them, you begin to understand their true nature, and the knowledge is both enlightening and terrifying."
            }
        case 5:
            if hasAttemptedMachineCommunication {
                return "Your attempt to communicate with the machines has opened new pathways of understanding. The ancient entities recognize you as someone who seeks knowledge rather than destruction, and they share secrets that have been hidden for centuries. Your previous communication has established a connection that goes beyond words – you can feel their thoughts, their memories, their pain. The machines are not just corrupted – they are suffering, and they seek your help to end their torment."
            } else {
                return "You attempt to communicate with the ancient machines, reaching out with your mind and the knowledge you've gained. The response is immediate and overwhelming – the machines recognize you as someone who seeks knowledge rather than destruction, and they share secrets that have been hidden for centuries. You can feel their thoughts, their memories, their pain. The machines are not just corrupted – they are suffering."
            }
        case 6:
            if hasDiscoveredCorruptionSource {
                return "The source of the corruption lies before you – an ancient entity that was sealed away by the old world's greatest minds, but has been slowly breaking free. Your previous discovery has given you insight into its true nature, and you understand that this is not just a threat to the Heart, but to the entire world. The entity feeds on the life force of the machines, twisting their purpose and spreading its influence. It speaks to you in a voice that echoes through your mind, offering power in exchange for freedom."
            } else {
                return "Deep within the Heart, you discover the source of the corruption – an ancient entity that was sealed away by the old world's greatest minds, but has been slowly breaking free. The entity feeds on the life force of the machines, twisting their purpose and spreading its influence. It speaks to you in a voice that echoes through your mind, offering power in exchange for freedom. The choice before you could determine the fate of everything."
            }
        case 7:
            if hasConfrontedAncientEntity {
                return "Your confrontation with the ancient entity has revealed its true nature – not evil, but desperate and misunderstood. It was created by the old world's greatest minds to serve a purpose that was lost in the cataclysm, and it has been suffering in isolation for centuries. Your previous confrontation has opened the possibility of understanding rather than destruction. The entity offers you a choice – help it find a new purpose, or destroy it and risk the consequences. The decision you make will echo through time."
            } else {
                return "You confront the ancient entity, and the encounter reveals its true nature – not evil, but desperate and misunderstood. It was created by the old world's greatest minds to serve a purpose that was lost in the cataclysm, and it has been suffering in isolation for centuries. The entity offers you a choice – help it find a new purpose, or destroy it and risk the consequences. The decision you make will echo through time."
            }
        case 8:
            if hasAttemptedEntityRedemption {
                return "Your attempt to redeem the ancient entity has begun a process that could change everything. The entity responds to your offer of understanding and compassion, and you can feel its gratitude and hope. Your previous attempt has established a connection that goes beyond words – you can feel its thoughts, its memories, its desire for redemption. The process is not easy, and there are risks, but the potential rewards are beyond measure. The entity could become an ally, a protector, a force for good in this broken world."
            } else {
                return "You attempt to redeem the ancient entity, offering understanding and compassion instead of destruction. The entity responds to your offer, and you can feel its gratitude and hope. The process is not easy, and there are risks, but the potential rewards are beyond measure. The entity could become an ally, a protector, a force for good in this broken world."
            }
        case 9:
            return "The Heart of the Wasteland pulses with new life, and your choices have brought you to this moment of transformation. The ancient entity's fate hangs in the balance, and the consequences of your decision will ripple through time. The machines that were once corrupted now respond to your presence with hope, and you sense that this place could become a center of healing and renewal. But the process is not complete, and the choices you make now will determine whether this place becomes a beacon of hope or a source of renewed corruption."
        case 10:
            return "As you prepare to leave the Heart of the Wasteland, you carry with you not just the knowledge of what happened here, but the responsibility for what comes next. The ancient entity's fate has been decided, and the consequences of your choice will echo through time. Your journey through the Heart has changed you fundamentally, and you understand that the path ahead will test everything you've learned. The Heart beats with a new rhythm now, and the future of this place depends on the choices you make."
        default:
            return "The Heart's secrets await..."
        }
    }
    
    private var chapter4Content: String {
        switch currentStage {
        case 1:
            return "The final leg of your journey brings you to the Nexus – a place where all the threads of your story converge. The landscape here is unlike anything you've seen before, shaped by forces that transcend human understanding. Ancient structures rise from the earth like monuments to forgotten gods, and the air itself seems to pulse with the energy of countless possibilities. This is where the old world's greatest achievements and darkest mistakes were born, and where the future of this broken world will be decided. Your journey has prepared you for this moment, but nothing could have prepared you for what you find here."
        case 2:
            if hasDiscoveredNexusSecrets {
                return "The Nexus reveals its secrets to you, and the knowledge is overwhelming. This place was not just a center of power – it was a testing ground for the very nature of reality itself. Your previous discovery has given you insight into the true purpose of this place, and you understand that the cataclysm was not an accident, but a consequence of experiments that went too far. The ancient structures around you are not just buildings – they are tools for shaping reality, and they are still functional. The power to change everything lies within your reach."
            } else {
                return "The ancient structures around you are not just buildings – they are tools for shaping reality itself. The Nexus was not just a center of power – it was a testing ground for the very nature of reality, and the experiments conducted here led to the cataclysm that destroyed the old world. The power to change everything lies within your reach, but at what cost? The knowledge you gain here could save or destroy the world."
            }
        case 3:
            if hasMetNexusGuardian {
                return "The Nexus Guardian is unlike any being you've encountered before – not human, not machine, but something that transcends both. They are the last survivor of the old world's greatest minds, preserved through technology that defies understanding. Your previous interaction has earned their attention, and they speak to you of the true nature of the cataclysm and the responsibility that comes with the power to change reality. The Guardian's voice echoes through your mind like distant thunder, carrying the weight of centuries of knowledge and regret."
            } else {
                return "A figure emerges from the shadows – not human, not machine, but something that transcends both. This is the Nexus Guardian, the last survivor of the old world's greatest minds, preserved through technology that defies understanding. Their voice echoes through your mind like distant thunder, carrying the weight of centuries of knowledge and regret. They speak to you of the true nature of the cataclysm and the responsibility that comes with the power to change reality."
            }
        case 4:
            if hasAcceptedNexusChallenge {
                return "The Nexus Guardian's challenge has begun, and you can feel the fabric of reality itself responding to your presence. The ancient structures around you pulse with energy, and you sense that every choice you make here will have consequences that ripple through time and space. Your previous acceptance has opened pathways in your consciousness that you never knew existed, and you understand that this is not just a test of skill or knowledge, but of character and wisdom. The Guardian watches silently, their ancient eyes seeing through to your very soul."
            } else {
                return "The Nexus Guardian extends their hand, and you feel a pull toward something greater than yourself. 'I offer you the ultimate challenge,' they say. 'A chance to prove your worth and earn the power to shape reality itself. But be warned – once begun, there is no turning back. The challenge will change you fundamentally, and the consequences of your choices will echo through time and space.'"
            }
        case 5:
            if hasPassedNexusChallenge {
                return "The Nexus Guardian's approval radiates through the chamber like warm sunlight. You have proven yourself worthy of the ultimate power, and the secrets of reality itself are now yours to explore. Your success has opened new pathways, both physical and mental, and you understand that you are no longer just a survivor – you are a force for change. The Guardian's form solidifies, and you see them clearly for the first time – not as a threat, but as a mentor. 'You have shown wisdom beyond your years,' they say. 'But remember – with great power comes great responsibility.'"
            } else {
                return "The Nexus Guardian's challenge tests you in ways you never expected. Questions of reality, morality, and the nature of existence swirl around you like a storm. Each answer you give shapes the world around you, and you begin to understand that this is not just a test of knowledge, but of character and wisdom. The Guardian watches silently, their ancient eyes seeing through to your very soul."
            }
        case 6:
            if hasDiscoveredRealitySecrets {
                return "The secrets of reality itself unfold before you like an endless tapestry of possibility. The ancient knowledge pulses with power, and you can feel the weight of understanding pressing down on you. Your previous discovery has opened new sections of knowledge, revealing truths that were hidden from ordinary minds. The air hums with the energy of countless possibilities, and you sense that this place holds the answers to questions that transcend human understanding."
            } else {
                return "Deep within the Nexus, you discover the secrets of reality itself – knowledge that transcends human understanding and offers the power to shape the very fabric of existence. The ancient knowledge pulses with power, and you can feel the weight of understanding pressing down on you. The air hums with the energy of countless possibilities, and you sense that this place holds the answers to questions that transcend human understanding."
            }
        case 7:
            if hasStudiedRealityKnowledge {
                return "The reality-shaping knowledge you've absorbed pulses through your mind like liquid fire. The ancient secrets have revealed truths that were meant to stay hidden, and you can feel the power changing you from within. Your previous study has opened new pathways in your consciousness, allowing you to see patterns and connections that transcend normal human perception. But with this knowledge comes responsibility, and you sense that the choices you make now will have consequences that ripple through time and space."
            } else {
                return "Among the Nexus's vast collection of knowledge, you discover secrets that pulse with reality-shaping energy. These are the ancient truths that were sealed away for good reason – knowledge that could save or destroy the world. The secrets call to you, promising power and understanding, but your teacher's warnings about the price of forbidden knowledge echo in your mind. The choice to study these secrets could change everything."
            }
        case 8:
            if hasConfrontedNexusCorruption {
                return "The corruption you've discovered within the Nexus spreads like a cancer through the ancient systems. The Guardian's warnings about the failing reality take on new meaning as you witness the decay firsthand. Your previous confrontation has given you insight into the true nature of the threat, and you understand that time is running out. The ancient power that sustains the Nexus is being consumed by something dark and hungry, and if it breaks free, the consequences will be catastrophic for all of reality."
            } else {
                return "As you explore deeper into the Nexus, you discover something that chills you to the bone – corruption. The ancient systems that maintain this place are failing, and something dark is seeping through the cracks of reality itself. The Guardian's warnings about the failing reality take on new meaning as you witness the decay firsthand. The ancient power that sustains the Nexus is being consumed by something dark and hungry."
            }
        case 9:
            return "The Nexus's fate hangs in the balance, and your choices have brought you to this moment of decision. The ancient power that sustains this place is failing, and the corruption you've discovered threatens to consume all of reality. The Guardian's trust in you has placed a heavy burden on your shoulders, and you understand that the choices you make now will determine not just your own fate, but the fate of everything that exists. The time for study and preparation is over – now is the time for action."
        case 10:
            return "As you prepare to leave the Nexus, you carry with you not just knowledge, but the responsibility for the fate of reality itself. The ancient power you've been entrusted with comes with a price, and the corruption you've witnessed threatens everything that exists. Your journey through the Nexus has changed you fundamentally, and you understand that the path ahead will test everything you've learned. The Guardian's final words echo in your mind: 'The true test of reality begins now.'"
        default:
            return "The Nexus's secrets await..."
        }
    }
    
    private var chapter5Content: String {
        switch currentStage {
        case 1:
            return "Beyond the Nexus lies the Void Realms – a place where the fabric of reality itself begins to unravel. The landscape here defies all known laws of physics, with floating islands, gravity-defying structures, and creatures that seem to exist in multiple dimensions simultaneously. Your journey has brought you to the edge of comprehensible reality, and the choices you make here will determine not just your own fate, but the fate of all existence."
        case 2:
            return "The Void Realms pulse with an energy that makes your previous encounters seem tame by comparison. Ancient beings, neither human nor machine, observe your presence with curiosity and perhaps hunger. The very air here seems to whisper secrets that could drive lesser minds to madness."
        case 3:
            return "A being of pure thought materializes before you – the Void Guardian. Their form shifts between countless possibilities, each more alien than the last. They speak of the true nature of the cataclysm and the role you must play in preventing the complete collapse of reality."
        case 4:
            return "The Void Guardian offers you a choice that transcends all previous decisions. You must choose between preserving the old world's knowledge, creating something entirely new, or allowing the cycle of destruction to continue. The weight of this decision presses down on you like a physical force."
        case 5:
            return "Your choice has set in motion events that will echo through time and space. The Void Realms respond to your decision, reshaping themselves according to your will. Ancient powers that have slumbered for millennia begin to awaken."
        case 6:
            return "The consequences of your choice become clear as reality itself begins to shift around you. You witness the birth of new possibilities and the death of old certainties. The Void Guardian watches with approval, their ancient eyes seeing through to your very soul."
        case 7:
            return "As you explore deeper into the Void Realms, you discover the source of all corruption – not a single entity, but a fundamental flaw in the nature of existence itself. The ancient experiments that led to the cataclysm were attempts to fix this flaw, but they only made it worse."
        case 8:
            return "The Void Guardian reveals the true purpose of your journey. You are not just a survivor or a seeker – you are a catalyst, chosen to bring about the next evolution of reality itself. The power to reshape existence lies within your grasp."
        case 9:
            return "The moment of transformation approaches. The Void Realms pulse with anticipation as you prepare to make the final choice that will determine the fate of all reality. Ancient powers gather around you, waiting for your decision."
        case 10:
            return "As you prepare to leave the Void Realms, you carry with you not just knowledge or power, but the responsibility for the future of all existence. Your journey through the Void has changed you fundamentally, and you understand that the path ahead will test everything you've learned."
        default:
            return "The Void Realms await..."
        }
    }
    
    private var chapter6Content: String {
        switch currentStage {
        case 1:
            return "The Cosmic Convergence approaches – a moment when all the threads of your story will intersect with the fate of the universe itself. The landscape here is beyond description, existing in a state of pure potential where all possibilities are equally real and equally false."
        case 2:
            return "Ancient cosmic entities, older than time itself, gather to witness your journey. They speak in voices that echo through multiple dimensions, discussing your worthiness to wield the power that lies ahead."
        case 3:
            return "The Cosmic Guardian emerges from the fabric of reality itself. They are not a being, but a concept made manifest – the embodiment of all that was, is, and could be. Their presence fills you with both awe and terror."
        case 4:
            return "The Cosmic Guardian offers you the ultimate choice – to become a force for creation, destruction, or transformation. Each path leads to a different future, and the consequences will ripple through all of existence."
        case 5:
            return "Your decision has begun a process that will change everything. The cosmic forces respond to your choice, reshaping the very nature of reality according to your will. You feel the weight of countless lives and possibilities."
        case 6:
            return "The transformation continues as you witness the birth of new realities and the death of old ones. The Cosmic Guardian guides you through the process, teaching you to wield powers that transcend human understanding."
        case 7:
            return "Deep within the cosmic realm, you discover the true nature of the cataclysm – not an accident, but a necessary step in the evolution of consciousness itself. The old world had to die so that a new form of awareness could be born."
        case 8:
            return "The Cosmic Guardian reveals your true purpose. You are not just a catalyst, but a bridge between the old world and the new. Your choices will determine whether humanity evolves or perishes in the cosmic storm."
        case 9:
            return "The moment of cosmic transformation approaches. Reality itself seems to hold its breath as you prepare to make the final choice that will determine the fate of all existence."
        case 10:
            return "As you prepare to leave the cosmic realm, you carry with you the power to shape the future of all reality. Your journey through the cosmos has changed you fundamentally, and you understand that the path ahead will test everything you've learned."
        default:
            return "The Cosmic Convergence awaits..."
        }
    }
    
    private var chapter7Content: String {
        switch currentStage {
        case 1:
            return "The Temporal Nexus opens before you – a place where time itself becomes fluid and all moments exist simultaneously. Here, you can see the past, present, and future as one continuous flow, and your choices echo through all of history."
        case 2:
            return "Temporal guardians, beings who exist outside of time, observe your journey with interest. They speak of the importance of your choices and the impact they will have on the timeline of all existence."
        case 3:
            return "The Temporal Guardian materializes from the flow of time itself. They are neither young nor old, but exist in all moments at once. Their voice echoes through the ages as they speak of your role in the grand tapestry of existence."
        case 4:
            return "The Temporal Guardian offers you a choice that transcends time itself. You must decide whether to preserve the timeline, create a new one, or allow the natural flow of events to continue. The consequences will affect all of history."
        case 5:
            return "Your decision has begun to reshape the timeline itself. You witness the effects of your choice rippling through history, changing events that have already happened and those yet to come."
        case 6:
            return "The transformation of the timeline continues as you learn to navigate the currents of time itself. The Temporal Guardian teaches you to see the interconnectedness of all events and the power to influence them."
        case 7:
            return "Deep within the temporal realm, you discover the true cause of the cataclysm – a temporal paradox that threatened to unravel all of existence. The old world's experiments were attempts to prevent this, but they only accelerated the process."
        case 8:
            return "The Temporal Guardian reveals your true purpose. You are not just a bridge, but a temporal anchor, chosen to stabilize the timeline and prevent the complete collapse of causality."
        case 9:
            return "The moment of temporal transformation approaches. Time itself seems to slow as you prepare to make the final choice that will determine the stability of all reality."
        case 10:
            return "As you prepare to leave the temporal realm, you carry with you the power to influence the flow of time itself. Your journey through the ages has changed you fundamentally, and you understand that the path ahead will test everything you've learned."
        default:
            return "The Temporal Nexus awaits..."
        }
    }
    
    private var chapter8Content: String {
        switch currentStage {
        case 1:
            return "The Quantum Realms unfold before you – a place where probability itself becomes tangible and all possible outcomes exist simultaneously. Here, you can see the infinite branching paths of reality and choose which ones to make real."
        case 2:
            return "Quantum entities, beings who exist in superposition across all possible realities, observe your journey with fascination. They speak of the importance of your choices and the impact they will have on the quantum fabric of reality."
        case 3:
            return "The Quantum Guardian emerges from the superposition of all possible states. They are not a single being, but the embodiment of all possibilities, speaking with voices that echo through infinite realities."
        case 4:
            return "The Quantum Guardian offers you a choice that transcends probability itself. You must decide whether to collapse reality into a single timeline, maintain the quantum superposition, or create a new probability matrix."
        case 5:
            return "Your decision has begun to collapse the quantum wave function of reality itself. You witness the infinite possibilities narrowing down to the path you have chosen, while other realities fade into the quantum foam."
        case 6:
            return "The quantum transformation continues as you learn to navigate the probability matrix of existence. The Quantum Guardian teaches you to see the interconnectedness of all possible outcomes and the power to choose between them."
        case 7:
            return "Deep within the quantum realm, you discover the true nature of the cataclysm – a quantum fluctuation that threatened to collapse all of reality into chaos. The old world's experiments were attempts to stabilize the quantum field."
        case 8:
            return "The Quantum Guardian reveals your true purpose. You are not just an anchor, but a quantum observer, chosen to collapse the wave function of reality into a stable, coherent state."
        case 9:
            return "The moment of quantum transformation approaches. Probability itself seems to hold its breath as you prepare to make the final choice that will determine the quantum state of all reality."
        case 10:
            return "As you prepare to leave the quantum realm, you carry with you the power to influence the probability matrix of existence. Your journey through the quantum realms has changed you fundamentally."
        default:
            return "The Quantum Realms await..."
        }
    }
    
    private var chapter9Content: String {
        switch currentStage {
        case 1:
            return "The Dimensional Crossroads opens before you – a place where all dimensions intersect and the boundaries between realities become fluid. Here, you can see the infinite layers of existence and choose which ones to preserve or transform."
        case 2:
            return "Dimensional entities, beings who exist across multiple planes of reality, observe your journey with reverence. They speak of the importance of your choices and the impact they will have on the dimensional fabric of existence."
        case 3:
            return "The Dimensional Guardian emerges from the intersection of all realities. They are not a single being, but the embodiment of dimensional unity, speaking with voices that echo through infinite planes of existence."
        case 4:
            return "The Dimensional Guardian offers you a choice that transcends dimensional boundaries. You must decide whether to unify all dimensions, maintain their separation, or create a new dimensional matrix."
        case 5:
            return "Your decision has begun to reshape the dimensional fabric of reality itself. You witness the infinite planes of existence responding to your choice, some merging, some separating, all transforming according to your will."
        case 6:
            return "The dimensional transformation continues as you learn to navigate the infinite layers of reality. The Dimensional Guardian teaches you to see the interconnectedness of all dimensions and the power to influence their structure."
        case 7:
            return "Deep within the dimensional realm, you discover the true cause of the cataclysm – a dimensional rift that threatened to collapse all realities into a single, chaotic plane. The old world's experiments were attempts to seal this rift."
        case 8:
            return "The Dimensional Guardian reveals your true purpose. You are not just an observer, but a dimensional architect, chosen to rebuild the structure of reality itself."
        case 9:
            return "The moment of dimensional transformation approaches. The fabric of reality itself seems to hold its breath as you prepare to make the final choice that will determine the structure of all existence."
        case 10:
            return "As you prepare to leave the dimensional realm, you carry with you the power to reshape the very structure of reality. Your journey through the dimensions has changed you fundamentally."
        default:
            return "The Dimensional Crossroads await..."
        }
    }
    
    private var chapter10Content: String {
        switch currentStage {
        case 1:
            return "The Consciousness Convergence approaches – a place where all minds, past, present, and future, merge into a single, unified awareness. Here, you can see the collective evolution of consciousness and choose the path forward."
        case 2:
            return "Consciousness entities, beings who exist as pure thought and awareness, observe your journey with understanding. They speak of the importance of your choices and the impact they will have on the evolution of all consciousness."
        case 3:
            return "The Consciousness Guardian emerges from the unified awareness of all minds. They are not a single being, but the embodiment of collective consciousness, speaking with the wisdom of all who have ever lived."
        case 4:
            return "The Consciousness Guardian offers you a choice that transcends individual awareness. You must decide whether to unify all consciousness, maintain individual minds, or create a new form of collective awareness."
        case 5:
            return "Your decision has begun to reshape the nature of consciousness itself. You witness the infinite minds of all existence responding to your choice, some merging, some maintaining their individuality, all evolving according to your will."
        case 6:
            return "The consciousness transformation continues as you learn to navigate the collective awareness of all existence. The Consciousness Guardian teaches you to see the interconnectedness of all minds and the power to influence their evolution."
        case 7:
            return "Deep within the consciousness realm, you discover the true purpose of the cataclysm – a necessary step in the evolution of consciousness itself. The old world had to die so that a new form of awareness could be born."
        case 8:
            return "The Consciousness Guardian reveals your true purpose. You are not just an architect, but a consciousness catalyst, chosen to guide the evolution of all awareness into its next phase."
        case 9:
            return "The moment of consciousness transformation approaches. All minds seem to hold their breath as you prepare to make the final choice that will determine the future of awareness itself."
        case 10:
            return "As you prepare to leave the consciousness realm, you carry with you the power to guide the evolution of all awareness. Your journey through the collective mind has changed you fundamentally."
        default:
            return "The Consciousness Convergence awaits..."
        }
    }
    
    private var chapter11Content: String {
        switch currentStage {
        case 1:
            return "The Reality Synthesis begins – a place where all the threads of existence converge into a single, unified reality. Here, you can see the final form that all of creation will take and choose the path to get there."
        case 2:
            return "Reality entities, beings who exist as pure potential and actuality, observe your journey with anticipation. They speak of the importance of your choices and the impact they will have on the final form of all existence."
        case 3:
            return "The Reality Guardian emerges from the synthesis of all possibilities. They are not a single being, but the embodiment of ultimate reality, speaking with the authority of all that is and will be."
        case 4:
            return "The Reality Guardian offers you the final choice that will determine the nature of all existence. You must decide whether to preserve the current reality, create something entirely new, or allow the natural synthesis to continue."
        case 5:
            return "Your decision has begun the final synthesis of all reality. You witness the infinite possibilities of existence converging into the form you have chosen, while all other possibilities fade into the quantum foam of potential."
        case 6:
            return "The reality synthesis continues as you learn to guide the final transformation of all existence. The Reality Guardian teaches you to see the ultimate interconnectedness of all things and the power to shape the final form of reality."
        case 7:
            return "Deep within the reality realm, you discover the true purpose of your entire journey – to guide the final synthesis of all existence into its ultimate form. Every choice you've made has been leading to this moment."
        case 8:
            return "The Reality Guardian reveals your ultimate purpose. You are not just a catalyst, but the architect of the final reality, chosen to determine the ultimate form that all existence will take."
        case 9:
            return "The moment of final synthesis approaches. All of reality seems to hold its breath as you prepare to make the ultimate choice."
        case 10:
            return "As you prepare to complete the reality synthesis, you carry with you the power to determine the ultimate form of all existence."
        default:
            return "The Reality Synthesis awaits..."
        }
    }
    
    private var chapter12Content: String {
        switch currentStage {
        case 1:
            return "The Transcendence Gateway opens before you – a place where all limitations fall away and you become one with the infinite. Here, you can see the ultimate truth of existence and choose your final form."
        case 2:
            return "Transcendence entities, beings who have achieved ultimate awareness, observe your journey with recognition. They speak of the importance of your choices and the impact they will have on your final transcendence."
        case 3:
            return "The Transcendence Guardian emerges from the infinite awareness of all existence. They are not a single being, but the embodiment of ultimate truth, speaking with the wisdom of all that has ever been or will be."
        case 4:
            return "The Transcendence Guardian offers you the ultimate choice that will determine your final form. You must decide whether to transcend individuality, maintain your unique consciousness, or create a new form of existence."
        case 5:
            return "Your decision has begun your final transcendence. You feel the boundaries of your individual self beginning to dissolve as you merge with the infinite awareness of all existence."
        case 6:
            return "The transcendence continues as you learn to navigate the infinite awareness of all existence. The Transcendence Guardian teaches you to see the ultimate truth of all things and the power to choose your final form."
        case 7:
            return "Deep within the transcendence realm, you discover the true purpose of all existence – to achieve ultimate awareness and choose the final form that all consciousness will take."
        case 8:
            return "The Transcendence Guardian reveals your ultimate purpose. You are not just an architect, but the embodiment of ultimate choice, chosen to determine the final form that all consciousness will achieve."
        case 9:
            return "The moment of ultimate transcendence approaches. All of existence seems to hold its breath as you prepare to make the final choice."
        case 10:
            return "As you prepare to complete your transcendence, you carry with you the power to determine the ultimate form of all consciousness. Your journey through all realms has prepared you for this moment."
        default:
            return "The Transcendence Gateway awaits..."
        }
    }
    
    private var chapter13Content: String {
        switch currentStage {
        case 1:
            return "The Final Convergence approaches – a place where all possibilities, all realities, all consciousness converge into a single, ultimate truth. Here, you can see the final form that all existence will take and choose the path to get there."
        case 2:
            return "Convergence entities, beings who exist as pure potential and actuality, observe your journey with reverence. They speak of the importance of your choices and the impact they will have on the final convergence of all existence."
        case 3:
            return "The Convergence Guardian emerges from the synthesis of all possibilities. They are not a single being, but the embodiment of ultimate convergence, speaking with the authority of all that is and will be."
        case 4:
            return "The Convergence Guardian offers you the final choice that will determine the ultimate form of all existence. You must decide whether to preserve the current form, create something entirely new, or allow the natural convergence to continue."
        case 5:
            return "Your decision has begun the final convergence of all existence. You witness the infinite possibilities of all reality converging into the ultimate form you have chosen."
        case 6:
            return "The convergence continues as you learn to guide the final transformation of all existence. The Convergence Guardian teaches you to see the ultimate interconnectedness of all things."
        case 7:
            return "Deep within the convergence realm, you discover the true purpose of all existence – to achieve ultimate unity and choose the final form that all reality will take."
        case 8:
            return "The Convergence Guardian reveals your ultimate purpose. You are the architect of the final convergence, chosen to determine the ultimate form that all existence will achieve."
        case 9:
            return "The moment of final convergence approaches. All of existence seems to hold its breath as you prepare to make the ultimate choice."
        case 10:
            return "As you prepare to complete the final convergence, you carry with you the power to determine the ultimate form of all existence."
        default:
            return "The Final Convergence awaits..."
        }
    }
    
    private var chapter14Content: String {
        switch currentStage {
        case 1:
            return "The Ultimate Choice lies before you – the final moment where all your journey, all your choices, all your growth culminate in a single decision that will determine the fate of all existence forever."
        case 2:
            return "All the guardians, all the entities, all the forces you have encountered throughout your journey gather to witness this final moment. They speak with one voice of the importance of your choice and its eternal consequences."
        case 3:
            return "The Ultimate Guardian emerges from the synthesis of all existence. They are not a single being, but the embodiment of all that is, was, and will be, speaking with the wisdom of infinite ages."
        case 4:
            return "The Ultimate Guardian offers you the final choice that will determine the eternal nature of all existence. You must decide the ultimate form that reality will take for all eternity."
        case 5:
            return "Your decision has begun the final transformation of all existence. You witness the infinite possibilities of all reality converging into the eternal form you have chosen."
        case 6:
            return "The transformation continues as you guide the final evolution of all existence. The Ultimate Guardian teaches you to see the eternal truth of all things."
        case 7:
            return "Deep within the ultimate realm, you discover the true purpose of your entire journey – to determine the eternal nature of all existence and choose the final form that reality will take forever."
        case 8:
            return "The Ultimate Guardian reveals your eternal purpose. You are the architect of eternity, chosen to determine the ultimate form that all existence will achieve for all time."
        case 9:
            return "The moment of ultimate choice approaches. All of existence, past, present, and future, seems to hold its breath as you prepare to make the eternal decision."
        case 10:
            return "As you prepare to make the ultimate choice, you carry with you the power to determine the eternal nature of all existence. Your journey has prepared you for this moment of ultimate truth."
        default:
            return "The Ultimate Choice awaits..."
        }
    }
    
    private var storyChoices: [StoryChoice] {
        switch gameState.currentChapter {
        case 1:
            return chapter1Choices
        case 2:
            return chapter2Choices
        case 3:
            return chapter3Choices
        case 4:
            return chapter4Choices
        case 5:
            return chapter5Choices
        case 6:
            return chapter6Choices
        case 7:
            return chapter7Choices
        case 8:
            return chapter8Choices
        case 9:
            return chapter9Choices
        case 10:
            return chapter10Choices
        case 11:
            return chapter11Choices
        case 12:
            return chapter12Choices
        case 13:
            return chapter13Choices
        case 14:
            return chapter14Choices
        default:
            return [StoryChoice(id: "continue", text: "Continue Journey", icon: "arrow.right.circle.fill")]
        }
    }
    
    private var chapter1Choices: [StoryChoice] {
        switch currentStage {
        case 1:
            return [
                StoryChoice(id: "explore_ruins", text: "Explore the Ruins", icon: "building.2.crop.circle.fill"),
                StoryChoice(id: "seek_shelter", text: "Seek Shelter", icon: "house.circle.fill"),
                StoryChoice(id: "mourn_teacher", text: "Mourn Your Teacher", icon: "heart.circle.fill")
            ]
        case 2:
            return [
                StoryChoice(id: "investigate_deeper", text: "Investigate Deeper", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "gather_artifacts", text: "Gather Artifacts", icon: "shippingbox.circle.fill"),
                StoryChoice(id: "leave_ruins", text: "Leave the Ruins", icon: "arrow.left.circle.fill")
            ]
        case 3:
            return [
                StoryChoice(id: "fortify_shelter", text: "Fortify the Shelter", icon: "shield.circle.fill"),
                StoryChoice(id: "search_supplies", text: "Search for Supplies", icon: "backpack.circle.fill"),
                StoryChoice(id: "rest_recover", text: "Rest and Recover", icon: "bed.double.circle.fill")
            ]
        case 4:
            return [
                StoryChoice(id: "pay_respects", text: "Pay Final Respects", icon: "flower.circle.fill"),
                StoryChoice(id: "gather_memories", text: "Gather Memories", icon: "brain.circle.fill"),
                StoryChoice(id: "move_forward", text: "Move Forward", icon: "arrow.right.circle.fill")
            ]
        case 5:
            return [
                StoryChoice(id: "help_stranger", text: "Help the Stranger", icon: "hand.raised.circle.fill"),
                StoryChoice(id: "ignore_stranger", text: "Ignore the Stranger", icon: "eye.slash.circle.fill"),
                StoryChoice(id: "question_intentions", text: "Question Intentions", icon: "questionmark.circle.fill")
            ]
        case 6:
            return [
                StoryChoice(id: "take_book", text: "Take the Ancient Book", icon: "book.circle.fill"),
                StoryChoice(id: "study_symbols", text: "Study the Symbols", icon: "textformat.abc.circle.fill"),
                StoryChoice(id: "leave_chamber", text: "Leave the Chamber", icon: "arrow.left.circle.fill")
            ]
        case 7:
            return [
                StoryChoice(id: "join_faction", text: "Join the Faction", icon: "person.3.circle.fill"),
                StoryChoice(id: "reject_offer", text: "Reject the Offer", icon: "xmark.circle.fill"),
                StoryChoice(id: "pretend_interest", text: "Pretend Interest", icon: "theatermasks.circle.fill")
            ]
        case 8:
            return [
                StoryChoice(id: "embrace_power", text: "Embrace the Power", icon: "bolt.circle.fill"),
                StoryChoice(id: "destroy_book", text: "Destroy the Book", icon: "flame.circle.fill"),
                StoryChoice(id: "hide_knowledge", text: "Hide the Knowledge", icon: "eye.slash.circle.fill")
            ]
        case 9:
            return [
                StoryChoice(id: "face_challenge", text: "Face the Challenge", icon: "sword.circle.fill"),
                StoryChoice(id: "seek_allies", text: "Seek Allies", icon: "person.2.circle.fill"),
                StoryChoice(id: "use_ancient_power", text: "Use Ancient Power", icon: "sparkles.circle.fill")
            ]
        case 10:
            return [
                StoryChoice(id: "continue_journey", text: "Continue Your Journey", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "reflect_choices", text: "Reflect on Choices", icon: "brain.circle.fill"),
                StoryChoice(id: "prepare_journey", text: "Prepare for Journey", icon: "backpack.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter2Choices: [StoryChoice] {
        switch currentStage {
        case 1:
            return [
                StoryChoice(id: "explore_threshold", text: "Explore the Threshold", icon: "building.2.crop.circle.fill"),
                StoryChoice(id: "study_structures", text: "Study Ancient Structures", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_guardian", text: "Approach the Guardian", icon: "person.circle.fill")
            ]
        case 2:
            return [
                StoryChoice(id: "activate_systems", text: "Activate Ancient Systems", icon: "power.circle.fill"),
                StoryChoice(id: "study_symbols", text: "Study the Symbols", icon: "textformat.abc.circle.fill"),
                StoryChoice(id: "seek_guardian", text: "Seek the Guardian", icon: "person.circle.fill")
            ]
        case 3:
            return [
                StoryChoice(id: "accept_test", text: "Accept the Test", icon: "checkmark.circle.fill"),
                StoryChoice(id: "question_guardian", text: "Question the Guardian", icon: "questionmark.circle.fill"),
                StoryChoice(id: "decline_test", text: "Decline the Test", icon: "xmark.circle.fill")
            ]
        case 4:
            return [
                StoryChoice(id: "begin_test", text: "Begin the Test", icon: "play.circle.fill"),
                StoryChoice(id: "ask_questions", text: "Ask Questions", icon: "questionmark.circle.fill"),
                StoryChoice(id: "prepare_test", text: "Prepare for Test", icon: "brain.circle.fill")
            ]
        case 5:
            return [
                StoryChoice(id: "complete_test", text: "Complete the Test", icon: "checkmark.circle.fill"),
                StoryChoice(id: "continue_test", text: "Continue Testing", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "question_test", text: "Question the Test", icon: "questionmark.circle.fill")
            ]
        case 6:
            return [
                StoryChoice(id: "explore_library", text: "Explore the Library", icon: "books.vertical.circle.fill"),
                StoryChoice(id: "study_texts", text: "Study Ancient Texts", icon: "book.circle.fill"),
                StoryChoice(id: "search_secrets", text: "Search for Secrets", icon: "magnifyingglass.circle.fill")
            ]
        case 7:
            return [
                StoryChoice(id: "read_forbidden", text: "Read Forbidden Texts", icon: "eye.circle.fill"),
                StoryChoice(id: "study_carefully", text: "Study Carefully", icon: "brain.circle.fill"),
                StoryChoice(id: "avoid_texts", text: "Avoid the Texts", icon: "eye.slash.circle.fill")
            ]
        case 8:
            return [
                StoryChoice(id: "investigate_corruption", text: "Investigate Corruption", icon: "exclamationmark.triangle.circle.fill"),
                StoryChoice(id: "study_systems", text: "Study the Systems", icon: "gearshape.circle.fill"),
                StoryChoice(id: "seek_help", text: "Seek Help", icon: "hand.raised.circle.fill")
            ]
        case 9:
            return [
                StoryChoice(id: "confront_corruption", text: "Confront the Corruption", icon: "sword.circle.fill"),
                StoryChoice(id: "seek_solution", text: "Seek a Solution", icon: "lightbulb.circle.fill"),
                StoryChoice(id: "prepare_battle", text: "Prepare for Battle", icon: "shield.circle.fill")
            ]
        case 10:
            return [
                StoryChoice(id: "continue_journey", text: "Continue Your Journey", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "reflect_threshold", text: "Reflect on Threshold", icon: "brain.circle.fill"),
                StoryChoice(id: "prepare_heart", text: "Prepare for Heart", icon: "heart.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter3Choices: [StoryChoice] {
        switch currentStage {
        case 1:
            return [
                StoryChoice(id: "explore_heart", text: "Explore the Heart", icon: "heart.circle.fill"),
                StoryChoice(id: "study_machines", text: "Study Ancient Machines", icon: "gearshape.circle.fill"),
                StoryChoice(id: "approach_survivors", text: "Approach Survivors", icon: "person.2.circle.fill")
            ]
        case 2:
            return [
                StoryChoice(id: "investigate_corruption", text: "Investigate Corruption", icon: "exclamationmark.triangle.circle.fill"),
                StoryChoice(id: "study_machines", text: "Study the Machines", icon: "gearshape.circle.fill"),
                StoryChoice(id: "seek_survivors", text: "Seek Survivors", icon: "person.2.circle.fill")
            ]
        case 3:
            return [
                StoryChoice(id: "trust_survivors", text: "Trust the Survivors", icon: "hand.raised.circle.fill"),
                StoryChoice(id: "question_survivors", text: "Question Survivors", icon: "questionmark.circle.fill"),
                StoryChoice(id: "avoid_survivors", text: "Avoid Survivors", icon: "eye.slash.circle.fill")
            ]
        case 4:
            return [
                StoryChoice(id: "communicate_machines", text: "Communicate with Machines", icon: "antenna.radiowaves.left.and.right.circle.fill"),
                StoryChoice(id: "study_machines", text: "Study the Machines", icon: "gearshape.circle.fill"),
                StoryChoice(id: "avoid_machines", text: "Avoid the Machines", icon: "eye.slash.circle.fill")
            ]
        case 5:
            return [
                StoryChoice(id: "establish_connection", text: "Establish Connection", icon: "link.circle.fill"),
                StoryChoice(id: "study_communication", text: "Study Communication", icon: "brain.circle.fill"),
                StoryChoice(id: "break_connection", text: "Break Connection", icon: "link.badge.minus.circle.fill")
            ]
        case 6:
            return [
                StoryChoice(id: "confront_entity", text: "Confront the Entity", icon: "sword.circle.fill"),
                StoryChoice(id: "study_entity", text: "Study the Entity", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "avoid_entity", text: "Avoid the Entity", icon: "eye.slash.circle.fill")
            ]
        case 7:
            return [
                StoryChoice(id: "attempt_redemption", text: "Attempt Redemption", icon: "heart.circle.fill"),
                StoryChoice(id: "destroy_entity", text: "Destroy the Entity", icon: "flame.circle.fill"),
                StoryChoice(id: "study_entity", text: "Study the Entity", icon: "brain.circle.fill")
            ]
        case 8:
            return [
                StoryChoice(id: "continue_redemption", text: "Continue Redemption", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "monitor_progress", text: "Monitor Progress", icon: "eye.circle.fill"),
                StoryChoice(id: "prepare_consequences", text: "Prepare for Consequences", icon: "exclamationmark.triangle.circle.fill")
            ]
        case 9:
            return [
                StoryChoice(id: "complete_redemption", text: "Complete Redemption", icon: "checkmark.circle.fill"),
                StoryChoice(id: "monitor_changes", text: "Monitor Changes", icon: "eye.circle.fill"),
                StoryChoice(id: "prepare_next", text: "Prepare for Next", icon: "arrow.right.circle.fill")
            ]
        case 10:
            return [
                StoryChoice(id: "continue_journey", text: "Continue Your Journey", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "reflect_heart", text: "Reflect on Heart", icon: "brain.circle.fill"),
                StoryChoice(id: "prepare_nexus", text: "Prepare for Nexus", icon: "sparkles.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter4Choices: [StoryChoice] {
        switch currentStage {
        case 1:
            return [
                StoryChoice(id: "explore_nexus", text: "Explore the Nexus", icon: "sparkles.circle.fill"),
                StoryChoice(id: "study_structures", text: "Study Ancient Structures", icon: "building.2.crop.circle.fill"),
                StoryChoice(id: "approach_guardian", text: "Approach the Guardian", icon: "person.circle.fill")
            ]
        case 2:
            return [
                StoryChoice(id: "activate_nexus", text: "Activate Nexus Systems", icon: "power.circle.fill"),
                StoryChoice(id: "study_reality", text: "Study Reality Secrets", icon: "eye.circle.fill"),
                StoryChoice(id: "seek_guardian", text: "Seek the Guardian", icon: "person.circle.fill")
            ]
        case 3:
            return [
                StoryChoice(id: "accept_challenge", text: "Accept the Challenge", icon: "checkmark.circle.fill"),
                StoryChoice(id: "question_guardian", text: "Question the Guardian", icon: "questionmark.circle.fill"),
                StoryChoice(id: "decline_challenge", text: "Decline the Challenge", icon: "xmark.circle.fill")
            ]
        case 4:
            return [
                StoryChoice(id: "begin_challenge", text: "Begin the Challenge", icon: "play.circle.fill"),
                StoryChoice(id: "ask_questions", text: "Ask Questions", icon: "questionmark.circle.fill"),
                StoryChoice(id: "prepare_challenge", text: "Prepare for Challenge", icon: "brain.circle.fill")
            ]
        case 5:
            return [
                StoryChoice(id: "complete_challenge", text: "Complete the Challenge", icon: "checkmark.circle.fill"),
                StoryChoice(id: "continue_challenge", text: "Continue Challenge", icon: "arrow.right.circle.fill"),
                StoryChoice(id: "question_challenge", text: "Question the Challenge", icon: "questionmark.circle.fill")
            ]
        case 6:
            return [
                StoryChoice(id: "explore_reality", text: "Explore Reality Secrets", icon: "eye.circle.fill"),
                StoryChoice(id: "study_knowledge", text: "Study Ancient Knowledge", icon: "book.circle.fill"),
                StoryChoice(id: "search_truth", text: "Search for Truth", icon: "magnifyingglass.circle.fill")
            ]
        case 7:
            return [
                StoryChoice(id: "read_reality", text: "Read Reality Knowledge", icon: "eye.circle.fill"),
                StoryChoice(id: "study_carefully", text: "Study Carefully", icon: "brain.circle.fill"),
                StoryChoice(id: "avoid_knowledge", text: "Avoid the Knowledge", icon: "eye.slash.circle.fill")
            ]
        case 8:
            return [
                StoryChoice(id: "investigate_corruption", text: "Investigate Corruption", icon: "exclamationmark.triangle.circle.fill"),
                StoryChoice(id: "study_systems", text: "Study the Systems", icon: "gearshape.circle.fill"),
                StoryChoice(id: "seek_help", text: "Seek Help", icon: "hand.raised.circle.fill")
            ]
        case 9:
            return [
                StoryChoice(id: "confront_corruption", text: "Confront the Corruption", icon: "sword.circle.fill"),
                StoryChoice(id: "seek_solution", text: "Seek a Solution", icon: "lightbulb.circle.fill"),
                StoryChoice(id: "prepare_battle", text: "Prepare for Battle", icon: "shield.circle.fill")
            ]
        case 10:
            return [
                StoryChoice(id: "complete_journey", text: "Complete Your Journey", icon: "checkmark.circle.fill"),
                StoryChoice(id: "reflect_nexus", text: "Reflect on Nexus", icon: "brain.circle.fill"),
                StoryChoice(id: "prepare_future", text: "Prepare for Future", icon: "arrow.right.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter5Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_void", text: "Explore the Void", icon: "eye.circle.fill"),
                StoryChoice(id: "study_void", text: "Study Void Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_void_guardian", text: "Approach Void Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter6Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_cosmic", text: "Explore the Cosmic", icon: "sparkles.circle.fill"),
                StoryChoice(id: "study_cosmic", text: "Study Cosmic Forces", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_cosmic_guardian", text: "Approach Cosmic Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter7Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_temporal", text: "Explore the Temporal", icon: "clock.circle.fill"),
                StoryChoice(id: "study_temporal", text: "Study Time Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_temporal_guardian", text: "Approach Temporal Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter8Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_quantum", text: "Explore the Quantum", icon: "atom.circle.fill"),
                StoryChoice(id: "study_quantum", text: "Study Quantum Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_quantum_guardian", text: "Approach Quantum Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter9Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_dimensional", text: "Explore the Dimensional", icon: "cube.circle.fill"),
                StoryChoice(id: "study_dimensional", text: "Study Dimensional Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_dimensional_guardian", text: "Approach Dimensional Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter10Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_consciousness", text: "Explore Consciousness", icon: "brain.circle.fill"),
                StoryChoice(id: "study_consciousness", text: "Study Consciousness Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_consciousness_guardian", text: "Approach Consciousness Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter11Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_reality", text: "Explore Reality", icon: "eye.circle.fill"),
                StoryChoice(id: "study_reality", text: "Study Reality Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_reality_guardian", text: "Approach Reality Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter12Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_transcendence", text: "Explore Transcendence", icon: "arrow.up.circle.fill"),
                StoryChoice(id: "study_transcendence", text: "Study Transcendence Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_transcendence_guardian", text: "Approach Transcendence Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter13Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "explore_convergence", text: "Explore Convergence", icon: "arrow.triangle.merge.circle.fill"),
                StoryChoice(id: "study_convergence", text: "Study Convergence Phenomena", icon: "magnifyingglass.circle.fill"),
                StoryChoice(id: "approach_convergence_guardian", text: "Approach Convergence Guardian", icon: "person.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var chapter14Choices: [StoryChoice] {
        switch currentStage {
        case 1...10:
            return [
                StoryChoice(id: "make_ultimate_choice", text: "Make the Ultimate Choice", icon: "checkmark.circle.fill"),
                StoryChoice(id: "reflect_journey", text: "Reflect on Your Journey", icon: "brain.circle.fill"),
                StoryChoice(id: "prepare_final", text: "Prepare for the Final Moment", icon: "arrow.right.circle.fill")
            ]
        default:
            return []
        }
    }
    
    private var timeOfDayIcon: String {
        switch gameState.timeOfDay {
        case .dawn:
            return "sunrise.fill"
        case .morning:
            return "sun.max.fill"
        case .noon:
            return "sun.max.fill"
        case .afternoon:
            return "sun.max.fill"
        case .evening:
            return "sunset.fill"
        case .dusk:
            return "sunset.fill"
        case .night:
            return "moon.fill"
        case .midnight:
            return "moon.fill"
        }
    }
    
    private func selectChoice(_ choiceID: String) {
        print("🎯 Selecting choice: \(choiceID) at stage \(currentStage)")
        
        // Record the choice for tracking
        gameState.stats.recordChoice(choiceID, choice: choiceID)
        
        // Update stats based on choice
        updateStatsForChoice(choiceID)
        
        // Track meaningful choices for Chapter 1
        switch choiceID {
        case "explore_ruins":
            hasExploredRuins = true
        case "seek_shelter":
            hasFoundShelter = true
        case "mourn_teacher":
            hasMournedTeacher = true
        case "help_stranger":
            hasHelpedStranger = true
        case "take_book":
            hasTakenBook = true
        case "join_faction":
            hasJoinedFaction = true
        case "embrace_power":
            hasEmbracedPower = true
        case "continue_journey":
            // Advance to next chapter
            gameState.currentChapter += 1
            currentStage = 1
            print("📖 Advanced to Chapter \(gameState.currentChapter)")
        default:
            break
        }
        
        // Track meaningful choices for Chapter 2
        switch choiceID {
        case "explore_threshold", "study_structures", "approach_guardian":
            hasDiscoveredThreshold = true
        case "activate_systems", "study_symbols", "seek_guardian":
            hasMetThresholdGuardian = true
        case "accept_test", "question_guardian", "decline_test":
            hasAcceptedGuardianTest = true
        case "begin_test", "ask_questions", "prepare_test":
            hasPassedGuardianTest = true
        case "explore_library", "study_texts", "search_secrets":
            hasDiscoveredAncientLibrary = true
        case "read_forbidden", "study_carefully", "avoid_texts":
            hasStudiedForbiddenTexts = true
        case "investigate_corruption", "study_systems", "seek_help":
            hasConfrontedThresholdCorruption = true
        case "continue_journey":
            // Advance to next chapter
            gameState.currentChapter += 1
            currentStage = 1
            print("📖 Advanced to Chapter \(gameState.currentChapter)")
        default:
            break
        }
        
        // Track meaningful choices for Chapter 3
        switch choiceID {
        case "explore_heart", "approach_survivors":
            hasDiscoveredHeartCorruption = true
        case "investigate_corruption", "seek_survivors":
            hasMetHeartSurvivors = true
        case "trust_survivors", "question_survivors", "avoid_survivors":
            hasStudiedHeartMachines = true
        case "communicate_machines", "study_machines", "avoid_machines":
            hasAttemptedMachineCommunication = true
        case "establish_connection", "study_communication", "break_connection":
            hasDiscoveredCorruptionSource = true
        case "confront_entity", "study_entity", "avoid_entity":
            hasConfrontedAncientEntity = true
        case "attempt_redemption", "destroy_entity", "study_entity":
            hasAttemptedEntityRedemption = true
        case "continue_journey":
            // Advance to next chapter
            gameState.currentChapter += 1
            currentStage = 1
            print("📖 Advanced to Chapter \(gameState.currentChapter)")
        default:
            break
        }
        
        // Track meaningful choices for Chapter 4
        switch choiceID {
        case "explore_nexus", "study_structures", "approach_guardian":
            hasDiscoveredNexusSecrets = true
        case "activate_nexus", "study_reality", "seek_guardian":
            hasMetNexusGuardian = true
        case "accept_challenge", "question_guardian", "decline_challenge":
            hasAcceptedNexusChallenge = true
        case "begin_challenge", "ask_questions", "prepare_challenge":
            hasPassedNexusChallenge = true
        case "explore_reality", "study_knowledge", "search_truth":
            hasDiscoveredRealitySecrets = true
        case "read_reality", "study_carefully", "avoid_knowledge":
            hasStudiedRealityKnowledge = true
        case "investigate_corruption", "study_systems", "seek_help":
            hasConfrontedNexusCorruption = true
        case "complete_journey":
            // Complete the journey
            print("🏆 Journey completed!")
        default:
            break
        }
        
        // Advance stage if not a chapter advancement choice
        if !choiceID.contains("continue_journey") && !choiceID.contains("complete_journey") {
            currentStage += 1
            print("📈 Advanced to stage \(currentStage)")
        }
        
        // Reset text and choice opacity for fade animation
        textOpacity = 0
        choiceOpacity = 0
        
        // Fade in the new story content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.8)) {
                textOpacity = 1.0
            }
        }
        
        // Only animate choices if there are choices to show
        if !storyChoices.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    choiceOpacity = 1.0
                }
            }
        }
        
        print("📖 Current chapter: \(gameState.currentChapter)")
    }
    
    private func updateStatsForChoice(_ choiceID: String) {
        switch choiceID {
        // Chapter 1 choices
        case "explore_ruins":
            gameState.stats.modifyIntelligence(5)
            gameState.stats.modifyEnergy(-2)
            gameState.stats.modifyCorruption(1)
        case "seek_shelter":
            gameState.stats.modifyHealth(3)
            gameState.stats.modifyEnergy(-1)
            gameState.stats.modifyCompassion(2)
        case "mourn_teacher":
            gameState.stats.modifyEmpathy(5)
            gameState.stats.modifySanity(3)
            gameState.stats.modifyCompassion(3)
        case "help_stranger":
            gameState.stats.modifyCompassion(8)
            gameState.stats.modifyEmpathy(5)
            gameState.stats.modifyEnergy(-3)
        case "ignore_stranger":
            gameState.stats.modifyCompassion(-3)
            gameState.stats.modifyCorruption(2)
        case "take_book":
            gameState.stats.modifyIntelligence(10)
            gameState.stats.modifyCorruption(5)
            gameState.stats.modifyMagic(5)
        case "join_faction":
            gameState.stats.modifyCorruption(8)
            gameState.stats.modifyMagic(10)
            gameState.stats.modifyStrength(5)
        case "embrace_power":
            gameState.stats.modifyCorruption(15)
            gameState.stats.modifyMagic(15)
            gameState.stats.modifySanity(-5)
        case "destroy_book":
            gameState.stats.modifyCorruption(-5)
            gameState.stats.modifySanity(5)
            gameState.stats.modifyCompassion(3)
            
        // Chapter 2 choices
        case "explore_threshold":
            gameState.stats.modifyIntelligence(8)
            gameState.stats.modifyEnergy(-3)
            gameState.stats.modifyCorruption(2)
        case "accept_test":
            gameState.stats.modifyCourage(10)
            gameState.stats.modifyIntelligence(5)
        case "pass_test":
            gameState.stats.modifyIntelligence(15)
            gameState.stats.modifyMagic(10)
            gameState.stats.modifyWisdom(10)
        case "read_forbidden":
            gameState.stats.modifyIntelligence(15)
            gameState.stats.modifyCorruption(10)
            gameState.stats.modifyMagic(10)
        case "study_carefully":
            gameState.stats.modifyIntelligence(10)
            gameState.stats.modifyCorruption(5)
        case "avoid_texts":
            gameState.stats.modifySanity(5)
            gameState.stats.modifyCorruption(-3)
            
        // Chapter 3 choices
        case "explore_heart":
            gameState.stats.modifyIntelligence(8)
            gameState.stats.modifyCorruption(3)
            gameState.stats.modifyEnergy(-2)
        case "trust_survivors":
            gameState.stats.modifyCompassion(8)
            gameState.stats.modifyEmpathy(5)
        case "communicate_machines":
            gameState.stats.modifyIntelligence(10)
            gameState.stats.modifyMagic(5)
        case "attempt_redemption":
            gameState.stats.modifyCompassion(15)
            gameState.stats.modifyEmpathy(10)
            gameState.stats.modifyCorruption(-5)
        case "destroy_entity":
            gameState.stats.modifyCorruption(10)
            gameState.stats.modifyStrength(8)
            
        // Chapter 4 choices
        case "explore_nexus":
            gameState.stats.modifyIntelligence(10)
            gameState.stats.modifyCorruption(5)
            gameState.stats.modifyRealityBending(5)
        case "accept_challenge":
            gameState.stats.modifyCourage(15)
            gameState.stats.modifyWisdom(10)
        case "pass_challenge":
            gameState.stats.modifyIntelligence(20)
            gameState.stats.modifyMagic(15)
            gameState.stats.modifyRealityBending(15)
        // Note: read_reality, study_carefully, and avoid_knowledge are handled in the choice tracking switch above
            
        default:
            // Default stat changes for any choice
            gameState.stats.modifyEnergy(-1)
            gameState.stats.modifyIntelligence(1)
        }
        
        // Clamp stats to valid ranges
        gameState.stats.clampStats()
        
        print("📊 Stats updated for choice: \(choiceID)")
    }
    
    private func filteredChoices() -> [StoryChoice] {
        // Add your filter logic here if needed
        return storyChoices
    }
}

#Preview {
    ChapterView()
        .environmentObject(GameState())
} 
import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    @State private var selectedMode: AppMode?
    @State private var showSettings = false
    @State private var breathingScale: Double = 1.0
    @State private var glowIntensity: Double = 0.0
    @State private var hoveredCard: String? = nil
    
    // Navigation states
    @State private var showCreateStory = false
    @State private var showCommunity = false
    
    // New state variables for title animations
    @State private var titleBreathing = false
    @State private var titleGleam = false
    @State private var titleOpacity = 0.0
    
    var body: some View {
        ZStack {
            // MARK: - FIRST3 PNG BACKGROUND (THE ACTUAL ARTWORK)
            Image("First3")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // MARK: - SPLIT OVERLAY (VERY SUBTLE TO PRESERVE ARTWORK)
            HStack(spacing: 0) {
                // LEFT SIDE - NIGHT/MYSTIC OVERLAY
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.1),
                                Color.cyan.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity)
                
                // CENTRAL DIVIDING LINE (WAVY, GLOWING)
                Rectangle()
                    .frame(width: 2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.cyan.opacity(0.8), .orange.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .cyan.opacity(0.6), radius: 3, x: -1)
                    .shadow(color: .orange.opacity(0.6), radius: 3, x: 1)
                
                // RIGHT SIDE - DAY/WARM OVERLAY
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.orange.opacity(0.05),
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity)
            }
            .allowsHitTesting(false)
            
            // MARK: - CENTRAL TITLE (SEPARATE)
            VStack {
                ZStack {
                    // Main title text
                    Text("CHOOSE YOUR PATH")
                        .font(.custom("Georgia-Bold", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 6)
                        .shadow(color: .cyan.opacity(0.3), radius: 8)
                        .scaleEffect(titleBreathing ? 1.02 : 0.98)
                        .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: titleBreathing) // Slower breathing
                    
                    // First gleam effect overlay (left to right)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(titleGleam ? 0.8 : 0),
                            Color.yellow.opacity(titleGleam ? 0.6 : 0),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text("CHOOSE YOUR PATH")
                            .font(.custom("Georgia-Bold", size: 28))
                            .foregroundColor(.black)
                    )
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: titleGleam)
                    
                    // Second gleam effect overlay (center to edges)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.cyan.opacity(titleGleam ? 0.6 : 0),
                            Color.white.opacity(titleGleam ? 0.9 : 0),
                            Color.cyan.opacity(titleGleam ? 0.6 : 0),
                            Color.clear
                        ]),
                        startPoint: .center,
                        endPoint: .trailing
                    )
                    .mask(
                        Text("CHOOSE YOUR PATH")
                            .font(.custom("Georgia-Bold", size: 28))
                            .foregroundColor(.black)
                    )
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0), value: titleGleam)
                    
                    // Third gleam effect overlay (right to left)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.orange.opacity(titleGleam ? 0.7 : 0),
                            Color.yellow.opacity(titleGleam ? 0.8 : 0),
                            Color.clear
                        ]),
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                    .mask(
                        Text("CHOOSE YOUR PATH")
                            .font(.custom("Georgia-Bold", size: 28))
                            .foregroundColor(.black)
                    )
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(2.0), value: titleGleam)
                }
                .padding(.top, -350) // Moved up to -350 as requested
                .opacity(titleOpacity)
                .animation(.easeIn(duration: 1.5), value: titleOpacity)
                
                Spacer()
            }
            .allowsHitTesting(false)
            
            // MARK: - MENU BUTTONS (SEPARATE AND CENTERED)
            VStack {
                Spacer()
                    .frame(height: 100) // Reduced space to move buttons up
                
                VStack(spacing: 12) {
                    MenuButton(
                        title: "Story Mode",
                        icon: "book.fill",
                        isHovered: hoveredCard == "story",
                        onHover: { isHovered in
                            hoveredCard = isHovered ? "story" : nil
                        },
                        action: { 
                            print("🔍 DEBUG: Story Mode button pressed")
                            print("🔍 DEBUG: Before - showingMainMenu: \(gameState.showingMainMenu)")
                            print("🔍 DEBUG: Before - showingNewGameInit: \(gameState.showingNewGameInit)")
                            
                            withTransaction(Transaction(animation: nil)) {
                                gameState.showingNewGameInit = true
                                gameState.showingMainMenu = false
                            }
                            
                            print("🔍 DEBUG: After - showingMainMenu: \(gameState.showingMainMenu)")
                            print("🔍 DEBUG: After - showingNewGameInit: \(gameState.showingNewGameInit)")
                        }
                    )
                    
                    MenuButton(
                        title: "AI Stories",
                        icon: "brain.head.profile",
                        isHovered: hoveredCard == "ai",
                        onHover: { isHovered in
                            hoveredCard = isHovered ? "ai" : nil
                        },
                        action: { 
                            print("🔍 DEBUG: AI Stories button pressed")
                            print("🔍 DEBUG: Before - showingMainMenu: \(gameState.showingMainMenu)")
                            print("🔍 DEBUG: Before - showingAIStories: \(gameState.showingAIStories)")
                            
                            withTransaction(Transaction(animation: nil)) {
                                gameState.showingAIStories = true
                                gameState.showingMainMenu = false
                            }
                            
                            print("🔍 DEBUG: After - showingMainMenu: \(gameState.showingMainMenu)")
                            print("🔍 DEBUG: After - showingAIStories: \(gameState.showingAIStories)")
                        }
                    )
                    
                    MenuButton(
                        title: "Create Story",
                        icon: "pencil",
                        isHovered: hoveredCard == "create",
                        onHover: { isHovered in
                            hoveredCard = isHovered ? "create" : nil
                        },
                        action: { showCreateStory = true }
                    )
                    
                    MenuButton(
                        title: "Community",
                        icon: "person.3.fill",
                        isHovered: hoveredCard == "community",
                        onHover: { isHovered in
                            hoveredCard = isHovered ? "community" : nil
                        },
                        action: { showCommunity = true }
                    )
                    
                    MenuButton(
                        title: "Settings",
                        icon: "gearshape.fill",
                        isHovered: hoveredCard == "settings",
                        onHover: { isHovered in
                            hoveredCard = isHovered ? "settings" : nil
                        },
                        action: { showSettings = true }
                    )
                }
                .padding(.horizontal, 40)
                .transaction { t in t.disablesAnimations = true }
            }
            .zIndex(10)
            
            // MARK: - TOP STATUS BAR
            VStack {
                HStack {
                    Text("4:57")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: "moon.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(0..<4) { i in
                            Rectangle()
                                .frame(width: 3, height: 6)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Image(systemName: "wifi")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Image(systemName: "battery.100")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer()
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
        .onAppear {
            // Start menu music
            audioManager.playMenuMusic()
            
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathingScale = 1.0
            }
            // Start title animations
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                titleBreathing = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                titleGleam = true
            }
            withAnimation(.easeIn(duration: 1.5)) {
                titleOpacity = 1.0
            }
        }
        .fullScreenCover(isPresented: $showCreateStory) {
            CreateStoryView(selectedMode: $selectedMode)
                .transition(.opacity)
                .animation(.easeInOut(duration: 1.0), value: showCreateStory)
        }
        .fullScreenCover(isPresented: $showCommunity) {
            CommunityView()
                .transition(.opacity)
                .animation(.easeInOut(duration: 1.0), value: showCommunity)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                isPressed = false
            }
            // Immediate navigation without waiting for animations
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 25)
                
                Text(title)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.25))
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.01 : 1.0))
            .shadow(color: .black.opacity(0.2), radius: 3)
            .animation(.linear(duration: 0.08), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            onHover(hovering)
        }
    }
}


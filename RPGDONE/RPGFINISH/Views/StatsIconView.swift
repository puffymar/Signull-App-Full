import SwiftUI

// MARK: - Stats View Wrapper

struct StatsView: View {
    let gameState: GameState
    let currentStage: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            StatsIconView(gameState: gameState, currentStage: currentStage)
                .navigationTitle("Character Stats")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(Theme.textPrimary)
                    }
                }
        }
    }
}

// MARK: - Stats Icon View

struct StatsIconView: View {
    let gameState: GameState
    let currentStage: Int
    @State private var animateStats = false
    @State private var pulseHealth = false
    @State private var pulseMagic = false
    @State private var pulseEnergy = false
    @State private var showTooltip = false
    @State private var selectedStat: StatType? = nil
    @State private var selectedTab: StatsTab = .core
    @State private var tabBreathing: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    
    enum StatsTab: String, CaseIterable {
        case core = "Core"
        case story = "Story"
        case progress = "Progress"
        case relationships = "Relations"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Enhanced title with breathing animation
                Text("CHARACTER STATS")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.6), radius: 8, x: 0, y: 0)
                    .opacity(animateStats ? 1.0 : 0.0)
                    .offset(y: animateStats ? 0 : 20)
                    .scaleEffect(1.0 + tabBreathing * 0.02)
                
                // Enhanced tab selector with better spacing
                HStack(spacing: 8) {
                    ForEach(StatsTab.allCases, id: \.self) { tab in
                        Button(action: {
                            Task {
                                await HapticManager.shared.impact(.light)
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedTab == tab ? Color.cyan.opacity(0.2) : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedTab == tab ? Color.cyan.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                )
                
                // Content based on selected tab with better spacing
                switch selectedTab {
                case .core:
                    CoreStatsView(gameState: gameState)
                        .transition(.opacity.combined(with: .scale))
                case .story:
                    StoryStatsView(gameState: gameState, currentStage: currentStage)
                        .transition(.opacity.combined(with: .scale))
                case .progress:
                    ProgressStatsView(gameState: gameState)
                        .transition(.opacity.combined(with: .scale))
                case .relationships:
                    RelationshipStatsView(gameState: gameState)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.95),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateStats = true
            }
            
            // Start breathing animation for title
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                tabBreathing = 1.0
            }
            
            // Start shimmer animation
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
            
            // Start pulsing animations for stats
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseHealth = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseMagic = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseEnergy = true
                }
            }
        }
        .sheet(isPresented: $showTooltip) {
            if let selectedStat = selectedStat {
                StatTooltipView(statType: selectedStat)
            }
        }
    }
    
    private func getCurrentStage() -> Int {
        // This would need to be passed from ChapterView
        return 1
    }
}

// MARK: - Core Stats View

struct CoreStatsView: View {
    let gameState: GameState
    @State private var animateBars = false
    @State private var statBreathing: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 20) {
            // Core stats section with enhanced spacing
            VStack(spacing: 16) {
                // Health stat with enhanced visual
                ShimmerStatBarView(
                    title: "HEALTH",
                    value: gameState.stats.health,
                    maxValue: 100,
                    statType: .health,
                    icon: "heart.fill",
                    color: .red,
                    pulse: true,
                    shimmerOffset: shimmerOffset
                )
                
                // Magic stat with enhanced visual
                ShimmerStatBarView(
                    title: "MAGIC",
                    value: gameState.stats.magic,
                    maxValue: 100,
                    statType: .magic,
                    icon: "sparkles",
                    color: .purple,
                    pulse: true,
                    shimmerOffset: shimmerOffset
                )
                
                // Energy stat with enhanced visual
                ShimmerStatBarView(
                    title: "ENERGY",
                    value: gameState.stats.energy,
                    maxValue: 100,
                    statType: .energy,
                    icon: "bolt.fill",
                    color: .yellow,
                    pulse: true,
                    shimmerOffset: shimmerOffset
                )
            }
            .opacity(animateBars ? 1.0 : 0.0)
            .offset(y: animateBars ? 0 : 20)
            
            // Secondary stats grid with enhanced spacing
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                EnhancedSecondaryStatView(
                    title: "STRENGTH",
                    value: gameState.stats.strength,
                    icon: "figure.strengthtraining.traditional",
                    color: .orange
                )
                
                EnhancedSecondaryStatView(
                    title: "INTELLIGENCE",
                    value: gameState.stats.intelligence,
                    icon: "brain.head.profile",
                    color: .blue
                )
                
                EnhancedSecondaryStatView(
                    title: "CHARISMA",
                    value: gameState.stats.charisma,
                    icon: "person.2.fill",
                    color: .pink
                )
                
                EnhancedSecondaryStatView(
                    title: "SANITY",
                    value: gameState.stats.sanity,
                    icon: "eye.fill",
                    color: .cyan
                )
            }
            .opacity(animateBars ? 1.0 : 0.0)
            .offset(y: animateBars ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateBars = true
            }
            
            // Breathing animation for stats
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                statBreathing = 1.0
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - Shimmer Stat Bar View

struct ShimmerStatBarView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let statType: StatType
    let icon: String
    let color: Color
    let pulse: Bool
    let shimmerOffset: CGFloat
    
    @State private var animateBar = false
    @State private var showMasteryBadge = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                
                Text(title)
                    .font(Theme.subtitleFont(size: 14).weight(.medium))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                // Mastery badge for high stats
                if value >= 90 {
                    Text("MASTERY")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(4)
                        .foregroundColor(.cyan)
                        .opacity(showMasteryBadge ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: showMasteryBadge)
                }
                
                Text("\(value)/\(maxValue)")
                    .font(Theme.subtitleFont(size: 12).weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
            }
            
            // Progress bar with shimmer effect
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateBar ? geometry.size.width * CGFloat(value) / CGFloat(maxValue) : 0, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: animateBar)
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 20, height: 8)
                        .offset(x: shimmerOffset)
                        .blendMode(.screen)
                        .clipped()
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                animateBar = true
            }
            
            if value >= 90 {
                withAnimation(.easeInOut(duration: 0.5).delay(1.0)) {
                    showMasteryBadge = true
                }
            }
        }
    }
}

// MARK: - Story Stats View

struct StoryStatsView: View {
    let gameState: GameState
    let currentStage: Int
    @State private var animateContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Story Progress with enhanced visual
                VStack(alignment: .leading, spacing: 12) {
                    Text("STORY PROGRESS")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.6), radius: 4)
                    
                    HStack {
                        Text("Chapter \(gameState.currentChapter)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("Stage \(currentStage)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                
                // Story Stats with enhanced grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    EnhancedStoryStatView(
                        title: "CORRUPTION",
                        value: gameState.stats.corruption,
                        icon: "exclamationmark.triangle.fill",
                        color: .red,
                        isNegative: true
                    )
                    
                    EnhancedStoryStatView(
                        title: "DREAM ALIGNMENT",
                        value: gameState.stats.dreamAlignment,
                        icon: "moon.fill",
                        color: .purple,
                        isNegative: false
                    )
                    
                    EnhancedStoryStatView(
                        title: "COMPASSION",
                        value: gameState.stats.compassion,
                        icon: "heart.fill",
                        color: .pink,
                        isNegative: false
                    )
                    
                    EnhancedStoryStatView(
                        title: "RESOLVE",
                        value: gameState.stats.resolve,
                        icon: "shield.fill",
                        color: .blue,
                        isNegative: false
                    )
                    
                    EnhancedStoryStatView(
                        title: "EMPATHY",
                        value: gameState.stats.empathy,
                        icon: "brain.head.profile",
                        color: .cyan,
                        isNegative: false
                    )
                    
                    EnhancedStoryStatView(
                        title: "REALITY BENDING",
                        value: gameState.stats.realityBending,
                        icon: "sparkles",
                        color: .yellow,
                        isNegative: false
                    )
                }
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                
                // Choice Tracking with enhanced visual
                VStack(alignment: .leading, spacing: 12) {
                    Text("MAJOR CHOICES")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.6), radius: 4)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(gameState.stats.majorChoices.keys.prefix(5)), id: \.self) { choice in
                            HStack {
                                Text(choice.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("✓")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black.opacity(0.2))
                            )
                        }
                    }
                }
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Progress Stats View

struct ProgressStatsView: View {
    let gameState: GameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Chapter Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("CHAPTER PROGRESS")
                        .font(Theme.subtitleFont(size: 14).weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    ForEach(1...4, id: \.self) { chapter in
                        HStack {
                            Text("Chapter \(chapter)")
                                .font(Theme.bodyFont(size: 12))
                                .foregroundColor(Theme.textSecondary)
                            
                            Spacer()
                            
                            if let progress = gameState.stats.getChapterProgress(chapter) {
                                Text(progress.isCompleted ? "Completed" : "In Progress")
                                    .font(Theme.bodyFont(size: 10))
                                    .foregroundColor(progress.isCompleted ? .green : .orange)
                            } else {
                                Text("Not Started")
                                    .font(Theme.bodyFont(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Achievements
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACHIEVEMENTS")
                        .font(Theme.subtitleFont(size: 14).weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(gameState.stats.achievements.count) Unlocked")
                        .font(Theme.bodyFont(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Secrets
                VStack(alignment: .leading, spacing: 8) {
                    Text("SECRETS DISCOVERED")
                        .font(Theme.subtitleFont(size: 14).weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(gameState.stats.unlockedSecrets.count) Found")
                        .font(Theme.bodyFont(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Combat Stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ProgressStatView(
                        title: "SPARED",
                        value: gameState.stats.enemiesSpared,
                        icon: "hand.raised.fill",
                        color: .green
                    )
                    
                    ProgressStatView(
                        title: "DEFEATED",
                        value: gameState.stats.enemiesDefeated,
                        icon: "shield.fill",
                        color: .blue
                    )
                    
                    ProgressStatView(
                        title: "KILLED",
                        value: gameState.stats.enemiesKilled,
                        icon: "flame.fill",
                        color: .red
                    )
                }
            }
        }
    }
}

// MARK: - Relationship Stats View

struct RelationshipStatsView: View {
    let gameState: GameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Character Relationships
                VStack(alignment: .leading, spacing: 8) {
                    Text("RELATIONSHIPS")
                        .font(Theme.subtitleFont(size: 14).weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    ForEach(Array(gameState.stats.relationshipLevels.keys.sorted()), id: \.self) { character in
                        HStack {
                            Text(character)
                                .font(Theme.bodyFont(size: 12))
                                .foregroundColor(Theme.textSecondary)
                            
                            Spacer()
                            
                            let level = gameState.stats.getRelationshipLevel(with: character)
                            let risk = gameState.stats.getBetrayalRisk(with: character)
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Trust: \(level)")
                                    .font(Theme.bodyFont(size: 10))
                                    .foregroundColor(level > 0 ? .green : level < 0 ? .red : .gray)
                                
                                if risk > 0 {
                                    Text("Risk: \(risk)")
                                        .font(Theme.bodyFont(size: 10))
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
                
                // Faction Loyalty
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    RelationshipStatView(
                        title: "KAI LOYALTY",
                        value: gameState.stats.kaiLoyalty,
                        icon: "person.3.fill",
                        color: .blue
                    )
                    
                    RelationshipStatView(
                        title: "NAYA TRUST",
                        value: gameState.stats.nayaTrust,
                        icon: "person.2.fill",
                        color: .green
                    )
                    
                    RelationshipStatView(
                        title: "ANCIENT ONE FAVOR",
                        value: gameState.stats.ancientOneFavor,
                        icon: "sparkles",
                        color: .purple
                    )
                    
                    RelationshipStatView(
                        title: "CULT INFLUENCE",
                        value: gameState.stats.cultInfluence,
                        icon: "eye.fill",
                        color: .red
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StoryStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let isNegative: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(isNegative ? value : abs(value))")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(value > 0 ? color : .gray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ProgressStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(value)")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct RelationshipStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(value)")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stat Bar View

struct StatBarView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let statType: StatType
    let icon: String
    let color: Color
    let pulse: Bool
    
    @State private var animateBar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                
                Text(title)
                    .font(Theme.subtitleFont(size: 14).weight(.medium))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(value)/\(maxValue)")
                    .font(Theme.subtitleFont(size: 12).weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateBar ? geometry.size.width * CGFloat(value) / CGFloat(maxValue) : 0, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: animateBar)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                animateBar = true
            }
        }
    }
}

// MARK: - Secondary Stat View

struct SecondaryStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(value)")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Enhanced Stat Bar View

struct EnhancedStatBarView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let statType: StatType
    let icon: String
    let color: Color
    let pulse: Bool
    
    @State private var animateBar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                
                Text(title)
                    .font(Theme.subtitleFont(size: 14).weight(.medium))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(value)/\(maxValue)")
                    .font(Theme.subtitleFont(size: 12).weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateBar ? geometry.size.width * CGFloat(value) / CGFloat(maxValue) : 0, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: animateBar)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                animateBar = true
            }
        }
    }
}

// MARK: - Enhanced Secondary Stat View

struct EnhancedSecondaryStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(value)")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Enhanced Story Stat View

struct EnhancedStoryStatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let isNegative: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .medium))
            
            Text(title)
                .font(Theme.subtitleFont(size: 10).weight(.semibold))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(isNegative ? value : abs(value))")
                .font(Theme.subtitleFont(size: 16).weight(.bold))
                .foregroundColor(value > 0 ? color : .gray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stat Tooltip View

struct StatTooltipView: View {
    let statType: StatType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: getStatIcon(statType))
                    .foregroundColor(getStatColor(statType))
                    .font(.system(size: 24, weight: .semibold))
                
                Text(getStatTitle(statType))
                    .font(Theme.titleFont(size: 24).weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textSecondary)
                        .font(.system(size: 24))
                }
            }
            
            // Description
            Text(getStatDescription(statType))
                .font(Theme.bodyFont(size: 16))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(24)
        .background(Theme.darkGradient)
        .presentationDetents([.medium])
    }
    
    // MARK: - Helper Methods
    
    private func getStatIcon(_ statType: StatType) -> String {
        switch statType {
        case .health: return "heart.fill"
        case .magic: return "sparkles"
        case .energy: return "bolt.fill"
        case .strength: return "figure.strengthtraining.traditional"
        case .intelligence: return "brain.head.profile"
        case .charisma: return "person.2.fill"
        case .sanity: return "eye.fill"
        default: return "chart.bar.fill"
        }
    }
    
    private func getStatColor(_ statType: StatType) -> Color {
        switch statType {
        case .health: return Theme.healthColor
        case .magic: return Theme.magicColor
        case .energy: return Theme.energyColor
        case .strength: return Theme.strengthColor
        case .intelligence: return Theme.intelligenceColor
        case .charisma: return Theme.charismaColor
        case .sanity: return Theme.sanityColor
        default: return Theme.textPrimary
        }
    }
    
    private func getStatTitle(_ statType: StatType) -> String {
        switch statType {
        case .health: return "HEALTH"
        case .magic: return "MAGIC"
        case .energy: return "ENERGY"
        case .strength: return "STRENGTH"
        case .intelligence: return "INTELLIGENCE"
        case .charisma: return "CHARISMA"
        case .sanity: return "SANITY"
        default: return statType.description.uppercased()
        }
    }
    
    private func getStatDescription(_ statType: StatType) -> String {
        switch statType {
        case .health: return "Physical well-being. Affects your ability to survive and recover from damage."
        case .magic: return "Magical power and affinity. Required for casting spells and using magical abilities."
        case .energy: return "Physical and mental stamina. Affects your ability to perform actions and maintain focus."
        case .strength: return "Physical power and combat effectiveness. Influences damage dealt and carrying capacity."
        case .intelligence: return "Mental acuity and problem-solving ability. Affects spell effectiveness and dialogue options."
        case .charisma: return "Social influence and persuasion. Helps in negotiations and relationship building."
        case .sanity: return "Mental stability and resistance to corruption. Critical for maintaining your sense of reality."
        default: return "A fundamental attribute that affects various aspects of your character's capabilities."
        }
    }
    
    private func getStatValue(_ statType: StatType) -> Int {
        // This would need to be passed from the parent view or accessed via environment
        return 50 // Placeholder
    }
    
    private func isStatLow(_ statType: StatType) -> Bool {
        let value = getStatValue(statType)
        switch statType {
        case .health, .magic, .energy:
            return value < 20
        default:
            return value < 30
        }
    }
}

// MARK: - Preview

#Preview {
    StatsView(gameState: GameState(), currentStage: 1)
        .background(Theme.darkGradient)
} 
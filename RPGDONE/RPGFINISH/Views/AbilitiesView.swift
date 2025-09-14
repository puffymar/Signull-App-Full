import SwiftUI

struct AbilitiesView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var abilityManager = AbilityManager.shared
    
    @State private var selectedTier: AbilityTier = .divine
    @State private var showAbilityDetails = false
    @State private var selectedAbility: Ability?
    @State private var shimmerOffset: CGFloat = -200
    @State private var animateAbilities = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.black.opacity(0.95),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Tier Selector
                        tierSelectorSection
                        
                        // Abilities Grid
                        abilitiesGridSection
                        
                        // Unlock Button
                        unlockButtonSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Abilities")
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
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showAbilityDetails) {
            if let ability = selectedAbility {
                AbilityDetailView(ability: ability)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("ABILITIES")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan, .white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .cyan.opacity(0.6), radius: 8, x: 0, y: 0)
                .opacity(animateAbilities ? 1.0 : 0.0)
                .offset(y: animateAbilities ? 0 : 20)
            
            Text("Unlock powerful abilities through your journey")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .opacity(animateAbilities ? 1.0 : 0.0)
                .offset(y: animateAbilities ? 0 : 20)
        }
    }
    
    // MARK: - Tier Selector Section
    private var tierSelectorSection: some View {
        VStack(spacing: 16) {
            Text("TIER SELECTION")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .opacity(animateAbilities ? 1.0 : 0.0)
                .offset(y: animateAbilities ? 0 : 20)
            
            HStack(spacing: 8) {
                ForEach(AbilityTier.allCases, id: \.self) { tier in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTier = tier
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(tier.rawValue)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(selectedTier == tier ? .white : .gray)
                            
                            Text("\(tier.dropChance)%")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(selectedTier == tier ? .cyan : .gray.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTier == tier ? Color.cyan.opacity(0.2) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedTier == tier ? Color.cyan.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .opacity(animateAbilities ? 1.0 : 0.0)
            .offset(y: animateAbilities ? 0 : 20)
        }
    }
    
    // MARK: - Abilities Grid Section
    private var abilitiesGridSection: some View {
        VStack(spacing: 16) {
            Text("\(selectedTier.rawValue) TIER ABILITIES")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .opacity(animateAbilities ? 1.0 : 0.0)
                .offset(y: animateAbilities ? 0 : 20)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(getAbilitiesForTier(selectedTier), id: \.id) { ability in
                    AbilityCardView(
                        ability: ability,
                        isUnlocked: abilityManager.hasAbility(ability.type),
                        shimmerOffset: shimmerOffset
                    ) {
                        selectedAbility = ability
                        showAbilityDetails = true
                    }
                }
            }
            .opacity(animateAbilities ? 1.0 : 0.0)
            .offset(y: animateAbilities ? 0 : 20)
        }
    }
    
    // MARK: - Unlock Button Section
    private var unlockButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await HapticManager.shared.impact(.medium)
                }
                if let newAbility = abilityManager.assignRandomAbility() {
                    print("🎯 New ability unlocked: \(newAbility.displayName)")
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("UNLOCK RANDOM ABILITY")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                        )
                )
                .shadow(color: Color.cyan.opacity(0.3), radius: 8)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(animateAbilities ? 1.0 : 0.0)
            .offset(y: animateAbilities ? 0 : 20)
            
            Text("Unlocked: \(abilityManager.unlockedAbilities.count)/\(AbilityType.allCases.count)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .opacity(animateAbilities ? 1.0 : 0.0)
                .offset(y: animateAbilities ? 0 : 20)
        }
    }
    
    // MARK: - Helper Methods
    private func getAbilitiesForTier(_ tier: AbilityTier) -> [Ability] {
        return AbilityType.allCases
            .filter { $0.tier == tier }
            .map { Ability(type: $0) }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8)) {
            animateAbilities = true
        }
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Ability Card View
struct AbilityCardView: View {
    let ability: Ability
    let isUnlocked: Bool
    let shimmerOffset: CGFloat
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon with tier color
                ZStack {
                    Circle()
                        .fill(getTierColor(ability.tier).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: ability.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(getTierColor(ability.tier))
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                
                // Title
                Text(ability.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Tier badge
                Text(ability.tier.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(getTierColor(ability.tier))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(getTierColor(ability.tier).opacity(0.2))
                    )
                
                // Unlock status
                if isUnlocked {
                    Text("UNLOCKED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green.opacity(0.2))
                        )
                } else {
                    Text("LOCKED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isUnlocked ? getTierColor(ability.tier).opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .overlay(
                // Shimmer effect for unlocked abilities
                Group {
                    if isUnlocked {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        getTierColor(ability.tier).opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: shimmerOffset)
                            .blendMode(.screen)
                            .clipped()
                    }
                }
            )
            .shadow(
                color: isUnlocked ? getTierColor(ability.tier).opacity(0.3) : Color.clear,
                radius: isUnlocked ? 6 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func getTierColor(_ tier: AbilityTier) -> Color {
        switch tier {
        case .divine: return .yellow
        case .legendary: return .purple
        case .rare: return .blue
        case .uncommon: return .green
        case .common: return .gray
        }
    }
}

// MARK: - Ability Detail View
struct AbilityDetailView: View {
    let ability: Ability
    @Environment(\.dismiss) private var dismiss
    @StateObject private var abilityManager = AbilityManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(getTierColor(ability.tier).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: ability.icon)
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(getTierColor(ability.tier))
                        }
                        
                        VStack(spacing: 8) {
                            Text(ability.displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(ability.tier.rawValue) Tier")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(getTierColor(ability.tier))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(getTierColor(ability.tier).opacity(0.2))
                                )
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DESCRIPTION")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(ability.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Stat Bonuses
                    if !ability.statBonuses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STAT BONUSES")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(Array(ability.statBonuses.keys.sorted()), id: \.self) { stat in
                                    HStack {
                                        Text(stat.capitalized)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("+\(ability.statBonuses[stat] ?? 0)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.cyan)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black.opacity(0.3))
                                    )
                                }
                            }
                        }
                    }
                    
                    // Story Triggers
                    if !ability.storyTriggers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STORY TRIGGERS")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(ability.storyTriggers, id: \.self) { trigger in
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.cyan)
                                        
                                        Text(trigger.replacingOccurrences(of: "_", with: " ").capitalized)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Unlock Status
                    VStack(spacing: 12) {
                        if abilityManager.hasAbility(ability.type) {
                            Text("UNLOCKED")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.2))
                                )
                        } else {
                            Text("LOCKED")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
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
            .navigationTitle("Ability Details")
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
    
    private func getTierColor(_ tier: AbilityTier) -> Color {
        switch tier {
        case .divine: return .yellow
        case .legendary: return .purple
        case .rare: return .blue
        case .uncommon: return .green
        case .common: return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    AbilitiesView()
        .environmentObject(GameState())
} 
import SwiftUI

struct CombatView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedAction: CombatAction?
    @State private var showingActionDetails = false
    @State private var combatLog: [CombatLogEntry] = []
    @State private var animationIntensity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Atmospheric combat background
            CombatBackgroundView(
                encounter: gameState.currentCombat,
                intensity: animationIntensity
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Combat header
                CombatHeaderView(gameState: gameState)
                
                Spacer()
                
                // Combat log
                CombatLogView(log: combatLog)
                    .frame(height: 120)
                
                // Enemy status
                EnemyStatusView(
                    enemy: gameState.currentCombat?.enemies.first,
                    health: gameState.enemyHealth
                )
                
                // Player status
                PlayerStatusView(gameState: gameState)
                
                // Action buttons
                CombatActionView(
                    gameState: gameState,
                    selectedAction: $selectedAction,
                    onActionSelected: performAction
                )
                
                // Environmental interactions
                // if !(gameState.currentCombat?.environment.interactables.isEmpty ?? true) {
                //     EnvironmentalInteractionView(
                //         gameState: gameState,
                //         interactables: gameState.currentCombat?.environment.interactables ?? []
                //     )
                // }
            }
            .padding()
        }
        .onAppear {
            startCombatAnimation()
        }
        .sheet(isPresented: $showingActionDetails) {
            if let action = selectedAction {
                ActionDetailView(action: action)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Combat encounter")
    }
    
    private func startCombatAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animationIntensity = 1.0
        }
    }
    
    private func performAction(_ action: CombatAction) {
        let result = gameState.performCombatAction(action)
        
        // Add to combat log
        let logEntry = CombatLogEntry(
            turn: gameState.combatTurn,
            message: "You used \(action.name)",
            type: .playerAction
        )
        combatLog.append(logEntry)
        
        // Handle result
        switch result {
        case .victory:
            handleVictory()
        case .defeat:
            handleDefeat()
        case .continue:
            // Continue combat
            break
        case .fled:
            handleFlee()
        }
    }
    
    private func handleVictory() {
        let victoryEntry = CombatLogEntry(
            turn: gameState.combatTurn,
            message: "Victory! You defeated the enemy",
            type: .victory
        )
        combatLog.append(victoryEntry)
        
        // Auto-advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            gameState.currentCombat = nil
            gameState.combatState = .none
        }
    }
    
    private func handleDefeat() {
        let defeatEntry = CombatLogEntry(
            turn: gameState.combatTurn,
            message: "Defeat! You have been overcome",
            type: .defeat
        )
        combatLog.append(defeatEntry)
        
        // Auto-advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            gameState.currentCombat = nil
            gameState.combatState = .none
        }
    }
    
    private func handleFlee() {
        let fleeEntry = CombatLogEntry(
            turn: gameState.combatTurn,
            message: "You fled from combat",
            type: .environmental
        )
        combatLog.append(fleeEntry)
        
        // Auto-advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            gameState.currentCombat = nil
            gameState.combatState = .fled
        }
    }
}

// MARK: - Combat Background
struct CombatBackgroundView: View {
    let encounter: CombatEncounter?
    let intensity: Double
    
    var body: some View {
        ZStack {
            // Base background
            Color.black
            
            // Environmental effects
            if let environment = encounter?.environment {
                ForEach(environment.hazards, id: \.id) { hazard in
                    HazardEffectView(hazard: hazard, intensity: intensity)
                }
                
                ForEach(environment.advantages, id: \.id) { advantage in
                    AdvantageEffectView(advantage: advantage, intensity: intensity)
                }
            }
            
            // Combat particles
            CombatParticleView(intensity: intensity)
        }
    }
}

struct HazardEffectView: View {
    let hazard: EnvironmentalHazard
    let intensity: Double
    
    var body: some View {
        switch hazard.trigger {
        case .turnStart, .turnEnd:
            Circle()
                .fill(Color.red.opacity(0.3 * intensity))
                .scaleEffect(1.0 + (intensity * 0.2))
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: intensity)
        case .movement, .action, .random:
            Circle()
                .fill(Color.orange.opacity(0.2 * intensity))
                .scaleEffect(1.0 + (intensity * 0.15))
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: intensity)
        }
    }
}

struct AdvantageEffectView: View {
    let advantage: EnvironmentalAdvantage
    let intensity: Double
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.2 * intensity))
            .scaleEffect(1.0 + (intensity * 0.1))
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: intensity)
    }
}

struct CombatParticleView: View {
    let intensity: Double
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true),
                        value: intensity
                    )
            }
        }
    }
}

// MARK: - Combat Header
struct CombatHeaderView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        HStack {
            Text("Turn \(gameState.combatTurn)")
                .font(Theme.terminalFont(size: 16))
                .foregroundColor(Theme.terminalGreen)
            
            Spacer()
            
            Text("Combat")
                .font(Theme.terminalFont(size: 18))
                .foregroundColor(.red)
            
            Spacer()
            
            Button("Flee") {
                gameState.combatState = .fled
            }
            .font(Theme.terminalFont(size: 14))
            .foregroundColor(.yellow)
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Combat Log
struct CombatLogView: View {
    let log: [CombatLogEntry]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(log, id: \.id) { entry in
                    Text(entry.message)
                        .font(Theme.terminalFont(size: 12))
                        .foregroundColor(entry.type.color)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}

struct CombatLogEntry: Identifiable {
    let id = UUID()
    let turn: Int
    let message: String
    let type: LogEntryType
}

enum LogEntryType {
    case playerAction, enemyAction, victory, defeat, environmental
    
    var color: Color {
        switch self {
        case .playerAction: return .green
        case .enemyAction: return .red
        case .victory: return .yellow
        case .defeat: return .red
        case .environmental: return .cyan
        }
    }
}

// MARK: - Enemy Status
struct EnemyStatusView: View {
    let enemy: Enemy?
    let health: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(enemy?.name ?? "Enemy")
                .font(Theme.terminalFont(size: 18))
                .foregroundColor(.red)
            
            // Health bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: geometry.size.width * healthPercentage, height: 20)
                        .animation(.easeInOut(duration: 0.5), value: health)
                }
            }
            .frame(height: 20)
            .cornerRadius(10)
            
            Text("\(health)/\(enemy?.maxHealth ?? 100)")
                .font(Theme.terminalFont(size: 12))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
    
    private var healthPercentage: Double {
        guard let enemy = enemy else { return 0.0 }
        return Double(health) / Double(enemy.maxHealth)
    }
}

// MARK: - Player Status
struct PlayerStatusView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        HStack(spacing: 20) {
            // Health
            VStack {
                Text("Health")
                    .font(Theme.terminalFont(size: 12))
                    .foregroundColor(.white)
                
                Text("\(gameState.stats.health)")
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.green)
            }
            
            // Magic
            VStack {
                Text("Magic")
                    .font(Theme.terminalFont(size: 12))
                    .foregroundColor(.white)
                
                Text("\(gameState.stats.magic)")
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.blue)
            }
            
            // Sanity
            VStack {
                Text("Sanity")
                    .font(Theme.terminalFont(size: 12))
                    .foregroundColor(.white)
                
                Text("\(gameState.stats.sanity)")
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
}

// MARK: - Combat Actions
struct CombatActionView: View {
    @ObservedObject var gameState: GameState
    @Binding var selectedAction: CombatAction?
    let onActionSelected: (CombatAction) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(gameState.availableActions, id: \.id) { action in
                // CombatActionButton(
                //     action: action,
                //     gameState: gameState,
                //     onTap: {
                //         selectedAction = action
                //         onActionSelected(action)
                //     }
                // )
                Text(action.name) // Placeholder for CombatActionButton
                    .font(Theme.terminalFont(size: 14))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedAction = action
                        onActionSelected(action)
                    }
            }
        }
        .padding()
    }
}





// MARK: - Action Detail View
struct ActionDetailView: View {
    let action: CombatAction
    
    var body: some View {
        VStack(spacing: 16) {
            Text(action.name)
                .font(Theme.terminalFont(size: 20))
                .foregroundColor(.white)
            
            Text(action.description)
                .font(Theme.terminalFont(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Damage")
                        .font(Theme.terminalFont(size: 12))
                        .foregroundColor(.white)
                    Text("\(action.damage)")
                        .font(Theme.terminalFont(size: 16))
                        .foregroundColor(.red)
                }
                
                VStack {
                    Text("Cost")
                        .font(Theme.terminalFont(size: 12))
                        .foregroundColor(.white)
                    Text("\(action.cost)")
                        .font(Theme.terminalFont(size: 16))
                        .foregroundColor(.blue)
                }
            }
            
            if !action.effects.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effects:")
                        .font(Theme.terminalFont(size: 14))
                        .foregroundColor(.white)
                    
                    ForEach(action.effects, id: \.self) { effect in
                        Text(effectDescription(effect))
                            .font(Theme.terminalFont(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
    }
    
    private func effectDescription(_ effect: StoryEffect) -> String {
        switch effect {
        case .health(let value):
            return "Health: \(value > 0 ? "+" : "")\(value)"
        case .energy(let value):
            return "Energy: \(value > 0 ? "+" : "")\(value)"
        case .charisma(let value):
            return "Charisma: \(value > 0 ? "+" : "")\(value)"
        case .money(let value):
            return "Money: \(value > 0 ? "+" : "")\(value)"
        case .morality(let value):
            return "Morality: \(value > 0 ? "+" : "")\(value)"
        case .hunger(let value):
            return "Hunger: \(value > 0 ? "+" : "")\(value)"
        case .sanity(let value):
            return "Sanity: \(value > 0 ? "+" : "")\(value)"
        case .strength(let value):
            return "Strength: \(value > 0 ? "+" : "")\(value)"
        case .finalChoice:
            return "Final Choice Trigger"
        }
    }
} 

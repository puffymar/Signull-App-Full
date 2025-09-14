import SwiftUI

// MARK: - Terminal Scanlines
struct TerminalScanlines: View {
    @State private var animationPhase: Double = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let lineHeight: CGFloat = 2
                let lineSpacing: CGFloat = 4
                
                for y in stride(from: 0, through: size.height, by: lineSpacing) {
                    let opacity = 0.1 + 0.05 * sin(animationPhase + y * 0.01)
                    let path = Path(CGRect(x: 0, y: y, width: size.width, height: lineHeight))
                    context.fill(path, with: .color(Color.green.opacity(opacity)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
    }
}

struct CharacterCreationView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var audioManager = AudioManager.shared
    @State private var playerName = ""
    @State private var selectedGender: Gender = .man
    @State private var showingStats = false
    @State private var showingConfirmation = false
    @State private var nameError = ""
    
    var body: some View {
        ZStack {
            // Terminal background
            Color.black
                .ignoresSafeArea()
            
            // Terminal scanlines overlay
            TerminalScanlines()
                .opacity(0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                VStack(spacing: 30) {
                    // Title with enhanced animation
                    Text("IDENTITY INITIALIZATION")
                        .font(.custom("SF Pro Display", size: 28).weight(.bold))
                        .foregroundColor(Color.green)
                        .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
                        .shadow(color: Color.green.opacity(0.3), radius: 16, x: 0, y: 0)
                    
                    // Name Input with validation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ENTER SUBJECT NAME:")
                            .font(.custom("SF Pro Text", size: 16).weight(.medium))
                            .foregroundColor(Color.green.opacity(0.9))
                            .shadow(color: Color.green.opacity(0.4), radius: 2, x: 0, y: 0)
                        
                        TextField("Enter your name", text: $playerName)
                            .font(.custom("SF Pro Text", size: 18).weight(.medium))
                            .foregroundColor(Color.green)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(nameError.isEmpty ? Color.green.opacity(0.8) : .red, lineWidth: 1.5)
                            )
                            .cornerRadius(8)
                            .shadow(color: Color.green.opacity(0.3), radius: 3, x: 0, y: 0)
                            .onChange(of: playerName) { _, newValue in
                                validateName(newValue)
                            }
                        
                        if !nameError.isEmpty {
                            Text(nameError)
                                .font(.custom("SF Pro Text", size: 12).weight(.medium))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.4), radius: 1, x: 0, y: 0)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SELECT ESSENCE TYPE:")
                            .font(.custom("SF Pro Text", size: 16).weight(.medium))
                            .foregroundColor(Color.green.opacity(0.9))
                            .shadow(color: Color.green.opacity(0.4), radius: 2, x: 0, y: 0)
                        
                        HStack(spacing: 20) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Button(action: {
                                    HapticManager.shared.impact(.light)
                                    selectedGender = gender
                                }) {
                                    Text(gender.rawValue)
                                        .font(.custom("SF Pro Text", size: 16).weight(.medium))
                                        .foregroundColor(selectedGender == gender ? Color.green : .gray)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedGender == gender ? Color.green.opacity(0.2) : Color.black.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedGender == gender ? Color.green : Color.gray, lineWidth: 1.5)
                                        )
                                        .shadow(color: selectedGender == gender ? Color.green.opacity(0.3) : Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Show generated traits (read-only) - only after name is entered
                    if !playerName.isEmpty && !gameState.stats.traits.isEmpty && nameError.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GENERATED TRAITS")
                                .font(.custom("SF Pro Text", size: 16).weight(.medium))
                                .foregroundColor(Color.green)
                                .shadow(color: Color.green.opacity(0.4), radius: 2, x: 0, y: 0)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(gameState.stats.traits, id: \.name) { trait in
                                    Text("• \(trait.name)")
                                        .font(.custom("SF Pro Text", size: 14).weight(.medium))
                                        .foregroundColor(Color.green.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    Spacer().frame(height: 30)
                    
                    // Continue Button
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        if isValidName(playerName) {
                            showingConfirmation = true
                        } else {
                            HapticManager.shared.notification(.error)
                        }
                    }) {
                        Text("Confirm")
                            .font(.custom("SF Pro Display", size: 16).weight(.bold))
                            .foregroundColor(isValidName(playerName) ? Color.green : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isValidName(playerName) ? Color.green.opacity(0.15) : Color.black.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isValidName(playerName) ? Color.green : .gray, lineWidth: 1)
                            )
                            .shadow(color: isValidName(playerName) ? Color.green.opacity(0.2) : Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
                    }
                    .disabled(!isValidName(playerName))
                    .padding(.horizontal, 40)
                    
                    // SKIP Button for testing
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        ContentManager.shared.clearChapterCache()
                        playerName = "TestSubject"
                        gameState.stats.playerName = playerName
                        gameState.stats.traits = []
                        gameState.hasCompletedTutorial = true
                        gameState.currentChapter = 1
                        gameState.hasStartedGame = true
                        gameState.showingCharacterCreation = false
                        SaveManager.shared.saveGame(stats: gameState.stats, gameState: gameState)
                        print("[DEBUG] SKIP button used: hasStartedGame=\(gameState.hasStartedGame), showingCharacterCreation=\(gameState.showingCharacterCreation), currentChapter=\(gameState.currentChapter)")
                    }) {
                        Text("SKIP")
                            .font(.custom("SF Pro Text", size: 16).weight(.medium))
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.yellow, lineWidth: 1.5)
                            )
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer().frame(height: 80)
            }
        }
        .alert("Confirm Character", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {
                showingConfirmation = false
            }
            Button("Confirm") {
                confirmCharacter()
            }
        } message: {
            Text("Are you sure you want to create a character named '\(playerName)'? This cannot be changed later.")
        }

    }
    
    private func validateName(_ name: String) {
        if name.isEmpty {
            nameError = ""
            return
        }
        
        // Check for numbers
        if name.rangeOfCharacter(from: .decimalDigits) != nil {
            nameError = "Name cannot contain numbers"
            return
        }
        
        // Check for symbols (except letters and spaces)
        let allowedCharacters = CharacterSet.letters.union(.whitespaces)
        if name.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            nameError = "Name can only contain letters"
            return
        }
        
        // Check for spaces
        if name.contains(" ") {
            nameError = "Name cannot contain spaces"
            return
        }
        
        nameError = ""
    }
    
    private func isValidName(_ name: String) -> Bool {
        return !name.isEmpty && nameError.isEmpty
    }
    
    private func confirmCharacter() {
        // Set character data
        ContentManager.shared.clearChapterCache()
        gameState.stats.playerName = playerName
        gameState.hasCompletedTutorial = true
        Task {
            HapticManager.shared.notification(.success)
        }
        print("Character created: \(playerName), Tutorial complete: \(gameState.hasCompletedTutorial)")
        SaveManager.shared.saveGame(stats: gameState.stats, gameState: gameState)
        gameState.currentChapter = 1
        gameState.hasStartedGame = true
        gameState.showingCharacterCreation = false
        print("[DEBUG] PATCHED confirmCharacter: hasStartedGame=\(gameState.hasStartedGame), showingCharacterCreation=\(gameState.showingCharacterCreation), currentChapter=\(gameState.currentChapter)")
    }
} 
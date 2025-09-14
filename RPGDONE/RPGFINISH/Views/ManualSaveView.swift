import SwiftUI

struct ManualSaveView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @State private var manualSaves: [SaveData] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("MANUAL SAVES")
                    .font(Theme.terminalFont(size: 28))
                    .foregroundColor(Theme.terminalGreen)
                    .padding(.top, 20)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.terminalGreen))
                        .scaleEffect(1.5)
                    Spacer()
                } else if manualSaves.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Text("NO SAVES FOUND")
                            .font(Theme.terminalFont(size: 20))
                            .foregroundColor(.gray)
                        
                        Text("Create a new game to start your journey")
                            .font(Theme.terminalFont(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    // Save list
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(manualSaves, id: \.saveDate) { save in
                                SaveItemView(save: save) {
                                    Task {
                                        await HapticManager.shared.impact(.medium)
                                    }
                                    loadSave(save)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Close button
                Button(action: {
                    Task {
                        await HapticManager.shared.impact(.light)
                    }
                    dismiss()
                }) {
                    Text("CLOSE")
                        .font(Theme.terminalFont(size: 18))
                        .foregroundColor(Theme.accentBeige)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Rectangle().stroke(Theme.accentBeige, lineWidth: 2))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadManualSaves()
        }
    }
    
    private func loadManualSaves() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let saves = SaveManager.shared.loadManualSaves()
            DispatchQueue.main.async {
                self.manualSaves = saves
                self.isLoading = false
            }
        }
    }
    
    private func loadSave(_ save: SaveData) {
        gameState.loadGameFromSaveData(save)
        dismiss()
    }
}

struct SaveItemView: View {
    let save: SaveData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(save.playerStats.playerName.isEmpty ? "Unknown Player" : save.playerStats.playerName)
                        .font(Theme.terminalFont(size: 18))
                        .foregroundColor(Theme.terminalGreen)
                    
                    Spacer()
                    
                    Text(formatDate(save.saveDate))
                        .font(Theme.terminalFont(size: 12))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Day \(save.dayCount)")
                        .font(Theme.terminalFont(size: 14))
                        .foregroundColor(Theme.accentBeige)
                    
                    Spacer()
                    
                    if !save.abilities.isEmpty {
                        Text("\(save.abilities.count) Ability\(save.abilities.count == 1 ? "" : "ies")")
                            .font(Theme.terminalFont(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .overlay(Rectangle().stroke(Theme.terminalGreen.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 
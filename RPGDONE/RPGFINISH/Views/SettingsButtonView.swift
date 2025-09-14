import SwiftUI

struct SettingsButtonView: View {
    @ObservedObject var gameState: GameState
    @State private var showingSettings = false
    
    var body: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(Theme.terminalGreen)
                .padding(10)
                .background(Theme.darkBackground.opacity(0.7))
                .overlay(Rectangle().stroke(Theme.terminalGreen.opacity(0.4), lineWidth: 1))
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
} 
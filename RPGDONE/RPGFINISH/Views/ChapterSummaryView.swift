import SwiftUI

struct ChapterSummaryView: View {
    @ObservedObject var gameState: GameState
    @State private var showingSummary = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("CHAPTER \(gameState.currentChapter - 1) COMPLETE")
                    .font(Theme.terminalFont(size: 28))
                    .foregroundColor(Theme.terminalGreen)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    // Stats Summary
                    VStack(alignment: .leading, spacing: 15) {
                        Text("STATS SUMMARY")
                            .font(Theme.terminalFont(size: 18))
                            .foregroundColor(Theme.terminalGreen)
                        
                        HStack {
                            Text("Health:")
                            Spacer()
                            Text("\(gameState.stats.health)")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Energy:")
                            Spacer()
                            Text("\(gameState.stats.energy)")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Sanity:")
                            Spacer()
                            Text("\(gameState.stats.sanity)")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Money:")
                            Spacer()
                            Text("$\(String(format: "%.2f", gameState.stats.money))")
                                .foregroundColor(.white)
                        }
                    }
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Theme.darkBackground.opacity(0.5))
                    .overlay(Rectangle().stroke(Theme.terminalGreen.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    showingSummary = false
                }) {
                    Text("CONTINUE TO CHAPTER \(gameState.currentChapter)")
                        .font(Theme.terminalFont(size: 20))
                        .foregroundColor(Theme.terminalGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Rectangle().stroke(Theme.terminalGreen, lineWidth: 2))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            showingSummary = true
        }
    }
} 
//
//  ContentView.swift
//  RPGFINISH
//
//  Created by Marriatii on 7/7/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        Group {
            if !gameState.showingMainMenu && !gameState.showingCharacterCreation && !gameState.showingNewGameInit && !gameState.showingAIStories && !gameState.showingStoryView && !(gameState.hasStartedGame && gameState.currentChapter > 0) {
                IntroView()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: IntroView should be showing")
                        print("🔍 DEBUG: hasLaunchedBefore: \(hasLaunchedBefore)")
                    }
            } else if gameState.showingMainMenu {
                MainMenuView()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: MainMenuView should be showing")
                    }
            } else if gameState.showingNewGameInit {
                NewGameInitView()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: NewGameInitView should be showing")
                    }
            } else if gameState.showingCharacterCreation {
                CharacterCreationView(gameState: gameState)
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: CharacterCreationView should be showing")
                    }
            } else if gameState.showingAIStories {
                AIStoriesScreen()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: AIStoriesScreen should be showing")
                    }
            } else if gameState.showingStoryView {
                StoryView(initialStory: gameState.selectedStory?.fullStory ?? "Your story begins here...")
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: StoryView should be showing")
                    }
            } else if gameState.hasStartedGame && gameState.currentChapter > 0 {
                ChapterView()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: ChapterView should be showing")
                    }
            } else if gameState.showingDiscoverAIStories {
                DiscoverView()
                    .environmentObject(gameState)
                    .onAppear {
                        print("🔍 DEBUG: DiscoverView should be showing")
                    }
            }
        }
        .onAppear {
            print("🔍 DEBUG: ContentView appeared")
            print("🔍 DEBUG: State - showingMainMenu: \(gameState.showingMainMenu)")
            print("🔍 DEBUG: State - showingNewGameInit: \(gameState.showingNewGameInit)")
            print("🔍 DEBUG: State - showingCharacterCreation: \(gameState.showingCharacterCreation)")
            print("🔍 DEBUG: State - hasStartedGame: \(gameState.hasStartedGame)")
            print("🔍 DEBUG: State - currentChapter: \(gameState.currentChapter)")
            print("🔍 DEBUG: hasLaunchedBefore: \(hasLaunchedBefore)")
            
            // Set initial state to show main menu if this is not the first launch
            if hasLaunchedBefore {
                print("🔍 DEBUG: Setting showingMainMenu to true (not first launch)")
                gameState.showingMainMenu = true
            } else {
                print("🔍 DEBUG: First launch - will show IntroView")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showMainMenu)) { _ in
            print("🔍 DEBUG: Received showMainMenu notification")
            gameState.showingMainMenu = true
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let showMainMenu = Notification.Name("showMainMenu")
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}

//

import SwiftUI

public struct DialogueView: View {
    @ObservedObject var storyStats: StoryPlayerStats
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCharacter: String = "Stranger"
    @State private var showingDialogueOptions = false
    
    let availableCharacters = ["Stranger", "Teacher", "Faction Leader", "Ancient One"]
    
    public init(storyStats: StoryPlayerStats) {
        self.storyStats = storyStats
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Character selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(availableCharacters, id: \.self) { character in
                                Button(action: {
                                    selectedCharacter = character
                                    showingDialogueOptions = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: characterIcon(for: character))
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text(character)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("Trust: \(storyStats.relationshipLevels[character] ?? 0)")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCharacter == character ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 2)
                                            .background(Color.black.opacity(0.6))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Character info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Relationship with \(selectedCharacter)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Trust Level:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(storyStats.relationshipLevels[selectedCharacter] ?? 0)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        // Trust level indicator
                        ProgressView(value: Double(storyStats.relationshipLevels[selectedCharacter] ?? 0), total: 10)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            .frame(height: 6)
                        
                        // Character description
                        Text(characterDescription(for: selectedCharacter))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Dialogue history
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Dialogue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(storyStats.dialogueHistory.suffix(5), id: \.self) { dialogue in
                                    Text("• \(dialogue)")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Dialogue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .sheet(isPresented: $showingDialogueOptions) {
            DialogueOptionsView(storyStats: storyStats, character: selectedCharacter)
        }
    }
    
    private func characterIcon(for character: String) -> String {
        switch character {
        case "Stranger": return "person.fill"
        case "Teacher": return "book.fill"
        case "Faction Leader": return "crown.fill"
        case "Ancient One": return "sparkles"
        default: return "person.fill"
        }
    }
    
    private func characterDescription(for character: String) -> String {
        switch character {
        case "Stranger":
            return "A mysterious figure you encountered in the wasteland. Their true intentions remain unclear."
        case "Teacher":
            return "Your former mentor who taught you the ways of survival. Their memory guides your choices."
        case "Faction Leader":
            return "A powerful figure leading one of the surviving factions. Their influence extends far."
        case "Ancient One":
            return "An entity of immense power and knowledge. They speak in riddles and ancient wisdom."
        default:
            return "A character in your journey."
        }
    }
}

public struct DialogueOptionsView: View {
    @ObservedObject var storyStats: StoryPlayerStats
    let character: String
    @Environment(\.dismiss) private var dismiss
    
    public init(storyStats: StoryPlayerStats, character: String) {
        self.storyStats = storyStats
        self.character = character
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Speak with \(character)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(storyStats.getDialogueOptions(for: character, context: "general"), id: \.id) { option in
                                Button(action: {
                                    storyStats.selectDialogueOption(option)
                                    dismiss()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(option.text)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                            
                                            if let moralityReq = option.moralityRequirement {
                                                Text("Requires: \(moralityReq.rawValue)")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        
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
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Dialogue Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
} 
import SwiftUI

// MARK: - Clean Story Renderer (No NaN, No One-Block Wall)
struct StoryRenderer: View {
    let story: Story
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Title and Genre
                Text(story.title)
                    .font(.title)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(story.genre.capitalized + " • " + story.tags.joined(separator: " • "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // World Section
                Group {
                    SectionHeader("World")
                    Text(story.world.premise)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(story.world.history)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Synopsis
                SectionHeader("Synopsis")
                Text(story.story.synopsis)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Story Beats
                SectionHeader("Story")
                ForEach(story.story.beats.indices, id: \.self) { i in
                    Text("• " + story.story.beats[i])
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 6)
                }
                
                // Player Action Hook
                SectionHeader("Your Move")
                Text(story.player_in)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Choices
                SectionHeader("Choices")
                ForEach(story.choices.indices, id: \.self) { i in
                    ChoiceRow(
                        label: story.choices[i].label,
                        hint: story.choices[i].hint
                    )
                }
            }
            .padding()
        }
        .lineSpacing(4)
        .textSelection(.enabled)
    }
}

// MARK: - Helper Views
struct SectionHeader: View {
    let title: String
    init(_ t: String) { self.title = t }
    
    var body: some View {
        Text(title.uppercased())
            .font(.caption)
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}

struct ChoiceRow: View {
    let label: String
    let hint: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right.circle.fill")
                .foregroundColor(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .bold()
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Fallback Renderer for Parse Failures
struct FallbackStoryRenderer: View {
    let rawText: String
    let onRegenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Raw Response")
                .font(.headline)
                .foregroundColor(.orange)
            
            ScrollView {
                Text(rawText)
                    .font(.system(.body, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Button("Reformat as JSON") {
                onRegenerate()
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding()
    }
}

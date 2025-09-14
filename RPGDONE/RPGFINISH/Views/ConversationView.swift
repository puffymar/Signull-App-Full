import SwiftUI

struct ConversationView: View {
    @ObservedObject var vm: StoryVM
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.messages) { msg in
                        VStack(alignment: .leading, spacing: 10) {
                            if let scene = msg.scene {
                                SceneCard(scene: scene)
                            }
                            if let user = msg.userInput, !user.isEmpty {
                                Text("You: \(user)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .id(msg.id)
                    }
                    if vm.isThinking {
                        PonderingView().id("ponder")
                    }
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation(.easeOut) {
                    proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: vm.isThinking) { _ in
                withAnimation(.easeOut) {
                    proxy.scrollTo("ponder", anchor: .bottom)
                }
            }
        }
    }
}

// Placeholder for SceneCard - you'll need to implement this based on your existing StoryData display
struct SceneCard: View {
    let scene: StoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scene.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(scene.fullStory)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

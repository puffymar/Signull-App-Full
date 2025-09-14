// DEBUG scaffold view for local testing. Not used in release.
#if DEBUG
import SwiftUI

struct DevStoryViewScaffold: View {
    @StateObject private var vm = DevStoryVM()

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let npc = vm.npcLine { Text(npc) }
                    Text(vm.storyText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            if !vm.choices.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.choices) { c in
                            Button { vm.choose(c) } label: {
                                VStack(spacing: 2) {
                                    Text(labelFor(c.type)).font(.caption.bold())
                                    Text(c.label).font(.footnote).lineLimit(1)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.25))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            HStack {
                TextField("Enter your response…", text: $vm.input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.send)
                    .onSubmit { vm.submitTurn() }
                Button { vm.submitTurn() } label: { Image(systemName: "paperplane.fill") }
                    .disabled(vm.isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            if let err = vm.error { Text(err).font(.caption).foregroundStyle(.red).padding(.bottom, 6) }
        }
        .onAppear { if vm.storyText.isEmpty { vm.submitTurn() } }
    }

    private func labelFor(_ t: DevChoiceType) -> String {
        switch t {
        case .think: return "Think"
        case .act: return "Act"
        case .say: return "Say"
        case .intervene: return "Intervene"
        }
    }
}
#endif

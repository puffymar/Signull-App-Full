import SwiftUI

struct StoryScreen: View {
    let opening: OpeningResponse
    let onBack: () -> Void

    @State private var text: String = ""
    @State private var npcLine: String? = nil
    @State private var choices: [TurnChoice] = []
    @State private var input: String = ""
    @State private var isLoading = false
    @State private var error: String? = nil

    @StateObject private var vm = DiscoverVM()

    var body: some View {
        VStack(spacing: 12) {
            TopBar(back: onBack, title: opening.title)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let npc = npcLine { Text(npc) }
                    Text(text).padding(.bottom, 8)
                }
                .foregroundStyle(.white)
                .padding(.horizontal)
            }

            if !choices.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(choices) { c in
                            Button {
                                input = mapped(c)
                                Task { await send() }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(uiLabel(c.type)).font(.caption.bold())
                                    Text(c.label).font(.footnote).lineLimit(1)
                                }
                                .padding(.vertical, 8).padding(.horizontal, 12)
                                .background(.white.opacity(0.08), in: Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            HStack {
                TextField("Enter your response…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await send() }
                } label: { Image(systemName: "paperplane.fill") }
                .disabled(isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            if let e = error { Text(e).font(.caption).foregroundStyle(.red).padding(.bottom, 6) }
        }
        .onAppear {
            text = opening.text
            choices = opening.choices
        }
    }

    private func uiLabel(_ t: ChoiceType) -> String {
        switch t { case .think: "Think"; case .act: "Act"; case .say: "Say"; case .intervene: "Intervene" }
    }
    private func mapped(_ c: TurnChoice) -> String {
        switch c.type {
        case .think: return "(THINK) \(c.label)"
        case .act: return "(ACT) \(c.label)"
        case .say: return "(SAY) \(c.label)"
        case .intervene: return "(INTERVENE) \(c.label)"
        }
    }
    private func send() async {
        guard !isLoading else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            let cont = try await vm.continueStory(with: input)
            text = cont.text
            choices = cont.choices
            input = ""
        } catch {
            self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
        }
    }
}



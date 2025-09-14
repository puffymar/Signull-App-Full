import SwiftUI

struct DiscoverView: View {
    @StateObject private var vm = DiscoverVM()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                switch vm.stage {
                case .loading:
                    CRTIntro(text: "CHOOSE YOUR JOURNEY")
                        .onAppear { vm.start() }

                case .genres:
                    VStack(spacing: 24) {
                        TopBar(back: nil, title: "AI STORIES")
                        GenreGrid(select: vm.pick)
                        DreamButton(action: {
                            if vm.selected == nil { vm.pick(.scp) }
                        })
                    }
                    .padding(.bottom, 24)
                    .overlay(BackArrow(visible: false))

                case .generated:
                    VStack(spacing: 12) {
                        TopBar(back: { vm.backToGenres() }, title: vm.selected?.title ?? "")
                        if vm.isLoading { ProgressView().tint(.white) }
                        if let err = vm.error { Text(err).foregroundColor(.red).font(.footnote) }
                        GeneratedRow(cards: vm.ideas) { card in
                            vm.openStory(from: card)
                        }
                        .padding(.top, 6)

                        if let op = vm.opening {
                            StoryScreen(opening: op, onBack: { vm.opening = nil })
                        } else {
                            Spacer()
                        }
                    }
                    .overlay(BackArrow(visible: true, action: vm.backToGenres))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TopBar: View {
    var back: (() -> Void)?
    let title: String
    var body: some View {
        HStack {
            if let back { Button(action: back) { Image(systemName: "arrow.backward") } }
            Spacer()
            Text(title)
                .font(.title3).tracking(2).foregroundStyle(.white.opacity(0.9))
            Spacer()
            Color.clear.frame(width: 28)
        }
        .padding(.horizontal)
    }
}

private struct BackArrow: View {
    var visible: Bool
    var action: (() -> Void)? = nil
    var body: some View {
        HStack {
            if visible {
                Button(action: { action?() }) {
                    Image(systemName: "arrow.backward")
                        .font(.headline)
                        .padding(10)
                        .background(.white.opacity(0.06), in: Circle())
                }
                .padding(.leading, 12)
                .padding(.top, 8)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

private struct CRTIntro: View {
    let text: String
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Text(text)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .kerning(2)
                .foregroundColor(.white.opacity(0.9))
                .padding(16)
                .opacity(0.96)
                .shadow(color: .cyan.opacity(0.25), radius: 8, x: 0, y: 0)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

private struct GenreGrid: View {
    let select: (Journey) -> Void
    @State private var current: Journey? = .scp

    let cols = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 18) {
            Text("Genres & Categories").font(.headline).foregroundColor(.white.opacity(0.8))
            LazyVGrid(columns: cols, spacing: 14) {
                ForEach(Journey.allCases) { j in
                    Button {
                        current = j
                        select(j)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(j.title).font(.subheadline.bold())
                            Text(j.tags.joined(separator: " •"))
                                .font(.caption2).opacity(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(j == current ? .white.opacity(0.13) : .white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .shadow(color: j == current ? .cyan.opacity(0.25) : .clear, radius: 8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct DreamButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                Text("Dream")
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 10).padding(.horizontal, 18)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.12)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08)))
        }
        .foregroundStyle(.white)
    }
}

private struct GeneratedRow: View {
    let cards: [IdeaCard]
    let open: (IdeaCard) -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(cards) { card in
                    Button {
                        open(card)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(card.hook)
                                .font(.footnote)
                                .opacity(0.9)
                                .lineLimit(3)
                        }
                        .frame(width: 270, height: 150, alignment: .topLeading)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.06)))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08)))
                        .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}



import SwiftUI

struct PonderingView: View {
    @State private var phase: CGFloat = 0
    private let text = "Grand Wizard is pondering"

    var body: some View {
        Text(text)
            .font(.callout.weight(.medium))
            .foregroundStyle(.secondary)
            .overlay {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.7), location: 0.5),
                    .init(color: .clear, location: 1),
                ], startPoint: .leading, endPoint: .trailing)
                .blendMode(.overlay)
                .mask(Text(text).font(.callout.weight(.medium)))
                .offset(x: phase * 120)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityLabel("Grand Wizard is pondering")
    }
}

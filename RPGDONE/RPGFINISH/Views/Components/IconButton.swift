import SwiftUI

struct IconButton: View {
    let iconName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(title).font(.footnote).lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

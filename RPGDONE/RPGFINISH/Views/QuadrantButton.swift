import SwiftUI

struct QuadrantButton: View {
    let title: String
    let color: Color
    let tapAction: () -> Void
    var body: some View {
        ZStack {
            color
            Text(title)
                .font(.title)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            tapAction()
        }
    }
} 
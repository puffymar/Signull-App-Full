import SwiftUI

struct RGBDisplace: ViewModifier {
    var amplitude: CGFloat
    @State private var t: Double = 0

    private var shader: Shader {
        Shader(function: .init(library: .default, name: "rgbDisplace"),
               arguments: [
                    .texture(.content),
                    .float(t),
                    .float(Float(amplitude))
               ])
    }

    func body(content: Content) -> some View {
        TimelineView(.animation) { tl in
            let time = tl.date.timeIntervalSinceReferenceDate
            content
                .layerEffect(shader, maxSampleOffset: .init(width: amplitude * 6, height: amplitude * 6))
                .onChange(of: time) { _, new in t = new }
        }
    }
}

extension View {
    func rgbDisplace(amplitude: CGFloat = 0.35) -> some View {
        modifier(RGBDisplace(amplitude: amplitude))
    }
}



import SwiftUI

// MARK: - SYSTEM-style reactive background with scanlines

struct ReactiveSphereBackground: View {
    /// Drive with scroll/interaction if you like (0…1). Otherwise it idles.
    var drive: CGFloat = 0.0
    @State private var seed: CGFloat = .random(in: 0...1)

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                // Base
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))

                // Center follows a slow orbital drift
                let cx = size.width * 0.5 + CGFloat(sin(t * 0.25 + Double(seed)) * 10)
                let cy = size.height * 0.36 + CGFloat(cos(t * 0.22 + Double(seed)) * 8)
                let c  = CGPoint(x: cx, y: cy)

                // Soft radial glow (blue mythic)
                let glow = Gradient(stops: [
                    .init(color: Color(red: 0.10, green: 0.20, blue: 0.32).opacity(0.8), location: 0),
                    .init(color: Color.black, location: 1)
                ])
                let rGrad = GraphicsGradient.radialGradient(glow, center: c, startRadius: 2, endRadius: max(size.width, size.height) * 0.9)
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .gradient(rGrad))

                // Concentric kinetic rings
                let ringCount = 12
                let baseR: CGFloat = min(size.width, size.height) * 0.18
                for i in 0..<ringCount {
                    let p = CGFloat(i) / CGFloat(max(1, ringCount - 1))
                    let wobble = CGFloat(sin(t * 1.05 + Double(i) * 0.55)) * 5
                    let r = baseR + p * min(size.width, size.height) * 0.55 + wobble + drive * 10
                    var path = Path()
                    path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))

                    let alpha = 0.20 * (1 - p) + 0.06
                    let stroke = GraphicsGradient.linearGradient(
                        Gradient(colors: [
                            Color(red: 0.45, green: 0.75, blue: 1.0).opacity(alpha),
                            Color(red: 0.15, green: 0.30, blue: 0.60).opacity(alpha * 0.6)
                        ]),
                        startPoint: CGPoint(x: c.x - r, y: c.y - r),
                        endPoint: CGPoint(x: c.x + r, y: c.y + r)
                    )
                    ctx.stroke(path, with: .gradient(stroke), lineWidth: 1.0)
                }

                // Subtle vignette
                let vignette = Gradient(stops: [
                    .init(color: .clear, location: 0.6),
                    .init(color: .black.opacity(0.45), location: 1)
                ])
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .gradient(GraphicsGradient.radialGradient(vignette, center: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: 0, endRadius: max(size.width, size.height))) )
            }
        }
        .overlay(CRTScanlines().blendMode(.overlay).allowsHitTesting(false))
        .ignoresSafeArea()
    }
}

struct CRTScanlines: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 2.0
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                ctx.fill(Path(rect), with: .color(.white.opacity(0.05)))
                y += spacing
            }
        }
    }
}



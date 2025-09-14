import SwiftUI

// LoadingView.swift (drop-in)
struct LoadingView: View {
    var body: some View { MorphingLoader() }
}

struct BreathingSphere: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let c = CGPoint(x: size.width/2, y: size.height/2)
                let base: CGFloat = min(size.width, size.height)/2.6
                let b = CGFloat(sin(t*1.8))*6
                // Core
                var core = Path()
                core.addEllipse(in: CGRect(x: c.x-(base+8+b), y: c.y-(base+8+b), width: (base+8+b)*2, height: (base+8+b)*2))
                ctx.fill(core, with: .radialGradient(Gradient(colors: [
                    Color(red: 0.50, green: 0.90, blue: 1.0),
                    Color(red: 0.10, green: 0.20, blue: 0.35).opacity(0.4)
                ]), center: c, startRadius: 0, endRadius: base+14+b))

                // Pulsing rings
                for i in 0..<5 {
                    let r = base + CGFloat(i)*14 + CGFloat(sin(t*1.2 + Double(i)*0.7))*3
                    var p = Path()
                    p.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r*2, height: r*2))
                    ctx.stroke(p, with: .color(Color(red: 0.45, green: 0.75, blue: 1.0).opacity(0.35 - Double(i)*0.05)), lineWidth: 1)
                }
            }
        }
        .overlay(CRTScanlines().blendMode(.overlay).allowsHitTesting(false))
    }
}

struct GlowingTriangle: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let p0 = CGPoint(x: w*0.5, y: h*0.08)
            let p1 = CGPoint(x: w*0.06, y: h*0.90)
            let p2 = CGPoint(x: w*0.94, y: h*0.90)
            var tri = Path(); tri.move(to: p0); tri.addLines([p1,p2,p0])
            ctx.fill(tri, with: .radialGradient(Gradient(colors: [
                Color(red: 0.60, green: 0.90, blue: 1.0),
                Color(red: 0.15, green: 0.25, blue: 0.40).opacity(0.4)
            ]), center: CGPoint(x: w/2, y: h*0.55), startRadius: 0, endRadius: max(w, h)*0.7))
            ctx.stroke(tri, with: .color(Color(red: 0.55, green: 0.80, blue: 1.0).opacity(0.85)), lineWidth: 1.2)
            for y in stride(from: h*0.12, through: h*0.88, by: 3) {
                var line = Path(); line.move(to: CGPoint(x: w*0.18, y: y)); line.addLine(to: CGPoint(x: w*0.82, y: y))
                ctx.stroke(line, with: .color(.white.opacity(0.06)), lineWidth: 1)
            }
        }
        .overlay(CRTScanlines().blendMode(.overlay))
    }
}

// Minimal scanlines helper to avoid dependency issues
private struct CRTScanlines: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let h = max(geo.size.height, 1)
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .white.opacity(0.08), location: 0.0),
                    .init(color: .clear, location: 0.5),
                    .init(color: .white.opacity(0.08), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(
                Canvas { ctx, size in
                    for y in stride(from: phase.truncatingRemainder(dividingBy: 6), to: h, by: 6) {
                        ctx.stroke(
                            Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                            with: .color(.white),
                            lineWidth: 1
                        )
                    }
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 6
                }
            }
        }
    }
}

struct MorphingLoader: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            ReactiveSphereBackground(drive: phase)
            VStack(spacing: 22) {
                ZStack {
                    GlowingTriangle()
                        .opacity(1 - phase)
                        .scaleEffect(1 - phase*0.08)
                        .rgbDisplace(amplitude: 0.28)
                    BreathingSphere()
                        .opacity(phase)
                        .scaleEffect(0.92 + phase*0.08)
                        .rgbDisplace(amplitude: 0.22)
                }
                .frame(width: 130, height: 130)
                Text(phase < 0.5 ? "INITIALIZING" : "TUNING THE SIGNAL")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.92))
                    .rgbDisplace(amplitude: 0.18)
            }
        }
        .onAppear { withAnimation(.easeInOut(duration: 1.2)) { phase = 1 } }
    }
}

struct BreathingSphere: View {
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let base: CGFloat = min(size.width, size.height) / 2.6
                let b = CGFloat(sin(t * 1.8)) * 6
                // Core
                var core = Path()
                core.addEllipse(in: CGRect(x: c.x - (base + 8 + b), y: c.y - (base + 8 + b), width: (base + 8 + b) * 2, height: (base + 8 + b) * 2))
                ctx.fill(core, with: .radialGradient(Gradient(colors: [
                    Color(red: 0.50, green: 0.90, blue: 1.0),
                    Color(red: 0.10, green: 0.20, blue: 0.35).opacity(0.4)
                ]), center: c, startRadius: 0, endRadius: base + 14 + b))

                // Pulsing rings
                for i in 0..<5 {
                    let r = base + CGFloat(i) * 14 + CGFloat(sin(t * 1.2 + Double(i) * 0.7)) * 3
                    var p = Path()
                    p.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
                    ctx.stroke(p, with: .color(Color(red: 0.45, green: 0.75, blue: 1.0).opacity(0.35 - Double(i) * 0.05)), lineWidth: 1)
                }
            }
        }
        .overlay(CRTScanlines().blendMode(.overlay).allowsHitTesting(false))
    }
}



import SwiftUI

// MARK: - Timeout helper
func withTimeout<T>(_ seconds: Double, _ work: @escaping () async throws -> T) async -> Result<T, Error> {
    await withTaskGroup(of: Result<T, Error>.self) { group in
        group.addTask { 
            do {
                return .success(try await work())
            } catch {
                return .failure(error)
            }
        }
        group.addTask {
            let ns = UInt64(seconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            return .failure(NSError(domain: "Timeout", code: -1001))
        }
        let first = await group.next()!
        group.cancelAll()
        return first
    }
}

// MARK: - Drop-in model (tolerant) and parser
private struct AIStory: Identifiable, Hashable, Equatable {
    enum Status: Hashable { case placeholder, ready, error(String) }
    let id = UUID()
    var title: String
    var hook: String
    var tags: [String]
    var accent: Color
    var status: Status
    var raw: String
    
    static func == (lhs: AIStory, rhs: AIStory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private enum APIParse {
    static func extractStory(from data: Data) throws -> AIStory {
        let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        // Try output.message.content first
        if let output = root["output"] as? [[String: Any]] {
            let messages = output.filter { ($0["type"] as? String) == "message" }
            if let content = messages.first?["content"] as? [[String: Any]] {
                if let jsonItem = content.first(where: { ($0["type"] as? String) == "output_json" }),
                   let dict = jsonItem["json"] as? [String: Any] {
                    return fromJSONDict(dict, raw: (try? toJSONString(dict)) ?? "")
                }
                if let textItem = content.first(where: { ($0["type"] as? String) == "output_text" }),
                   let text = textItem["text"] as? String {
                    if let dict = try? JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any] {
                        return fromJSONDict(dict, raw: text)
                    }
                    // fallback: treat as hook-only
                    return AIStory(title: "Untitled", hook: text, tags: ["mystical"], accent: .cyan, status: .ready, raw: text)
                }
            }
        }

        // Top-level minimal
        if let title = root["title"] as? String, let hook = (root["hook"] as? String) ?? (root["openingHook"] as? String) ?? (root["opening_hook"] as? String) {
            let t = (root["tags"] as? [String]) ?? []
            return AIStory(title: title, hook: hook, tags: t.isEmpty ? ["mystical"] : t, accent: .cyan, status: .ready, raw: (try? toJSONString(root)) ?? "")
        }

        throw NSError(domain: "APIParse", code: -3, userInfo: [NSLocalizedDescriptionKey: "No output_text content"])
    }

    private static func fromJSONDict(_ dict: [String: Any], raw: String) -> AIStory {
        let title = (dict["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hook = (dict["hook"] as? String)
            ?? (dict["openingHook"] as? String)
            ?? (dict["opening_hook"] as? String)
            ?? "Something feels different here..."
        let tags = (dict["tags"] as? [String]) ?? []
        return AIStory(
            title: (title?.isEmpty == false) ? title! : "Untitled",
            hook: hook,
            tags: tags.isEmpty ? ["mystical", "coastal"] : tags,
            accent: [.blue, .teal, .purple, .indigo, .mint].randomElement()!,
            status: .ready,
            raw: raw
        )
    }

    private static func toJSONString(_ obj: Any) throws -> String {
        let d = try JSONSerialization.data(withJSONObject: obj)
        return String(data: d, encoding: .utf8) ?? "{}"
    }
}

// MARK: - ViewModel with timeout protection and never-stuck loading
@MainActor
private final class AIStoriesVM: ObservableObject {
    enum Phase { case idle, preparing, generating(done: Int, total: Int), ready([AIStory]) }
    @Published var phase: Phase = .idle
    @Published var selected: AIStory? = nil

    var isReady: Bool { if case .ready = phase { return true } ; return false }

    private let endpoint = URL(string: "https://api.signullrift.com/responses")!

    func loadThree() {
        phase = .preparing
        Task {
            try? await Task.sleep(nanoseconds: 320_000_000) // precursor delay

            var results: [AIStory] = []
            let total = 3
            phase = .generating(done: 0, total: total)

            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<total {
                    group.addTask { [endpoint] in
                        let result = await withTimeout(12.0) { () async throws -> AIStory in
                            let req = await self.makeStoryRequest(url: endpoint)
                            let (data, _) = try await URLSession.shared.data(for: req)
                            return try APIParse.extractStory(from: data)
                        }
                        await MainActor.run {
                            switch result {
                            case .success(let story): results.append(story)
                            case .failure:
                                // add a graceful placeholder with better content
                                let fallbackStories = [
                                    AIStory(title: "The Whispering Dunes", 
                                           hook: "Ancient sands shift beneath your feet, carrying secrets from civilizations long forgotten. The wind speaks in tongues you almost understand.", 
                                           tags: ["mystical", "desert"], accent: .orange, status: .ready, raw: ""),
                                    AIStory(title: "The Glass Forest", 
                                           hook: "Crystalline trees reflect moonlight in impossible patterns. Each step echoes through the transparent canopy, and something watches from within the reflections.", 
                                           tags: ["mystical", "forest"], accent: .cyan, status: .ready, raw: ""),
                                    AIStory(title: "The Clockwork Heart", 
                                           hook: "Deep beneath the city, gears turn in perfect harmony. But one cog is missing, and the rhythm is beginning to falter.", 
                                           tags: ["steampunk", "urban"], accent: .purple, status: .ready, raw: "")
                                ]
                                let fallback = fallbackStories[results.count % fallbackStories.count]
                                results.append(fallback)
                            }
                            let doneNow = results.count
                            self.phase = .generating(done: doneNow, total: total)
                        }
                    }
                }
                // Wait for all tasks to complete
                await group.waitForAll()
            }

            // Do not animate layout on data arrival
                self.phase = .ready(Array(results.prefix(3)))
        }
    }
    
    private func makeStoryRequest(url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("RPGFINISH/1.0 (iOS; Simulator)", forHTTPHeaderField: "User-Agent")
        req.setValue("signull-ios", forHTTPHeaderField: "X-App-Client")
        SignullAuth.apply(to: &req)

        let body: [String: Any] = [
            "model": "gpt-5-mini-2025-08-07",
            "input": "Generate exactly ONE story idea as JSON with fields {title, hook, tags}. tags must be an array of 1–3 short, evocative single-word labels (e.g., mystical, coastal, clockwork). Keep hook vivid and concrete (2–3 sentences). No extra fields, no prose outside JSON.",
            "text": [
                "format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "StoryIdea",
                        "strict": true,
                        "schema": [
                            "type": "object",
                            "properties": [
                                "title": ["type": "string", "maxLength": 80],
                                "hook":  ["type": "string", "maxLength": 320],
                                "tags":  [
                                    "type": "array",
                                    "items": ["type": "string", "maxLength": 16],
                                    "minItems": 1,
                                    "maxItems": 3
                                ]
                            ],
                            "required": ["title","hook","tags"],
                            "additionalProperties": false
                        ]
                    ]
                ],
                "verbosity": "medium"
            ],
            "max_output_tokens": 260,
            "parallel_tool_calls": false
        ]
        req.httpBody = try! JSONSerialization.data(withJSONObject: body)
        return req
    }
}

// MARK: - Glass HUD Component
private struct GlassHUD: View {
    var title: String
    var done: Int
    var total: Int
    var body: some View {
        HStack(spacing: 12) {
            ProgressView(value: Double(done), total: Double(total))
                .progressViewStyle(.linear)
                .frame(width: 170)
            Text("\(title) \(done)/\(total)…")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 18, y: 8)
    }
}

// MARK: - CRT Dream Button
private struct DreamButton: View {
    var enabled: Bool
    var tap: () -> Void
    
    @State private var glowPhase: CGFloat = 0
    @State private var scanlinePhase: CGFloat = 0
    @State private var pulsePhase: CGFloat = 0
    
    var body: some View {
        Button(action: tap) {
            ZStack {
                // CRT background with scanlines
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.9),
                                Color.gray.opacity(0.8),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                )
            )
            .overlay(
                        // Scanline effect
                        ScanlineShader(phase: scanlinePhase)
                            .blendMode(.plusLighter)
                            .opacity(0.15)
                    )
                    .overlay(
                        // CRT glow border
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: glowColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: enabled ? 2.5 : 1.5
                            )
                            .shadow(
                                color: Color.cyan.opacity(enabled ? 0.8 : 0.3),
                                radius: enabled ? 20 : 8
                            )
                    )
                
                // Content
                HStack(spacing: 12) {
                    Image(systemName: "moonphase.first.quarter")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.8), radius: 8)
                    
                    Text("Dream")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .shadow(color: Color.cyan.opacity(0.6), radius: 4)
                }
                .padding(.horizontal, 28).padding(.vertical, 18)
                
                // Pulsing effect when enabled
                if enabled {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        .scaleEffect(1 + pulsePhase * 0.1)
                        .opacity(1 - pulsePhase)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .scaleEffect(enabled ? 1 : 0.95)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: enabled)
        .onAppear {
            // Start CRT animations
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                glowPhase = 1.0
            }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                scanlinePhase = 1.0
            }
            if enabled {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulsePhase = 1.0
                }
            }
        }
    }
    
    private var glowColors: [Color] {
        let colors: [Color] = [.cyan, .blue, .purple, .cyan]
        let index = Int(glowPhase * 3) % 3
        return [colors[index], colors[index + 1]]
    }
}

// MARK: - Missing UI Components
private struct PrepBar: View {
    let text: String
    let progress: Double?
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                if let progress = progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.cyan)
                        .frame(width: 240)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12)))
            .shadow(color: .black.opacity(0.4), radius: 18, y: 6)
            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct NeonButton: View {
    let title: String
    let system: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: system)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cyan.opacity(0.6), lineWidth: 1.5)
                    )
            )
            .shadow(color: .cyan.opacity(0.3), radius: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CRT Story Card Components
private struct CinematicStoryCard: View {
    let story: AIStory
    let isSelected: Bool
    let tap: () -> Void
    
    @State private var showDesc = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header image area (accent gradient + scanlines + CRT icon)
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [story.accent.opacity(0.35), story.accent.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ScanlineShader(phase: 0.3).opacity(0.18)
            }
            .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
            Spacer(minLength: 0)
                    Text(story.title)
                .foregroundColor(.white.opacity(0.92))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                    
            if showDesc {
                    Text(story.hook)
                    .foregroundColor(.white.opacity(0.72))
                    .font(.system(size: 13))
                    .lineLimit(3)
                    .transition(.opacity)
            }

            HStack(spacing: 8) {
                ForEach(story.tags.prefix(3), id: \.self) { t in
                    Text(t).font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.white.opacity(0.06), in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
            }.padding(.top,4)
        }
        .padding(14)
                                .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(colors: [
                        .white.opacity(0.08), .white.opacity(0.03)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .blendMode(.softLight)
                )
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                        .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(story.accent.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: story.accent.opacity(0.35), radius: 14)
        )
        .contentShape(Rectangle())
        .frame(height: 220)
    }
}

// MARK: - Lite Card used by new grid flow
private struct StoryCardLite: View {
    let s: AIStory
    var onDream: () -> Void
    var onDescription: () -> Void

    var body: some View {
        CRTGlassCard(tint: s.accent) {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(s.accent)
                    .frame(width: 28, height: 28)
                Text(s.title)
                    .foregroundColor(SN.fg)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                Spacer()
            }

            Text(s.hook)
                .foregroundColor(SN.sub)
                .font(.system(size: 13))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)

            HStack(spacing: 6) {
                ForEach(s.tags.prefix(3), id: \.self) { t in
                    Text(t)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.white.opacity(0.06), in: Capsule())
                        .overlay(Capsule().stroke(SN.line1, lineWidth: 1))
                }
                Spacer()
                DreamChipLite(action: onDream)
            }

            HStack {
                DescriptionChipLite(action: onDescription)
                Spacer()
            }
            .padding(.top, 2)
        }
        .contentShape(Rectangle())
    }
}

private struct DreamChipLite: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").font(.system(size: 13, weight: .bold))
                Text("Dream").font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(SN.fg)
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(SN.line1, lineWidth: 1))
            .shadow(color: SN.glow.opacity(0.22), radius: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct DescriptionChipLite: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "text.alignleft").font(.system(size: 12, weight: .bold))
                Text("Description").font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(SN.fg)
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(Color.white.opacity(0.05), in: Capsule())
            .overlay(Capsule().stroke(SN.line1, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - In-app Description Drawer (opaque backdrop)
private struct DescriptionDrawerLite: View {
    let story: AIStory
    var onClose: () -> Void
    var onDream: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.70).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                Capsule().fill(Color.white.opacity(0.25))
                    .frame(width: 44, height: 5)
                    .padding(.top, 8).padding(.bottom, 12)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(story.accent)
                            .frame(width: 28, height: 28)
                        Text(story.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(SN.fg)
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                        }.tint(SN.sub)
                    }

                    Text(story.hook)
                        .font(.system(size: 15))
                        .foregroundColor(SN.fg)
                        .lineSpacing(3.5)

                    HStack(spacing: 6) {
                        ForEach(story.tags, id: \.self) { t in
                            Text(t).font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.white.opacity(0.06), in: Capsule())
                                .overlay(Capsule().stroke(SN.line1, lineWidth: 1))
                        }
                        Spacer()
                        DreamChipLite(action: { onClose(); onDream() })
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    ScanlineShader(phase: 0.3)
                        .opacity(0.22)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
    }
}

// MARK: - Scanline Shader Component
private struct ScanlineShader: View {
    let phase: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let lineHeight: CGFloat = 2
                let spacing: CGFloat = 4
                let totalHeight = lineHeight + spacing
                
                for y in stride(from: 0, through: size.height, by: totalHeight) {
                    let adjustedY = (y + phase * size.height * 2).truncatingRemainder(dividingBy: size.height)
                    let opacity = 0.1 * (1 - abs(adjustedY - size.height/2) / (size.height/2))
                    
                    context.fill(
                        Path(CGRect(x: 0, y: adjustedY, width: size.width, height: lineHeight)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Ambient Particle Effects
private struct AmbientParticles: View {
    let phase: CGFloat
    let accent: Color
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let particleCount = 8
                
                for i in 0..<particleCount {
                    let progress = (phase + Double(i) / Double(particleCount)).truncatingRemainder(dividingBy: 1.0)
                    let x = size.width * 0.2 + (size.width * 0.6) * progress
                    let y = size.height * 0.3 + sin(progress * .pi * 4) * size.height * 0.2
                    let opacity = 0.3 * (1 - abs(progress - 0.5) * 2)
                    let size = 2 + sin(progress * .pi * 2) * 2
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - size/2, y: y - size/2, width: size, height: size)),
                        with: .color(accent.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Reactive Pulsing Aura
private struct PulsingAura: View {
    let accent: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        RadialGradient(colors: [accent.opacity(0.18), .clear], center: .center, startRadius: 0, endRadius: 240)
            .scaleEffect(0.95 + 0.08 * phase)
            .opacity(0.6 * (0.5 + 0.5 * phase))
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: phase)
            .onAppear { phase = 1 }
            .allowsHitTesting(false)
    }
}

struct AIStoriesView: View {
    @StateObject private var vm = AIStoriesVM()
    @Namespace private var ns
    @Environment(\.dismiss) private var dismiss
    @State private var showPreview = false
    @State private var gridAnimationPhase: CGFloat = 0
    @State private var goToStory = false
    @State private var initialStoryText = ""
    @State private var descTarget: AIStory? = nil
    // 🎯 OPTIMIZED SCANLINE STATES
    @State private var scanlinePulse: Double = 0.0
    @State private var scanlineIntensity: Double = 0.0
    @State private var promptSweepX: CGFloat = -120
    
    // 🌙 ENHANCED DREAM BUTTON STATES
    @State private var dreamButtonGlow: Double = 0.0

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Unified CRT Background
                CRTBackground()

                // (Aura removed per revert)

                // Always show content immediately; no loading curtain
                VStack(spacing: 12) { header; listContent() }

                // In-app description drawer (not system sheet)
                if let story = descTarget {
                    DescriptionDrawerLite(
                                        story: story,
                        onClose: { withAnimation(.easeInOut(duration: 0.18)) { descTarget = nil } },
                        onDream: {
                            initialStoryText = "\(story.title)\n\n\(story.hook)"
                            descTarget = nil
                            goToStory = true
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
                }
            }
            .onAppear { if case .idle = vm.phase { vm.loadThree() } }
            // No sheets; we use a custom in-app drawer
            .navigationDestination(isPresented: $goToStory) { StoryView(initialStory: initialStoryText) }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) { Image(systemName: "chevron.left"); Text("Back") }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    // Inline boot loading removed

    // Break out list to simplify type-checking in body
    @ViewBuilder
    private func listContent() -> some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                if case .ready(let stories) = vm.phase {
                    ForEach(Array(stories.enumerated()), id: \.element.id) { _, story in
                        StoryCardLite(
                            s: story,
                            onDream: {
                                initialStoryText = "\(story.title)\n\n\(story.hook)"
                                goToStory = true
                            },
                            onDescription: {
                                descTarget = story
                            }
                        )
                        .frame(height: 230)
                        .animation(nil, value: stories.count)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 100)
        }
    }

    private var header: some View {
        HStack {
            // Removed Home button; keep toolbar Back button only
            Spacer(minLength: 0)

            Spacer()
            Text("AI STORIES")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.cyan)
                .shadow(color: .cyan.opacity(0.4), radius: 6, y: 2)
                .overlay(
                    GlobalAura(accent: .cyan, intensity: 0.6)
                        .frame(height: 34)
                        .offset(y: 18)
                        .allowsHitTesting(false)
                )
            Spacer()

            Button { vm.loadThree() } label: {
                Image(systemName: "gearshape.fill")
            }
            .buttonStyle(.bordered)
            .tint(.blue.opacity(0.25))
        }
    }

    private func navigate(to story: AIStory) { vm.selected = story; showPreview = false }
}

// MARK: - Background Components
private struct GridBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let gridSize: CGFloat = 40
                let lineWidth: CGFloat = 0.5
                
                // Vertical lines
                for x in stride(from: 0, through: size.width, by: gridSize) {
                    let adjustedX = (x + phase * gridSize).truncatingRemainder(dividingBy: size.width)
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: adjustedX, y: 0))
                            path.addLine(to: CGPoint(x: adjustedX, y: size.height))
                        },
                        with: .color(.white.opacity(0.1)),
                        lineWidth: lineWidth
                    )
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: size.height, by: gridSize) {
                    let adjustedY = (y + phase * gridSize).truncatingRemainder(dividingBy: size.height)
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: adjustedY))
                            path.addLine(to: CGPoint(x: size.width, y: adjustedY))
                        },
                        with: .color(.white.opacity(0.1)),
                        lineWidth: lineWidth
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 60.0).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}

private struct PulsingSigil: View {
    @State private var pulse: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer ring
                Circle()
                    .stroke(.cyan.opacity(0.3), lineWidth: 1)
                    .scaleEffect(1 + pulse * 0.5)
                    .opacity(1 - pulse)
                
                // Inner sigil
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(.cyan.opacity(0.6))
                    .scaleEffect(1 + pulse * 0.2)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                pulse = 1.0
            }
        }
    }
}

// MARK: - Skeleton Loading Cards
private struct SkeletonCard: View {
    let index: Int
    @State private var shimmer: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(
                // Shimmer effect
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: UnitPoint(x: shimmer - 0.5, y: 0),
                            endPoint: UnitPoint(x: shimmer + 0.5, y: 1)
                        )
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    shimmer = 1.5
                }
            }
    }
}

private struct StoryPreviewSheet: View {
    let story: AIStory
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [.black, story.accent.opacity(0.35)], startPoint: .top, endPoint: .bottom))
                .frame(height: 140)
                .overlay(ScanlineOverlay().opacity(0.25))
                .overlay(alignment: .bottomLeading) {
                    Label("Preview", systemImage: "sparkles")
                        .padding(10)
                        .background(.black.opacity(0.35), in: Capsule())
                        .padding()
                }
            Text(story.title).font(.title2.bold())
            Text(story.hook).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            HStack {
                ForEach(story.tags, id: \.self) { t in
                    Text(t)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.ultraThinMaterial))
                }
            }
            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .large])
        .background(Color.black.ignoresSafeArea())
    }
}


// MARK: - Full-screen Loading Curtain (inline)
private struct LoadingCurtain: View {
    var progress: Double? = nil
    var label: String? = nil
    @State private var p: CGFloat = 0
    var body: some View {
        ZStack {
            Color.black.opacity(0.70).ignoresSafeArea()
            // Global aura behind the panel
            GlobalAura(accent: .cyan, intensity: (progress ?? Double(p)))
                .allowsHitTesting(false)
            VStack(spacing: 14) {
                Text(label ?? "TUNING THE SIGNAL")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.72))
                ProgressView(value: progress ?? p)
                    .progressViewStyle(.linear)
                    .frame(height: 8)
                    .tint(.cyan)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
                Text("\(Int(((progress ?? p))*100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 18, y: 6)
        }
        .onAppear {
            p = 0
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                p = 1.0
            }
        }
    }
}

// MARK: - Global Aura (breathing field)
private struct GlobalAura: View {
    let accent: Color
    let intensity: Double
    @State private var phase: CGFloat = 0
    var body: some View {
        RadialGradient(colors: [accent.opacity(0.25 * intensity), .clear], center: .center, startRadius: 0, endRadius: 700)
            .scaleEffect(0.96 + 0.06 * phase)
            .opacity(0.4 + 0.3 * phase)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: phase)
            .onAppear { phase = 1 }
    }
}

// Phase → 0..1 loading aura mapping
private extension AIStoriesView {
    func auraProgress() -> Double {
        switch vm.phase {
        case .idle: return 0.1
        case .preparing: return 0.3
        case .generating(let done, let total):
            let t = max(1, total)
            return min(1.0, Double(done) / Double(t))
        case .ready: return 1.0
        }
    }
}


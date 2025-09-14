import SwiftUI
import SceneKit

// MARK: - Public entry
public struct InteractiveSphereLoader: View {
    public var autoAdvanceAfter: TimeInterval? = 0.85   // fast beat; set nil to disable
    public var onFinished: () -> Void = {}

    @State private var dots = 0
    @State private var spinHint = true

    public init(autoAdvanceAfter: TimeInterval? = 0.85, onFinished: @escaping () -> Void = {}) {
        self.autoAdvanceAfter = autoAdvanceAfter
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            SceneViewContainer(spinHint: $spinHint)
                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Text("SYSTEM // LOADING")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.95))
                    Text(String(repeating: ".", count: dots))
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.95))
                        .offset(y: -1)
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // dot cycle
            Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
                dots = (dots + 1) % 4
            }
            // optional quick auto-advance
            if let t = autoAdvanceAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + t) { onFinished() }
            }
        }
    }
}

// MARK: - SceneKit wrapper
private struct SceneViewContainer: UIViewRepresentable {
    @Binding var spinHint: Bool

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 120
        view.backgroundColor = .black
        view.scene = makeScene()
        view.pointOfView = view.scene?.rootNode.childNode(withName: "camera", recursively: true)
        view.isPlaying = true
        view.loops = true
        view.rendersContinuously = true

        // gestures (SwiftUI overlay gestures fight SceneKit; use UIKit here)
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(pan); view.addGestureRecognizer(pinch); view.addGestureRecognizer(tap)

        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Scene graph
    private func makeScene() -> SCNScene {
        let scene = SCNScene()

        // camera
        let cam = SCNCamera()
        cam.fieldOfView = 55
        cam.wantsHDR = true
        cam.wantsExposureAdaptation = true
        cam.exposureOffset = 0.1
        cam.bloomIntensity = 0.6
        cam.bloomThreshold = 0.6
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = cam
        cameraNode.position = SCNVector3(0, 0, 6.6)
        scene.rootNode.addChildNode(cameraNode)

        // lights
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.intensity = 900
        key.position = SCNVector3(5, 6, 7)
        scene.rootNode.addChildNode(key)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .omni
        fill.light?.intensity = 400
        fill.position = SCNVector3(-6, -3, 4)
        scene.rootNode.addChildNode(fill)

        let amb = SCNNode()
        amb.light = SCNLight()
        amb.light?.type = .ambient
        amb.light?.intensity = 180
        amb.light?.color = UIColor(red: 0.25, green: 0.35, blue: 0.6, alpha: 1)
        scene.rootNode.addChildNode(amb)

        // sphere
        let sphere = SCNSphere(radius: 1.75)
        sphere.segmentCount = 128
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = UIColor(red: 0.05, green: 0.1, blue: 0.18, alpha: 1)
        mat.metalness.contents = 0.6
        mat.roughness.contents = 0.25
        mat.emission.contents = UIColor(red: 0.35, green: 0.75, blue: 1.0, alpha: 1)
        mat.emission.intensity = 0.35
        mat.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment: Shader.scanlineFragment,
            SCNShaderModifierEntryPoint.surface: Shader.chromaticAberrationSurface
        ]
        sphere.firstMaterial = mat

        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "core"
        scene.rootNode.addChildNode(sphereNode)

        // idle spin
        let spin = SCNAction.repeatForever(.rotateBy(x: 0, y: CGFloat.pi*2, z: 0, duration: 14))
        sphereNode.runAction(spin, forKey: "idleSpin")

        // pulsing rings
        for i in 0..<4 {
            let ring = SCNTorus(ringRadius: 2.5 + CGFloat(i)*0.35, pipeRadius: 0.02)
            let rm = SCNMaterial()
            rm.emission.contents = UIColor(red: 0.45, green: 0.85, blue: 1.0, alpha: 1)
            rm.emission.intensity = 0.75 - CGFloat(i)*0.14
            rm.diffuse.contents = UIColor.clear
            ring.firstMaterial = rm
            let n = SCNNode(geometry: ring)
            n.name = "ring\(i)"
            n.eulerAngles = SCNVector3(Double(i)%2 == 0 ? .pi/2 : 0, 0, Double(i)%3 == 0 ? .pi/3 : 0)
            scene.rootNode.addChildNode(n)

            let pulse = SCNAction.sequence([
                .group([
                    .fadeOpacity(to: 0.12, duration: 0.9),
                    .scale(to: 1.08, duration: 0.9)
                ]),
                .group([
                    .fadeOpacity(to: 0.75 - CGFloat(i)*0.18, duration: 0.9),
                    .scale(to: 1.0, duration: 0.9)
                ])
            ])
            n.runAction(.repeatForever(pulse))
        }

        // faint backdrop disk (helps depth)
        let disk = SCNCylinder(radius: 3.8, height: 0.02)
        let dm = SCNMaterial()
        dm.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.38, alpha: 0.6)
        dm.diffuse.contents = UIColor.black.withAlphaComponent(0.0)
        disk.firstMaterial = dm
        let diskNode = SCNNode(geometry: disk)
        diskNode.eulerAngles = SCNVector3(.pi/2, 0, 0)
        diskNode.position = SCNVector3(0, -1.6, -0.2)
        scene.rootNode.addChildNode(diskNode)

        return scene
    }

    // MARK: - Coordinator (gestures)
    final class Coordinator: NSObject {
        weak var view: SCNView?
        private var lastPan = CGPoint.zero

        @objc func handlePan(_ g: UIPanGestureRecognizer) {
            guard let v = view,
                  let node = v.scene?.rootNode.childNode(withName: "core", recursively: true)
            else { return }

            let p = g.translation(in: v)
            if g.state == .began { lastPan = p }

            let dx = Float(p.x - lastPan.x)
            let dy = Float(p.y - lastPan.y)
            lastPan = p

            // drag rotates sphere
            let factor: Float = 0.008
            node.eulerAngles.y += dx * factor
            node.eulerAngles.x += dy * factor * -1
        }

        @objc func handlePinch(_ g: UIPinchGestureRecognizer) {
            guard let v = view,
                  let cam = v.scene?.rootNode.childNode(withName: "camera", recursively: true)
            else { return }
            let z = cam.position.z
            // clamp zoom range
            cam.position.z = max(4.2, min(10.0, z / Float(g.scale)))
            g.scale = 1
        }

        @objc func handleTap(_ g: UITapGestureRecognizer) {
            guard let v = view,
                  let node = v.scene?.rootNode.childNode(withName: "core", recursively: true)
            else { return }
            let pulse = SCNAction.sequence([
                .group([ .scale(to: 1.06, duration: 0.18),
                         .customAction(duration: 0.18) { n, _ in
                             n.geometry?.firstMaterial?.emission.intensity = 0.65
                         }]),
                .group([ .scale(to: 1.0, duration: 0.26),
                         .customAction(duration: 0.26) { n, _ in
                             n.geometry?.firstMaterial?.emission.intensity = 0.35
                         }])
            ])
            node.runAction(pulse)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Lightweight shader modifiers
private enum Shader {
    /// Subtle scanlines + vignette without textures (fragment stage)
    static let scanlineFragment = """
    #pragma transparent
    #pragma body
    // normalized UV in screen space
    vec2 uv = _surface.diffuseTexcoord;
    // soft vignette
    float d = distance(uv, vec2(0.5));
    float vign = smoothstep(0.9, 0.2, d);
    // scanlines
    float line = 0.06 + 0.05 * (0.5 + 0.5 * sin(uv.y * 220.0 + u_time * 1.7));
    _output.color.rgb = _output.color.rgb * vign + line;
    """

    /// Tiny chromatic aberration shift at the edge (surface stage)
    static let chromaticAberrationSurface = """
    #pragma body
    float rim = pow(1.0 - saturate(_surface.NdotV), 2.0);
    _surface.emission.rgb += vec3(0.02, 0.0, 0.06) * rim;
    """
}

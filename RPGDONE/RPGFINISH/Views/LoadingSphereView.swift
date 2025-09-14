import SwiftUI
import SceneKit

struct LoadingSphereView: View {
    var body: some View {
        ZStack {
            SceneKitView().ignoresSafeArea()
            VStack(spacing: 12) {
                Text("INITIALIZING STORY REALM…")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .opacity(0.85)
                ProgressView().progressViewStyle(.circular)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 36)
        }
    }
}

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = buildScene()
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        view.rendersContinuously = true
        view.loops = true
        return view
    }
    func updateUIView(_ uiView: SCNView, context: Context) {}
}

private func buildScene() -> SCNScene {
    let scene = SCNScene()
    let sphereGeo = SCNSphere(radius: 1.0)
    sphereGeo.segmentCount = 128

    let mat = SCNMaterial()
    mat.lightingModel = .physicallyBased
    mat.metalness.contents = 0.7
    mat.roughness.contents = 0.2
    mat.emission.contents = UIColor.purple.withAlphaComponent(0.35)
    mat.shaderModifiers = [
        .geometry: """
        #pragma arguments
        float u_time;
        float u_amp;
        #pragma body
        float t = u_time * 1.5;
        float n = scn_periodic_noise(_geometry.position.xyz * 3.5 + t);
        _geometry.position.xyz += _geometry.normal * (n * u_amp);
        """,
        .surface: """
        #pragma arguments
        float u_time;
        #pragma body
        float glow = 0.3 + 0.2 * sin(u_time*3.0);
        _output.color.rgb += vec3(glow*0.7, glow*0.2, glow*1.0);
        """
    ]
    sphereGeo.firstMaterial = mat

    let sphereNode = SCNNode(geometry: sphereGeo)
    scene.rootNode.addChildNode(sphereNode)

    let cam = SCNNode()
    cam.camera = SCNCamera()
    cam.camera?.fieldOfView = 55
    cam.position = SCNVector3(0, 0, 3.2)
    scene.rootNode.addChildNode(cam)

    let rot = CABasicAnimation(keyPath: "rotation")
    rot.fromValue = SCNVector4(0, 1, 0, 0)
    rot.toValue = SCNVector4(0, 1, 0, Float.pi*2)
    rot.duration = 12
    rot.repeatCount = .infinity
    sphereNode.addAnimation(rot, forKey: "spin")

    let scale = CABasicAnimation(keyPath: "scale")
    scale.fromValue = SCNVector3(1,1,1)
    scale.toValue = SCNVector3(1.05,1.05,1.05)
    scale.autoreverses = true
    scale.duration = 2.4
    scale.repeatCount = .infinity
    sphereNode.addAnimation(scale, forKey: "pulse")

    return scene
}

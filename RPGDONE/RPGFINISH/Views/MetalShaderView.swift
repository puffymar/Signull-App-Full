import SwiftUI
import MetalKit

struct MetalShaderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        metalView.isPaused = false
        metalView.enableSetNeedsDisplay = false
        let renderer = CrackRenderer(metalView: metalView)
        metalView.delegate = renderer
        return metalView
    }
    func updateUIView(_ uiView: MTKView, context: Context) {}
} 
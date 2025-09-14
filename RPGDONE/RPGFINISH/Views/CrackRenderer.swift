import MetalKit

class CrackRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState

    init(metalView: MTKView) {
        device = metalView.device!
        commandQueue = device.makeCommandQueue()!
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "vertex_main")
        let fragFunc = library.makeFunction(name: "fragment_crack")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        super.init()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        encoder.setRenderPipelineState(pipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
} 
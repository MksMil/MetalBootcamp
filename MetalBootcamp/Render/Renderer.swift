import MetalKit

class Renderer: NSObject {
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary

  private let timeBuffer: MTLBuffer
  private let uniformBuffer: MetalScalarBuffer<Uniforms>
  private let dispatcher: ComputeDispatcher
  
  var selectedColor: FragmentColor = FragmentColor(0.0,0.0,1.0,1.0)
  
  let date = Date()
  
  var computePipelineState: MTLComputePipelineState?
  weak var mtkView: MTKView?

  init(metalView: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue(),
          let library = device.makeDefaultLibrary()
    else {
      fatalError("GPU not available")
    }
    self.mtkView = metalView
    self.device = device
    self.commandQueue = commandQueue
    self.dispatcher = ComputeDispatcher(device: device)
    metalView.device = device

    
    self.library = library
    
    
    guard let buff = device.makeBuffer(length: MemoryLayout<Float>.stride, options: [.storageModeShared])
    else {
      fatalError("cant create timeBuffer")
      
    }
    self.timeBuffer = buff
    self.uniformBuffer = MetalScalarBuffer(mtlBufferOptions: .storageModeShared, mtlDevice: device)
    
    super.init()

    metalView.clearColor = MTLClearColor(red: 0.1, green: 1, blue: 0.8, alpha: 1)
    metalView.delegate = self
    
    makeComputePipelineState()
  }
}
// MARK: - PipelineState
extension Renderer {
  func makeComputePipelineState(){
    //define shader function and make pipelineState
    guard let computeFunction = library.makeFunction(name: "exampleShader"),
          let computePipeline = try? device.makeComputePipelineState(function: computeFunction) else {
      fatalError("couldn't create computeFunc or computePipeline")
    }
    computePipelineState = computePipeline
  }
}

// MARK: - MTKViewDelegate
extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView,
               drawableSizeWillChange size: CGSize) {}

  // MARK: - DRAW
  func draw(in view: MTKView) {
   guard let buffer = commandQueue.makeCommandBuffer(),
         let encoder = buffer.makeComputeCommandEncoder() else {
     print("cant create budder or encoder ")
     return
   }
    
    guard let drawable = view.currentDrawable else {
      print("cant receive drawable")
      return
    }
    //update time buffer
    let timeBufferPointer = timeBuffer.contents().bindMemory(to: Float.self, capacity: 1)
    let newTime = Float(date.timeIntervalSinceNow)
    timeBufferPointer.pointee = newTime
    //update uniform buffer
    //v.1
    uniformBuffer.setValue { pointer in
      pointer.time = newTime
      pointer.shapeColor = selectedColor
    }
    //v.2
//    uniformBuffer.updateValue(keyPath: \.time, value: newTime)
//    uniformBuffer.updateValue(keyPath: \.shapeColor, value: selectedColor)
    
    encoder.setBuffer(timeBuffer, offset: 0, index: 0)
    encoder.setBuffer(uniformBuffer.mtlBuffer, offset: 0, index: 1)
    encoder.setTexture(drawable.texture, index: 0)
    
    guard let computePipelineState else {
      print("error in set pipelineState")
      return
    }
    encoder.setComputePipelineState(computePipelineState)
    
    dispatcher.dispatch(encoder: encoder,
                        pipeline: computePipelineState,
                        texture: drawable.texture)
    encoder.endEncoding()
    buffer.present(drawable)
    buffer.commit()
  }
}

// MARK: - Future Delegate
extension Renderer {
  func changeColor(){
    selectedColor = FragmentColor(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
  }
}

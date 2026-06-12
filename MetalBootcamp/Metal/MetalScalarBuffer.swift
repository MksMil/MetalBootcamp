//
//  MetalScalarBuffer.swift
//  MetalBootcamp
//
//  Created by Миляев Максим on 12.06.2026.
//

import Foundation
import MetalKit

struct MetalScalarBuffer<T> {
  let mtlBuffer: MTLBuffer
  let pointer: UnsafeMutablePointer<T>
  
  init(mtlBufferOptions: MTLResourceOptions = [], mtlDevice: MTLDevice) {
    self.mtlBuffer = mtlDevice.makeBuffer(length: MemoryLayout<T>.stride,
                                          options: mtlBufferOptions)!
    self.pointer = mtlBuffer.contents().bindMemory(to: T.self, capacity: 1)
  }
  var currentValue: T {
    pointer.pointee
  }
  
  func setValue(_ handler: (inout T) -> Void ){
    handler(&pointer.pointee)
  }
  
  func updateValue<V>(keyPath: WritableKeyPath<T,V>, value: V){
    setValue { uniform in
      uniform[keyPath: keyPath] = value
    }
  }
  
}

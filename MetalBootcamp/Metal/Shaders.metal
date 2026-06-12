#include "ShaderTypes.h"
#include <metal_stdlib>
using namespace metal;
//struct VertexIn {
//    float4 position[[attribute(0)]];
//};
//
//vertex float4 vertex_main(const VertexIn vertex_in[[stage_in]]){
//    return  vertex_in.position;
//};
//fragment float4 fragment_main(){
//    return float4(1,0,0,1);
//};

kernel void exampleShader(texture2d<half, access::write> output[[texture(0)]],
                          constant float &time [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint2 gid [[thread_position_in_grid]]){
  if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
  half4 outColor = half4(uniforms.shapeColor.x,uniforms.shapeColor.y,uniforms.shapeColor.z,1.0);
  float2 size = float2(output.get_width(),output.get_height());
  float aspectRation = size.x / size.y;
  float2 normalized = float2(gid) / size;
  float2 normCenter = float2(size.x / 2.0, size.y / 2.0) / size;
  
  float radius = float(0.25 / aspectRation);
  //random rad
  float angle = atan2(normalized.x, normalized.y);
  float distortion = sin(angle * 5 + uniforms.time) + cos(angle * 3 - uniforms.time);
  
  float radNorm = radius + distortion * 0.02;
  float2 diff = normCenter - normalized;
  float dist = sqrt(diff.x * diff.x + (diff.y * diff.y) / (aspectRation * aspectRation));
  if (dist < radNorm){
    output.write(outColor, gid);
  } else {
    //    return half4(color.x,distortion / 2,color.z,1);
    output.write(half4(1.0,0.0,0.5,1), gid);
  }
  
}



// Пример compute-шейдера с корректной проверкой границ для старых GPU.
// На устройствах с nonuniform threadgroups GPU никогда не запустит тред
// за пределами текстуры — проверка нужна только для старого пути.

kernel void processTexture(
    texture2d<float, access::read>  src [[texture(0)]],
    texture2d<float, access::write> dst [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    // Граничная проверка для устройств без nonuniform threadgroup поддержки.
    // На современных GPU этот if никогда не срабатывает — JIT оптимизирует.
    if (gid.x >= dst.get_width() || gid.y >= dst.get_height()) { return; }

    float4 color = src.read(gid);

    // ... обработка ...

    dst.write(color, gid);
}


//
//[[stitchable]] half4 basicColor(float2 position, half4 color,float2 size){
//  float2 normalized = position / size;
//  
//  return half4(normalized.x,normalized.y,1,1);
//}
//[[stitchable]] half4 drawCircle(float2 position, half4 color,float2 size,float2 center,float radius, float time){
//  float aspectRation = size.x / size.y;
//  float2 normalized = position / size;
//  float2 normCenter = center / size;
//  
//  //random rad
//  float angle = atan2(normalized.x, normalized.y);
//  float distortion = sin(angle + time) + cos(angle * 30 - time);
//  
//  float radNorm = radius / size.y + distortion * 0.002;
//  float2 diff = normCenter - normalized;
//  float dist = sqrt(diff.x * diff.x + (diff.y * diff.y) / (aspectRation * aspectRation));
//  if (dist > radNorm) {
//    return color;
//  } else {
////    return half4(color.x,distortion / 2,color.z,1);
//    return color * (1 - distortion / 2);
//  }
//  
//}

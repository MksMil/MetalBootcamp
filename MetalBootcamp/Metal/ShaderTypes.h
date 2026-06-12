#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>


typedef simd_float4 FragmentColor;

typedef struct {
  float time;
  FragmentColor shapeColor;
} Uniforms;

#endif /* ShaderTypes_h */

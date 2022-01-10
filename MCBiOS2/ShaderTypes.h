//
//  ShaderTypes.h
//  
//
//  Created by Xcode Developer on 1/9/22.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

/*
 Accessing Vector Components
 
 pos = float4(1.0f, 2.0f, 3.0f, 4.0f);
 float x = pos[0]; // x = 1.0 float z = pos[2]; // z = 3.0
 float4 vA = float4(1.0f, 2.0f, 3.0f, 4.0f); float4 vB;
 for (int i=0; i<4; i++)
 vB[i] = vA[i] * 2.0f // vB = (2.0, 4.0, 6.0, 8.0);

 float3x2(float2, float2, float2);
 */

typedef struct __attribute__((objc_boxable)) CaptureDevicePropertyControlLayout {
    simd_float2 arc_touch_point;
    simd_float2 button_center_points[5];
    simd_float2 arc_radius;
    simd_float2 arc_center;
    simd_float2 arc_control_points[3];
} CaptureDevicePropertyControlLayout;

#endif /* ShaderTypes_h */

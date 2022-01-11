/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A shader that adds two arrays of floats.
*/

#include <metal_stdlib>
#include <simd/simd.h>
#include "ShaderTypes.h"

using namespace metal;

/*
 
typedef struct
{
    simd_float2 arc_touch_point;
    simd_float2 button_center_points[5];
    simd_float2 arc_radius;
    simd_float2 arc_center;
    simd_float2 arc_control_points[3];
} CaptureDevicePropertyControlLayout;
 
 */

kernel void add_arrays(device CaptureDevicePropertyControlLayout & layout [[ buffer(0) ]],
                                    uint idx [[ thread_position_in_grid ]])
{
    layout.arc_touch_point = {(float)layout.arc_touch_point.y, (float)layout.arc_touch_point.x};
}

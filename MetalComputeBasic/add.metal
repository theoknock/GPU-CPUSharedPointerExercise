/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A shader that adds two arrays of floats.
*/

#include <metal_stdlib>
#include <simd/simd.h>
#import "/Users/xcodedeveloper/Downloads/PerformingCalculationsOnAGPU-3/MCBiOS2/ShaderTypes.h"

using namespace metal;
/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.

kernel void add_arrays(device BezierPathPoints & points [[ buffer(0) ]],
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    points.bezier_path_position_points[0].x = index; //points.bezier_path_position_points[0];//
}

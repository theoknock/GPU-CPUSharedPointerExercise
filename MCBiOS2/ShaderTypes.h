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

typedef struct
{
    simd_float3x2 bezier_path_position_points;
    simd_float3x2 bezier_path_control_points;
} BezierPathPoints;

#endif /* ShaderTypes_h */

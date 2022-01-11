/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import <Foundation/Foundation.h>
//@import CoreGraphics;
#import <Metal/Metal.h>
#include "ShaderTypes.h"

NS_ASSUME_NONNULL_BEGIN

static CaptureDevicePropertyControlLayout layout;

@interface MetalAdder : NSObject

- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData:(vector_float2)touch_point;
- (void) sendComputeCommand;

@end

NS_ASSUME_NONNULL_END

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include "ShaderTypes.h"

NS_ASSUME_NONNULL_BEGIN

static CaptureDevicePropertyControlLayout layout;

@interface MetalAdder : NSObject

- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData;
- (void) sendComputeCommand;

@end

NS_ASSUME_NONNULL_END
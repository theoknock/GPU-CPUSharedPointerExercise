/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A class to manage all of the Metal objects this app creates.
 */

#import "MetalAdder.h"
#include "ShaderTypes.h"

#import <simd/simd.h>

// The number of floats in each array, and the size of the arrays in bytes.
const unsigned int arrayLength = 0x05;
const unsigned int bufferSize = arrayLength * (sizeof(layout));
static vector_float2 touch_point = {1.0, 0.0};
static vector_float2 * touch_point_ptr = &touch_point;
@implementation MetalAdder
{
    id<MTLDevice> _mDevice;
    
    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;
    
    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;
    
    // Data and buffers to hold data
    id<MTLBuffer> captureDevicePropertyControlLayoutBuffer;
}

- (instancetype) initWithDevice: (id<MTLDevice>) device
{
    self = [super init];
    if (self)
    {
        _mDevice = device;
        
        NSError* error = nil;
        
        // Load the shader files with a .metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }
        
        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if (addFunction == nil)
        {
            NSLog(@"Failed to find the adder function.");
            return nil;
        }
        
        // Create a compute pipeline state object.
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
        if (_mAddFunctionPSO == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }
        
        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            NSLog(@"Failed to find the command queue.");
            return nil;
        }
        
        captureDevicePropertyControlLayoutBuffer = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
        CaptureDevicePropertyControlLayout * captureDevicePropertyControlLayoutBufferPtr = captureDevicePropertyControlLayoutBuffer.contents;
        captureDevicePropertyControlLayoutBufferPtr[0] = (CaptureDevicePropertyControlLayout) {
            .arc_touch_point      =  {1.0, 2.0},
            .button_center_points = {{40.0, 0.0}, {30.0, 0.0}, {20.0, 0.0}, {10.0, 0.0}, {0.0, 0.0}},
            .arc_radius           = 0.0,
            .arc_center           = {0.0, 0.0},
            .arc_control_points   = {{0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}}
        };;
    }
    
    return self;
}

- (void) prepareData
{
    CaptureDevicePropertyControlLayout * captureDevicePropertyControlLayoutBufferPtr = (CaptureDevicePropertyControlLayout *)captureDevicePropertyControlLayoutBuffer.contents;
    captureDevicePropertyControlLayoutBufferPtr[0] = (CaptureDevicePropertyControlLayout) {
        .arc_touch_point      =  (*captureDevicePropertyControlLayoutBufferPtr).arc_touch_point,
        .button_center_points = {{40.0, 0.0}, {30.0, 0.0}, {20.0, 0.0}, {10.0, 0.0}, {0.0, 0.0}},
        .arc_radius           = 0.0,
        .arc_center           = {0.0, 0.0},
        .arc_control_points   = {{0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}}
    };;
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {
    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:captureDevicePropertyControlLayoutBuffer offset:0 atIndex:0];
    
    MTLSize threadsPerThreadgroup = MTLSizeMake(MIN(sizeof(CaptureDevicePropertyControlLayout), (_mAddFunctionPSO.maxTotalThreadsPerThreadgroup / _mAddFunctionPSO.threadExecutionWidth)), 1, 1);
    MTLSize threadsPerGrid = MTLSizeMake(arrayLength, 1, 1);
    [computeEncoder dispatchThreads: threadsPerGrid
              threadsPerThreadgroup: threadsPerThreadgroup];
}

- (void) sendComputeCommand
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);
    
    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);
    
    [self encodeAddCommand:computeEncoder];
    
    // End the compute pass.
    [computeEncoder endEncoding];
    
    // Execute the command.
    [commandBuffer commit];
    
    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];
    
    [commandBuffer addCompletedHandler:^ (id<MTLBuffer> buffer) {
        return ^ (id<MTLCommandBuffer> _Nonnull commands) {
            CaptureDevicePropertyControlLayout * captureDevicePropertyControlLayoutBufferPtr = (CaptureDevicePropertyControlLayout *)buffer.contents;
//            printf("bezierPathPointsBufferPtr (BezierPathPoints) == %lu\n", sizeof(*captureDevicePropertyControlLayoutBufferPtr));
            printf("control_layout_buffer.arc_touch_point == {%.1f, %.1f}\n",
                   (*captureDevicePropertyControlLayoutBufferPtr).arc_touch_point.x,
                   (*captureDevicePropertyControlLayoutBufferPtr).arc_touch_point.y);
           
            //            for (unsigned long col_idx = 0; col_idx < 5; col_idx++)
            //            {
            //                printf("\t\t\t%lu\t\t{%.1f, %.1f}\n", col_idx,
            //                       (((*captureDevicePropertyControlLayoutBufferPtr).button_center_points)[col_idx]).x,
            //                       (((*captureDevicePropertyControlLayoutBufferPtr).button_center_points)[col_idx]).y);
            //            }
        };
    }(captureDevicePropertyControlLayoutBuffer)];
}

@end

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import "MetalAdder.h"
#import "ShaderTypes.h"

#import <simd/simd.h>

// The number of floats in each array, and the size of the arrays in bytes.
const unsigned int arrayLength = 0x05;
const unsigned int bufferSize = arrayLength * (sizeof(CaptureDevicePropertyControlLayout));

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
    }
    
    return self;
}

- (void) prepareData
{
    printf("sizeof(CaptureDevicePropertyControlLayout) == %lu\n", sizeof(struct CaptureDevicePropertyControlLayout));
    captureDevicePropertyControlLayoutBuffer = [_mDevice newBufferWithLength:(sizeof(CaptureDevicePropertyControlLayout) * 5) options:MTLResourceStorageModeShared];
    printf("captureDevicePropertyControlLayoutBuffer == %lu\n", sizeof(captureDevicePropertyControlLayoutBuffer));
    struct CaptureDevicePropertyControlLayout * captureDevicePropertyControlLayoutBufferPtr = captureDevicePropertyControlLayoutBuffer.contents;
    captureDevicePropertyControlLayoutBufferPtr[0] = (CaptureDevicePropertyControlLayout){
        .arc_touch_point      = {0.0, 0.0},
        .button_center_points = {{0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}},
        .arc_radius           = 0.0,
        .arc_center           = {0.0, 0.0},
        .arc_control_points   = {{0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}}
    };
}



- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:captureDevicePropertyControlLayoutBuffer offset:0 atIndex:0];
    
    
    MTLSize threadsPerThreadgroup = MTLSizeMake(_mAddFunctionPSO.maxTotalThreadsPerThreadgroup / _mAddFunctionPSO.threadExecutionWidth, 1, 1);
    MTLSize threadsPerGrid = MTLSizeMake(bufferSize, 1, 1);
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
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull commands) {
        [self verifyResults];
    }];
}

- (void) verifyResults
{
    CaptureDevicePropertyControlLayout * captureDevicePropertyControlLayoutBufferPtr = (CaptureDevicePropertyControlLayout *)captureDevicePropertyControlLayoutBuffer.contents;
    printf("bezierPathPointsBufferPtr (BezierPathPoints) == %lu\n", sizeof(*captureDevicePropertyControlLayoutBufferPtr));
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        printf("-----------------------------\n");
        printf("\t\tindex == %lu\n\n", index);
        printf("\t\t\tPosition\n");
        for (unsigned long col_idx = 0; col_idx < 5; col_idx++)
        {
            printf("\t\t\t%lu\t\t{%.1f, %.1f}\n", col_idx,
                   (((*captureDevicePropertyControlLayoutBufferPtr).button_center_points)[col_idx]).x,
                   (((*captureDevicePropertyControlLayoutBufferPtr).button_center_points)[col_idx]).y);
        }
        printf("-----------------------------\n");
    }
    printf("\nCompute results as expected\n");
}


static simd_float1 col_idx;
simd_float3x2 (^bezier_path_points)(simd_float1) = ^ (simd_float1 index) {
    simd_float2 col = simd_make_float2(col_idx++, index);
    return (simd_float3x2) {col, col, col};
};

@end

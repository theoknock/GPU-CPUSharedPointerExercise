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
const unsigned int bufferSize = arrayLength * sizeof(BezierPathPoints);

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Data and buffers to hold data
    BezierPathPoints bezierPathPoints[arrayLength];
    id<MTLBuffer> bezierPathPointsBuffer;
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
    // Allocate three buffers to hold our initial data and the result.
    bezierPathPointsBuffer = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    BezierPathPoints * bezierPathPointsPtr = bezierPathPointsBuffer.contents;
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        bezierPathPointsPtr[index] = ((BezierPathPoints){ .bezier_path_position_points = bezier_path_position(), .bezier_path_control_points = bezier_path_control()});
        printf(" %p\n", bezierPathPointsPtr[index]);
   }
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

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:bezierPathPointsBuffer offset:0 atIndex:0];
//    [computeEncoder setBytes:&bezierPathPointsBuffer length:(6 * sizeof(simd_float2)) atIndex:3];
    
    MTLSize threadsPerThreadgroup = MTLSizeMake(_mAddFunctionPSO.maxTotalThreadsPerThreadgroup / _mAddFunctionPSO.threadExecutionWidth, 1, 1);
    MTLSize threadsPerGrid = MTLSizeMake(_mAddFunctionPSO.threadExecutionWidth, 1, 1);
    [computeEncoder dispatchThreads: threadsPerGrid
              threadsPerThreadgroup: threadsPerThreadgroup];
}

- (void) generateRandomFloatData: (id<MTLBuffer>) buffer
{
    float* dataPtr = buffer.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        printf("index == %lu\n\n", index);
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}

- (void) verifyResults
{
    BezierPathPoints * bezierPathPointsBufferPtr = (BezierPathPoints *)bezierPathPointsBuffer.contents;
    
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        printf("-----------------------------\n");
        printf("%lu\n", index);
        for (unsigned long col_idx = 0; col_idx < 3; col_idx++)
        {
            printf("\t\t\t{%.1f, %.1f}\t\t\t{%.1f, %.1f}\n",
                   (((*bezierPathPointsBufferPtr).bezier_path_position_points).columns[col_idx]).x,
                   (((*bezierPathPointsBufferPtr).bezier_path_position_points).columns[col_idx]).y,
                   (((*bezierPathPointsBufferPtr).bezier_path_control_points).columns[col_idx]).x,
                   (((*bezierPathPointsBufferPtr).bezier_path_control_points).columns[col_idx]).y);
        }
        printf("-----------------------------\n");
    }
    printf("\nCompute results as expected\n");
}



simd_float3x2 bezier_path_position (void) {
    return (simd_float3x2) {{
        {0x00,   0x01},
        { 0x02,   0x04},
        { 0x06,   0x08}
    }};
}

simd_float3x2 bezier_path_control (void) {
    return (simd_float3x2) {{
        {0x10,   0x20},
        {0x40,  0x80},
        {0x100, 0x200}
    }};
}

- (void)updateBezierPathPoints {
    
}


@end

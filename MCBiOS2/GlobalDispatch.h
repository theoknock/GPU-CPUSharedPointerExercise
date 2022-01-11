//
//  GlobalDispatch.h
//  MetalProjectStage-1
//
//  Created by Xcode Developer on 6/15/21.
//

#ifndef GlobalDispatch_h
#define GlobalDispatch_h

#include <stdio.h>
#include <dispatch/dispatch.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <limits.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>

#import "ShaderTypes.h"

static CaptureDevicePropertyControlLayout control_layout;

static void(^((^enumerate)(size_t)))(void) = ^ (size_t i) {
    __block dispatch_queue_t enumerator_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enumerator_queue = dispatch_queue_create("enumerator_queue", DISPATCH_QUEUE_CONCURRENT);
    });
    dispatch_apply(i, enumerator_queue, ^(size_t iteration) {
        dispatch_sync(enumerator_queue, (dispatch_block_t)(enumerate)(iteration));
        enumerate = nil;
    });
    return enumerate(i);
};

static void (^emumerator)(size_t) = ^ (size_t enumerations){
    __block dispatch_queue_t enumerator_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enumerator_queue = dispatch_queue_create("enumerator_queue", DISPATCH_QUEUE_CONCURRENT);
    });
    dispatch_apply(enumerations, enumerator_queue, ^(size_t enumeration) {
        dispatch_sync(enumerator_queue, (dispatch_block_t)(enumerate)(enumeration));

    });
    enumerate(enumerations);
};


#endif /* GlobalDispatch_h */

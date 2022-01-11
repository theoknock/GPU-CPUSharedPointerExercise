//
//  ViewController.m
//  MCBiOS2
//
//  Created by Xcode Developer on 1/9/22.
//  Copyright © 2022 Apple. All rights reserved.
//

#import "ViewController.h"
#import <Metal/Metal.h>
#import "MetalAdder.h"
#import "ShaderTypes.h"

@interface ViewController ()

@end

@implementation ViewController
{
    id<MTLDevice> device;
}

@dynamic view;

static void (^(^(^touch_handler_init)(void(^)(CGPoint)))(UITouch * _Nonnull))(void) = ^ (void(^process_touch_point)(CGPoint)) {
    return ^ (UITouch * _Nonnull touch) {
        return ^{
            CGPoint touch_point = [touch preciseLocationInView:touch.view];
            process_touch_point(touch_point);
        };
    };
};

static void (^(^touch_handler)(UITouch *))(void);
static void (^handle_touch)(void);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    device = MTLCreateSystemDefaultDevice();
    MetalAdder * adder = [[MetalAdder alloc] initWithDevice:device];
    [adder prepareData:vector2((float)CGRectGetMidX(self.view.frame), (float)CGRectGetMidX(self.view.frame))];
    [adder sendComputeCommand];
    touch_handler = touch_handler_init(^ (MetalAdder * metal_adder) {
        return ^ (CGPoint touch_point) {
            if (!CGPointEqualToPoint(touch_point, CGPointZero)) { // ERROR: This is a workaround to a bug that sets the touch point to 0, 0 after touchesEnded
                [metal_adder prepareData:vector2((float)touch_point.x, (float)touch_point.y)];
                [metal_adder sendComputeCommand];
            }
        };
    }(adder));
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{  (handle_touch = touch_handler(touches.anyObject))(); });
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{ handle_touch(); });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{ handle_touch(); });
}



@end

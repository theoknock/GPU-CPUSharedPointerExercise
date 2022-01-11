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

//- (void)loadView {
//    self.view = (ControlView *)[[ControlView alloc] initWithFrame:self.view.frame];
//}
static void (^(^(^touch_handler_init)(dispatch_block_t))(UITouch * _Nonnull))(void) = ^ (dispatch_block_t blk) {
    return ^ (UITouch * _Nonnull touch) {
        return ^{
            CGPoint touch_point = [touch preciseLocationInView:touch.view];
//            layout.arc_touch_point = vector2((float)touch_point.x, (float)touch_point.y);
            blk();
        };
    };
};

static void (^(^touch_handler)(UITouch *))(void);
static void (^handle_touch)(void);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    device = MTLCreateSystemDefaultDevice();
    MetalAdder * adder = [[MetalAdder alloc] initWithDevice:device];
    [adder prepareData];
    [adder sendComputeCommand];
    touch_handler = touch_handler_init(^ (MetalAdder * metal_adder) {
        return ^{
            [metal_adder prepareData];
            [metal_adder sendComputeCommand];
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

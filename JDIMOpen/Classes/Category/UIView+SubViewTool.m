//
//  UIView+SubViewTool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "UIView+SubViewTool.h"

@implementation UIView (SubViewTool)

- (void)addSubviewToControllerView{
    [[UIView getControllerView] addSubview:self];
}

- (void)addSubviewToRootControllerView{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
}

+ (UIView *)getControllerView{
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil &&
           ![controller.presentedViewController isKindOfClass:[UIAlertController class]]) {
        controller = controller.presentedViewController;
    }
    return controller.view;
}

@end

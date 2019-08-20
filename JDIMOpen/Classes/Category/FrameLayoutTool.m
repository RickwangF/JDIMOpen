//
//  RNLiveLayoutTool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "FrameLayoutTool.h"

@implementation FrameLayoutTool

+ (BOOL)IsIphone{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)IsIpad{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)IsIphoneXSeries{
    
    NSString *standardRatio = [NSString stringWithFormat:@"%.2f", 9.0f/19.5];
    NSString *deviceRatio = [NSString stringWithFormat:@"%.2f", [self Width]/[self Height]];
    
    return [standardRatio isEqualToString: deviceRatio];
}

+ (CGFloat)Width{
    return UIScreen.mainScreen.bounds.size.width;
}

+ (CGFloat)Height{
    return UIScreen.mainScreen.bounds.size.height;
}

+ (CGFloat)SixteenNineWidth{
    return [self Height]*9/16;
}

+ (CGFloat)SixteenNineHeight{
    return [self Width]*16/9;
}

+ (CGFloat)UnitWidth{
    if ([self IsIpad]) {
        return [self Width]/768.0;
    }
    else {
        return [self Width]/375.0;
    }
}

+ (CGFloat)UnitHeight{
    if ([self IsIpad]) {
        return [self Height]/1024;
    }
    else {
        if ([self IsIphoneXSeries]) {
            return [self SixteenNineHeight] / 667.0;
        }
        else {
            return [self Height] / 667.0;
        }
    }
}

+ (UIFont *)UnitFont:(CGFloat)size{
    return [UIFont systemFontOfSize:size * [self UnitHeight]];
}

+ (CGFloat)statusBarHeight{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGFloat)TabbarHeight{
    return [self IsIphoneXSeries] ? 83 : 49;
}

+ (CGFloat)HomeBtnHeight{
    return [self IsIphoneXSeries] ? 34 : 0;
}

@end

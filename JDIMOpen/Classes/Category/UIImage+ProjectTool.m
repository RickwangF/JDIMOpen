//
//  UIImage+ProjectTool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "UIImage+ProjectTool.h"

@implementation UIImage (ProjectTool)
    
- (UIImage *)img_resizableWithCapInsets:(UIEdgeInsets)insets{
    return [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)img_setImageName:(NSString *)imageName{
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@/%@@2x.png", [[NSBundle mainBundle] pathForResource:@"images" ofType:@"bundle"], imageName, imageName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:bundlePath];
    
    return image ? image : [UIImage imageNamed:imageName];
}

+ (UIImage *)img_setImageOriginalName:(NSString *)imageName{
    
    UIImage *image = [self img_setImageName:imageName];
    
    return image ? [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : image;
}
    
+ (UIImage *)img_setImageName:(NSString *)imageName bundlePath:(NSString *)path{
    
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    
    return img ? img : [UIImage imageNamed:imageName];
}
    
+ (UIImage *)img_setImageOriginalName:(NSString *)imageName bundlePath:(NSString *)path{
        
    UIImage *img = [self img_setImageName:imageName bundlePath:path];
    
    return img ? [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : img;
}

+ (UIImage *)defultAvatarImage{
    return [self img_setImageName: @"btn_avatar_normal"];
}
    
+ (UIImage *)imgLogoGrayscaleSquare{
    return [UIImage img_setImageName:@"NotFound"];
}

+ (UIImage *)blankIndentImage{
    return [UIImage img_setImageName:@"ic_default_indent"];
}

@end

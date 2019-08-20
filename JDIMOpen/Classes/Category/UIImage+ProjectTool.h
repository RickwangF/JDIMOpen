//
//  UIImage+ProjectTool.h
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ProjectTool)
    
- (UIImage *)img_resizableWithCapInsets:(UIEdgeInsets)insets;

+ (UIImage*)img_setImageName:(NSString*)imageName;

+ (UIImage*)img_setImageOriginalName:(NSString*)imageName;
    
+ (UIImage *)img_setImageName:(NSString *)imageName bundlePath:(NSString *)path;
    
+ (UIImage *)img_setImageOriginalName:(NSString *)imageName bundlePath:(NSString *)path;

+ (UIImage*)defultAvatarImage;
    
+ (UIImage *)imgLogoGrayscaleSquare;

+ (UIImage *)blankIndentImage;

@end

NS_ASSUME_NONNULL_END

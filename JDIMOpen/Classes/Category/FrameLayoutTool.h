//
//  RNLiveLayoutTool.h
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameLayoutTool : NSObject

@property (nonatomic, class, assign, readonly) BOOL IsIphone;

@property (nonatomic, class, assign, readonly) BOOL IsIpad;

@property (nonatomic, class, assign, readonly) BOOL IsIphoneXSeries;

@property (nonatomic, class, assign, readonly) CGFloat Width;

@property (nonatomic, class, assign, readonly) CGFloat Height;

@property (nonatomic, class, assign, readonly) CGFloat SixteenNineWidth;

@property (nonatomic, class, assign, readonly) CGFloat SixteenNineHeight;

@property (nonatomic, class, assign, readonly) CGFloat UnitWidth;

@property (nonatomic, class, assign, readonly) CGFloat UnitHeight;

@property (nonatomic, class, assign, readonly) CGFloat statusBarHeight;

@property (nonatomic, class, assign, readonly) CGFloat TabbarHeight;

@property (nonatomic, class, assign, readonly) CGFloat HomeBtnHeight;

+ (UIFont *)UnitFont:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END

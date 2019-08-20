//
//  ZSCircleProgress.h
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSCircleProgress : UIView
@property (nonatomic, assign) CGFloat progress;  // 进度 0 - 1之间
@property (nonatomic, assign) CGFloat progressWidth;  // 进度条宽度  defult 5
@property (nonatomic, strong) UIColor *progressColor;  // 进度条颜色  defult blackColor
@property (nonatomic, assign) CGLineCap lineCapStyle;  // 进度条首部样式 defult 方形
@property (nonatomic, assign) CGLineJoin lineJoinStyle;  // 进度条尾部部样式 defult 方形
- (void)show;
- (void)dismiss;
@end


@interface ZSCircleLabelProgress : ZSCircleProgress
@property (nonatomic, strong) UIColor *progressLabelColor;  // 进度文字颜色  defult blackColor
@end


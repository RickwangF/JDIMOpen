//
//  ZSCircleProgress.m
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "ZSCircleProgress.h"
#import "FrameLayoutTool.h"
#import "UIView+SubViewTool.h"

@implementation ZSCircleProgress

- (void)drawRect:(CGRect)rect {

    CGFloat progressWidth = _progressWidth > 0 ? _progressWidth : 5;  // 进度条宽度
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - progressWidth) * 0.5;  // 半径
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = progressWidth;
    [(_progressColor ? _progressColor : [UIColor blackColor]) set];  // 进度条颜色
    path.lineCapStyle = _lineCapStyle;
    path.lineJoinStyle = _lineJoinStyle;
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];  // 画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path stroke];
}

- (void)setProgress:(CGFloat)progress {
    
    _progress = progress > 1 ? 1 : (progress < 0 ? 0 : progress);
    
    [self setNeedsDisplay];
}

- (void)show{
    [self addSubviewToControllerView];
}

- (void)dismiss{
    [self removeFromSuperview];
}

@end


@interface ZSCircleLabelProgress ()
@property (nonatomic, weak) UILabel *circleLabel;  // 百分比标签
@end

@implementation ZSCircleLabelProgress

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UILabel *cLabel = [[UILabel alloc] initWithFrame:self.bounds];
        cLabel.font = [FrameLayoutTool UnitFont:16];//KFONT(16);
        cLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
        self.circleLabel = cLabel;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _circleLabel.text = [NSString stringWithFormat:@"%.2f%%", progress * 100];
    _circleLabel.textColor = _progressLabelColor;
    [super setProgress:progress];
}

@end


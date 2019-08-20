//
//  ZSButton.m
//  JadeKing
//
//  Created by 张森 on 2018/10/11.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "CustomButton.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "FrameLayoutTool.h"

@implementation CustomButton

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (_contentComposing == ButtonImageTopWithTitleBottom) {
        self.titleLabel.frame = CGRectMake(0, self.zs_h - 20 * FrameLayoutTool.UnitHeight, self.zs_w, 20 * FrameLayoutTool.UnitHeight);
        self.imageView.frame  = CGRectMake(0, 0, self.zs_w, MIN(self.zs_w, self.titleLabel.zs_y));
    }else if (_contentComposing == ButtonImageRightWithTitleLeft) {
        self.titleLabel.zs_x = 10 * FrameLayoutTool.UnitWidth;
        self.imageView.zs_x  = self.titleLabel.zs_maxX + 8 * FrameLayoutTool.UnitWidth;
    }
}

@end

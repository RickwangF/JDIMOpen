//
//  ZSTableView.m
//  JadeKing
//
//  Created by 张森 on 2018/8/21.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "CustomTableView.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "FrameLayoutTool.h"

@interface CustomTableView ()
@property (nonatomic, strong) UIView *backView;  // 承载模版的背景视图
@end


@implementation CustomTableView

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
    }
    return _backView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backView.frame = CGRectMake(_backView.zs_x, _backView.zs_y, self.zs_w, self.zs_h);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.backView.backgroundColor = backgroundColor;
}

- (void)displayClassForDefultView:(Class)defultViewClass{
    if (!_backView.subviews.count) {
        NSInteger count = self.zs_h / _defultViewRowHeight + 0.5;
        for (NSInteger idx = 0; idx < count; idx++) {
            //CGFloat space = (idx + 1) * 8 * KUNIT_HEIGHT;
            CGFloat space = (idx + 1) * 8 * FrameLayoutTool.UnitHeight;
            UIView *view = [defultViewClass new];
            //view.frame = CGRectMake(0, _defultViewRowHeight * idx + space, self.width, _defultViewRowHeight);
            view.frame = CGRectMake(0, _defultViewRowHeight * idx + space, self.zs_w, _defultViewRowHeight);
            [view layoutIfNeeded];
            
            NSArray <UIView *>*subviews = view.subviews;
            if ([view isKindOfClass:[UITableViewCell class]]) {
                subviews = [view.subviews firstObject].subviews;
            }
            if (subviews.count == 1) {
                subviews = [subviews lastObject].subviews;
            }
            [subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.backgroundColor = [UIColor colorWithRed:233.0/255 green:231.0/255 blue:239.0/255 alpha:1.0];
            }];
            [self addSubview:self.backView];
            [_backView addSubview:view];
        }
    }
}

- (void)reloadDefultView:(Class)defultViewClass{
    [self removeDefultView];
    [self displayClassForDefultView:defultViewClass];
}

- (void)removeDefultView{
    [_backView removeFromSuperview];
    _backView = nil;
}

@end

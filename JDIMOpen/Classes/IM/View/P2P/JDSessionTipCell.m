//
//  JDSessionTipCell.m
//  JadeKing
//
//  Created by 张森 on 2018/10/17.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionTipCell.h"
#import "FrameLayoutTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIColor+ProjectTool.h"

@interface JDSessionTipCell ()
@property (nonatomic, strong) UILabel *tipLabel;  // tip
@property (nonatomic, assign) CGFloat tipWidth;  // tip宽度
@end


@implementation JDSessionTipCell

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.font = [FrameLayoutTool UnitFont:12];//KFONT(12);
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor rgb139Color];
        _tipLabel.layer.cornerRadius = 3 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _tipLabel.clipsToBounds = YES;
        [self.contentView addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.tipLabel.frame = CGRectMake((self.contentView.width - _tipWidth - 20 * KUNIT_WIDTH) * 0.5, (self.contentView.height - 24 * KUNIT_HEIGHT) * 0.5, _tipWidth + 20 * KUNIT_WIDTH, 24 * KUNIT_HEIGHT);
    self.tipLabel.frame = CGRectMake((self.contentView.zs_w - _tipWidth - 20 * FrameLayoutTool.UnitWidth) * 0.5, (self.contentView.zs_h - 24 * FrameLayoutTool.UnitHeight) * 0.5, _tipWidth + 20 * FrameLayoutTool.UnitWidth, 24 * FrameLayoutTool.UnitHeight);
}

- (void)setTipContent:(NSString *)tipContent{
    _tipContent = tipContent;
    //_tipWidth = [tipContent sizeWithFont:KFONT(12) maxSize:CGSizeMake(self.contentView.width, 24 * KUNIT_HEIGHT)].width;
    _tipWidth = [tipContent zs_sizeWithFont:[FrameLayoutTool UnitFont:12] textMaxSize:CGSizeMake(self.contentView.zs_w, 24*FrameLayoutTool.UnitHeight)].width;
    self.tipLabel.text = _tipContent;
    [self layoutSubviews];
}

@end

//
//  JDChatTimeHeader.m
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDChatTimeHeader.h"
#import "FrameLayoutTool.h"
#import "UIColor+ProjectTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>

@interface JDChatTimeHeader ()
@property (nonatomic, strong) UILabel *timeLabel;  // 时间
@property (nonatomic, assign) CGFloat dateTimeWidth;  // 消息时间宽度
@end

@implementation JDChatTimeHeader

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [FrameLayoutTool UnitFont:12];//KFONT(12);
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor rgb139Color];
        _timeLabel.layer.cornerRadius = 3 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _timeLabel.clipsToBounds = YES;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat dateTimeW = (_dateTimeWidth > 0 ? (_dateTimeWidth + 20 * FrameLayoutTool.UnitWidth) : 0);
    //self.timeLabel.frame = CGRectMake((self.width - dateTimeW) * 0.5, 18 * KUNIT_HEIGHT, dateTimeW, 24 * KUNIT_HEIGHT);
    self.timeLabel.frame = CGRectMake((self.zs_w - dateTimeW) * 0.5, 18 * FrameLayoutTool.UnitHeight, dateTimeW, 24 * FrameLayoutTool.UnitHeight);
}

- (void)setDateTime:(NSString *)dateTime{
    _dateTime = dateTime;
    self.timeLabel.text = dateTime;
    //_dateTimeWidth = [dateTime sizeWithFont:KFONT(12) maxSize:CGSizeMake(MAXFLOAT, 24 * KUNIT_HEIGHT)].width;
    _dateTimeWidth = [dateTime zs_sizeWithFont:[FrameLayoutTool UnitFont:12] textMaxSize:CGSizeMake(MAXFLOAT, 24*FrameLayoutTool.UnitHeight)].width;
    [self layoutSubviews];
}

@end

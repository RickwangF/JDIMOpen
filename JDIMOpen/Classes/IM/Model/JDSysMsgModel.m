//
//  JDSysMsgModel.m
//  JadeKing
//
//  Created by 张森 on 2018/9/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSysMsgModel.h"
#import "NSString+ProjectTool.h"
#import "UIColor+ProjectTool.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "FrameLayoutTool.h"
#import "LiveModuleStringTool.h"

@implementation JDSysUnreadMsgModel

- (void)setNum:(NSNumber *)num{
    _num = num;
    if ([num isKindOfClass:[NSNumber class]]) {
        _numStr = [NSString stringWithFormat:@"%@", [num integerValue] > 99 ? @"99+" : num];
        _isUnread = [num integerValue];
    }else{
        _numStr = nil;
        _isUnread = NO;
    }
}

- (void)setTime:(NSNumber *)time{
    _time = time;
    _msgTimeStr = [LiveModuleStringTool getTimeFrame:[time integerValue] showOclock:NO hideTodayOclock:YES timingMode:TimingMode_24];
    //[ZSStringTool getTimeFrame:[time integerValue] showOclock:NO hideTodayOclock:YES timingMode:ZSTimingMode_24];
}

- (void)setTitle:(NSString *)title{
    _title = [NSObject zs_isEmpty:title] ? @"暂时没有新消息" : title;
}

@end

@implementation JDSysMsgUnreadModel

- (void)setTotal:(NSNumber *)total{
    _total = total;
    if ([total isKindOfClass:[NSNumber class]]) {
        _unreadCount = [total integerValue];
    }else{
        _unreadCount = 0;
    }
}

@end


@interface JDSysMsgModel ()
@property (nonatomic, copy) NSAttributedString *titleAttribute;  // 缓存的富文本标题
@end

@implementation JDSysMsgModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"msgId" : @"id"
             };
}

- (void)setTitle:(NSString *)title{
    if (![_title isEqualToString:title]) {
        _titleAttribute = nil;
    }
    _title = title;
}

- (void)setCover:(NSString *)cover{
    _cover = [cover getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:cover];
}

- (NSAttributedString *)getTitleAttributedWithMaxSize:(CGSize)maxSize{
    
    _titleAttribute = [_title zs_addWithFont:[FrameLayoutTool UnitFont:16] textMaxSize:maxSize attributes:@{NSForegroundColorAttributeName : [_isRead boolValue] ? [UIColor rgb82Color] : [UIColor rgb51Color]} alignment:NSTextAlignmentLeft lineHeight:2*FrameLayoutTool.UnitHeight headIndent:0 tailIndent:0 isAutoLineBreak:YES];
    //[_title addAttributedFont:KFONT(16) maxSize:maxSize attribute:@{ NSForegroundColorAttributeName : [_isRead boolValue] ? [UIColor rgb82Color] : [UIColor rgb51Color] } lineHeight:2 * KUNIT_HEIGHT alignment:NSTextAlignmentLeft autoLineBreak:YES];
    _titleAttributedH = [_titleAttribute zs_sizeWithTextMaxSize:maxSize].height;
    //[_titleAttribute sizeWithMaxSize:maxSize].height;
    
    return _titleAttribute;
}

@end




@implementation JDSysMsgGroupModel


@end

//
//  JDSysMsgModel.h
//  JadeKing
//
//  Created by 张森 on 2018/9/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JDSysUnreadMsgModel : NSObject
/// 消息未读数
@property (nonatomic, strong) NSNumber *num;

/// 最新一条未读消息时间戳
@property (nonatomic, strong) NSNumber *time;

/// 最新一条未读消息标题
@property (nonatomic, copy) NSString *title;

/// 消息未读数
@property (nonatomic, copy) NSString *numStr;

/// 最新一条未读消息时间
@property (nonatomic, copy) NSString *msgTimeStr;

/// 是否全部已读
@property (nonatomic, assign) BOOL isUnread;
@end

@interface JDSysMsgUnreadModel : NSObject
/// 通知消息
@property (nonatomic, strong) JDSysUnreadMsgModel *notify;

/// 活动优惠
@property (nonatomic, strong) JDSysUnreadMsgModel *activity;

/// 未读消息数量
@property (nonatomic, strong) NSNumber *total;

/// 未读消息数量
@property (nonatomic, assign) NSInteger unreadCount;
@end



@interface JDSysMsgModel : NSObject
/// 图片
@property (nonatomic, copy) NSString *cover;

/// 描述
@property (nonatomic, copy) NSString *content;

/// 标题
@property (nonatomic, copy) NSString *title;

/// 跳转地址
@property (nonatomic, copy) NSString *url;

/// 消息id
@property (nonatomic, strong) NSNumber *msgId;

/// 是否已读
@property (nonatomic, strong) NSNumber *isRead;

/// 消息时间
@property (nonatomic, strong) NSNumber *pushTime;

// 扩展字段
/// 富文本标题高度
@property (nonatomic, assign) CGFloat titleAttributedH;

/**
 获取富文本标题

 @param maxSize 文本最大限制的宽高
 @return 富文本标题
 */
- (NSAttributedString *)getTitleAttributedWithMaxSize:(CGSize)maxSize;
@end


@interface JDSysMsgGroupModel : NSObject
/// 消息分组日期
@property (nonatomic, copy) NSString *date;

/// 消息数组
@property (nonatomic, copy) NSArray *msgArray;
@end


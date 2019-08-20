//
//  JDSessionKitUtil.h
//  JadeKing
//
//  Created by 张森 on 2018/9/8.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

typedef NS_ENUM(NSInteger, JDSessionMsgType) {
    /// 未知消息
    JDSessionMsgUnknow = 0,
    
    /// 消息不支持
    JDSessionMsgNoSupport = 101,
    
    /// 卡片消息
    JDSessionMsgCard = 102,
    
    /// 订单卡片
    JDSessionMsgOrderCard,
    
    /// 商品卡片
    JDSessionMsgGoodsCard,
    
    /// 拍卖卡片
    JDSessionMsgAuctionCard,
    
    /// 小视频卡片
    JDSessionMsgSVideoCard
};

@interface JDSessionKitUtil : NSObject

/**
 文字替换为emoji表情

 @param msg 文本消息
 @return emoji表情
 */
+ (NSAttributedString *)replaceEmoji:(NSString *)msg;

/**
 消息类型

 @param lastMessage 最后一条消息
 @return 消息类型的字符串
 */
+ (NSString *)messageContent:(NIMMessage*)lastMessage;

/**
 是否可以撤回消息

 @param message 需要撤回的消息
 @return YES为可以撤回的消息
 */
+ (BOOL)canMessageBeRevoked:(NIMMessage *)message;

/**
 是否是客服账号

 @param sessionId 客服云信账号
 @return YES为客服账号
 */
+ (BOOL)isAdminSessionId:(NSString *)sessionId;
@end

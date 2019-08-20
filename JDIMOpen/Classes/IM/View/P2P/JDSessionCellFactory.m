//
//  JDSessionCellFactory.m
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionCellFactory.h"

@implementation JDSessionCellFactory

+ (NSDictionary *)sessionCellDict{
    return @{@(JDSessionMsgNoSupport)   : @"JDSessionTipCell",
             @(NIMMessageTypeTip)       : @"JDSessionTipCell",
             @(NIMMessageTypeText)      : @"JDSessionTextCell",
             @(NIMMessageTypeImage)     : @"JDSessionImageCell",
             @(NIMMessageTypeAudio)     : @"JDSessionAudioCell",
             @(NIMMessageTypeVideo)     : @"JDSessionVideoCell",
             @(JDSessionMsgCard)        : @"JDSessionCardCell",
             @(JDSessionMsgOrderCard)   : @"JDSessionOrderCardCell",
             @(JDSessionMsgGoodsCard)   : @"JDSessionGoodsCardCell",
             @(JDSessionMsgAuctionCard) : @"JDSessionAuctionCardCell",
             @(JDSessionMsgSVideoCard)  : @"JDSessionSVideoCardCell"
             };
}

+ (NSString *)sessionCellFactory:(NIMMessage *)message{
    
    if (message.messageType == NIMMessageTypeCustom) {
        return [self sessionCellDict][@(JDSessionMsgNoSupport)];
    }
    
    NSString *cellString = [self sessionCellDict][@(message.messageType)];
    
    return cellString ? cellString : @"JDSessionTipCell";
}


+ (NSString *)sessionCellFactoryType:(JDSessionMsgType)type{
    
    NSString *cellString = [self sessionCellDict][@(type)];
    
    return cellString ? cellString : @"JDSessionTipCell";
}

@end

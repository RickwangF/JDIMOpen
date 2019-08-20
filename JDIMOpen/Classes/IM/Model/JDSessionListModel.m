//
//  JDSessionListModel.m
//  JadeKing
//
//  Created by 张森 on 2018/11/11.  
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionListModel.h"
#import "LiveModuleStringTool.h"

@implementation JDSessionListModel

- (void)setRecentSession:(NIMRecentSession *)recentSession{
    _recentSession = recentSession;
    
    _msg = [JDSessionKitUtil messageContent:recentSession.lastMessage];
    _isUnread = recentSession.unreadCount;
    _msgTimeStr = [LiveModuleStringTool getTimeFrame:recentSession.lastMessage.timestamp showOclock:NO hideTodayOclock:YES timingMode:TimingMode_24];
    _numStr = [NSString stringWithFormat:@"%@", recentSession.unreadCount > 99 ? @"99+" : @(recentSession.unreadCount)];
}

@end

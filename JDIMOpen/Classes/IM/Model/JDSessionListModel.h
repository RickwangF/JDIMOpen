//
//  JDSessionListModel.h
//  JadeKing
//
//  Created by 张森 on 2018/11/11.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "JDSessionKitUtil.h"

@interface JDSessionListModel : NSObject
/// 当前会话
@property (nonatomic, strong) NIMRecentSession *recentSession;

/// 消息
@property (nonatomic, copy) NSString *msg;

/// 消息未读数
@property (nonatomic, copy) NSString *numStr;

/// 最新一条未读消息时间
@property (nonatomic, copy) NSString *msgTimeStr;

/// 是否全部已读
@property (nonatomic, assign) BOOL isUnread;
@end


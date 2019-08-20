//
//  JDIMNetworkSetting.h
//  RNLive
//
//  Created by Rick on 2019/8/17.
//  Copyright © 2019 Rick. All rights reserved.
//

#if DEBUG
/// Native
#define NATIVE_BASE_HOST @"https://api.jaadee.net/"
#define API_BASE_HOST @"https://newapitest.jaadee.net/"

#else
/// Native
#define NATIVE_BASE_HOST @"https://api.jaadee.net/"
#define API_BASE_HOST @"https://newapi.jaadee.net/"

#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Mark - Msg
static NSString *const JD_Ser_List    = @"services";  // 获取客服列表
static NSString *const JD_Ser_Status  = @"services/show";  // 获取客服在线状态
static NSString *const JD_Unread_Msg  = @"messages/unread";  // 获取未读消息数
static NSString *const JD_Fetch_Msg   = @"messages";  // 获取系统消息列表
static NSString *const JD_ReadA_Msg   = @"messages/reads";  // 全部已读
static NSString *const JD_Read_Msg    = @"messages/read";  // 单条已读

static NSString *const JD_Live_SendMsg= @"s.php";  // 直播间发送消息验证

@interface JDIMNetworkSetting : NSObject

+ (NSDictionary*)HttpHeaders;

@end

NS_ASSUME_NONNULL_END

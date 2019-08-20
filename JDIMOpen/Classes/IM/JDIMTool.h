//
//  JDIMTool.h
//  RNLive
//
//  Created by Rick on 2019/8/18.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// IM模块中需要获取的用户信息的key
static NSString* const UserId = @"userId";

static NSString* const UserName = @"userName";

static NSString* const UserAvatar = @"userAvatar";

static NSString* const UserToken = @"userToken";

static NSString* const EaseAccount = @"easeAccount";

static NSString* const EasePassword = @"easePassword";

typedef void(^PresentLoginBlock)(void);

/// IM模块的基础工具类，有设置云信Appkey，设置当前登录的用户信息等
@interface JDIMTool : NSObject

@property (nonatomic, strong) PresentLoginBlock loginBlock;

+ (JDIMTool *)sharedInstance;

+ (void)initAppKey:(NSString*)appKey CerName:(NSString*)cerName;

+ (void)setUserInfo:(NSDictionary *)userInfo;

+ (NSDictionary*)userInfo;

+ (void)updateUserInfo:(NSString*)key Value:(id)value;

+ (void)resetUserInfo;

+ (NSString*)userId;

+ (NSString*)userName;

+ (NSString*)userAvatar;

+ (NSString*)userToken;

+ (NSString*)easeAccount;

+ (NSString*)easePassword;

+ (NSString *)getEmojisBundlePath;

+ (NSString *)getEmojiFileFromName:(NSString *)fileName;

+ (NSString *)getEmojiFileFromTag:(NSString *)tag;

@end

NS_ASSUME_NONNULL_END

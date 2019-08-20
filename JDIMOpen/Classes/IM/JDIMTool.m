//
//  JDIMTool.m
//  RNLive
//
//  Created by Rick on 2019/8/18.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "JDIMTool.h"
//#import "JDIMService-Swift.h"
#import <JDIMService/JDIMService-Swift.h>


@interface JDIMTool ()

@property (nonatomic, strong) NSMutableDictionary *userDefault;

@end

@implementation JDIMTool

static JDIMTool *instance;

+ (JDIMTool *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JDIMTool alloc] init];
        instance.userDefault = [NSMutableDictionary dictionary];
    });
    return instance;
}

+ (void)initAppKey:(NSString *)appKey CerName:(NSString *)cerName{
    [JDNIM registerTo:appKey apnsCerName:cerName];
}

+ (void)setUserInfo:(NSDictionary *)userInfo{
    if (userInfo == nil || ![userInfo isKindOfClass:NSDictionary.class]) {
        return;
    }
    
    [self sharedInstance].userDefault = [userInfo mutableCopy];
}

+ (NSDictionary *)userInfo{
    return [[self sharedInstance].userDefault copy];
}

+ (void)updateUserInfo:(NSString *)key Value:(id)value{
    if (key == nil || [key isEqualToString:@""]) {
        return;
    }
    
    [[self sharedInstance].userDefault setObject:value forKey:key];
}

+ (void)resetUserInfo{
    [self sharedInstance].userDefault = [NSMutableDictionary dictionary];
}

+ (NSString *)userId{
    return [[self sharedInstance].userDefault objectForKey:UserId];
}

+ (NSString *)userName{
    return [[self sharedInstance].userDefault objectForKey:UserName];
}

+ (NSString *)userAvatar{
    return [[self sharedInstance].userDefault objectForKey:UserAvatar];
}

+ (NSString *)userToken{
    return [[self sharedInstance].userDefault objectForKey:UserToken];
}

+ (NSString *)easeAccount{
    return [[self sharedInstance].userDefault objectForKey:EaseAccount];
}

+ (NSString *)easePassword{
    return [[self sharedInstance].userDefault objectForKey:EasePassword];
}

+ (NSString *)getEmojisBundlePath{
    return [[NSBundle mainBundle] pathForResource:@"emojis" ofType:@"bundle"];
}

+ (NSString *)getEmojiFileFromName:(NSString *)fileName{
    return [NSString stringWithFormat:@"%@@2x.png", fileName];
}

+ (NSString *)getEmojiFileFromTag:(NSString *)tag{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[self getEmojisBundlePath] stringByAppendingPathComponent:@"emojiChat.plist"]];
    return dict[tag] ? [[[self getEmojisBundlePath] stringByAppendingPathComponent:@"emoji"] stringByAppendingPathComponent:[self getEmojiFileFromName:dict[tag]]] : dict[tag];
}

@end

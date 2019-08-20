//
//  JDSessionDetailController.h
//  JadeKing
//
//  Created by 张森 on 2018/9/18.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>
#import "JDSessionView.h"

/// 聊天详情控制器
@interface JDSessionDetailController : UIViewController
@property (nonatomic, strong) id requestParams;
@property (nonatomic, strong) id responseParams;
@property (nonatomic, strong) NIMSession *session;  // 会话
@property (nonatomic, copy) NSString *nickName;  // 昵称
@property (nonatomic, copy) NSString *avatarUrl;  // 头像
@property (nonatomic, copy) void(^getHistoryComplete) (void);  // 历史消息拉取完成

// Mark - overwrite
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error;
- (void)setDeactivateAudioSessionAfterComplete;
- (void)playAudio:(JDSessionModel *)model;
- (BOOL)beginPlay;
- (void)recordStart;

/**
 打开投诉建议控制器的方法，子类需要自己实现
 
 */
- (void)didSelectedAdvice;

/**
 点击卡片的方法，跳转对应的控制器，子类需要自己实现
 
 @param model 会话模型
 */
- (void)didSelectCellAtMessage:(JDSessionModel *)model;

@end

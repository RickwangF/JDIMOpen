//
//  JDInputToolBar.h
//  JadeKing
//
//  Created by 张森 on 2018/9/25.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JDIMService/JDIMService-Swift.h>

static const CGFloat toolBarH = 50;

typedef NS_ENUM(NSInteger, JDInputStatus){
    JDInputStatusText,
    JDInputStatusAudio,
    JDInputStatusEmoticon,
    JDInputStatusMore
};

@protocol JDInputToolBarDelegate <NSObject>

- (void)didSelectedAlbum;
- (void)didSelectedCamera;
- (void)didSelectedAdvice;
- (void)didSelectedSendMsg:(NSString *)msg;
- (void)recordStart;

@end

@interface JDInputToolBar : UIView
/// 代理方法
@property (nonatomic, weak) id<JDInputToolBarDelegate> delegate;

/// 操作盘弹出回调
@property (nonatomic, copy) void(^keyBoardDidShow)(void);

/**
 根据语音的分贝数更新录制的UI

 @param power 语音分贝
 */
- (void)updateRecordUIFromPower:(NSInteger)power;

/**
 键盘收回
 */
- (void)keyBoardHide;

/**
 重制录制状态
 */
- (void)resetRecord;

/**
 录制错误提示
 */
- (void)recordErrorTip;
@end



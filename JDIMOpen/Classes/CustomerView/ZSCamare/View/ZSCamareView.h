//
//  ZSCamareView.h
//  JadeKing
//
//  Created by 张森 on 2018/10/11.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSAVAssetWriteManager.h"

//闪光灯状态
typedef NS_ENUM(NSInteger, ZSCamareFlashState) {
    ZSCamareFlashClose = 0,
    ZSCamareFlashOpen,
    ZSCamareFlashAuto,
};

@protocol ZSCamareViewDelegate <NSObject>

- (void)updateFlashState:(ZSCamareFlashState)state;
- (void)updateRecordingProgress:(CGFloat)progress;
- (void)updateRecordingTime:(NSString *)time;
- (void)updateRecordState:(ZSRecordState)recordStupdateFlashStateate;
- (void)recordFinish;

@end

@interface ZSCamareView : UIView
@property (nonatomic, weak  ) id<ZSCamareViewDelegate> delegate;
@property (nonatomic, assign) ZSRecordState recordState;  // 录制状态
@property (nonatomic, strong, readonly) NSURL *videoFilePath;  // 视频路径
@property (nonatomic, strong, readonly) UIImage *videoImage;  // 视频首帧截图

- (instancetype)initWithVideoModelType:(ZSVideoModelType )type recordMaxTime:(NSInteger)sec;
- (void)turnCameraAction;
- (void)switchflash;
- (void)startRecord;
- (void)stopRecord;
- (void)resetRecord;
- (void)closeCamare;
- (void)takePicturesCompletionHandler:(void(^)(UIImage* img))completionHandler;
@end

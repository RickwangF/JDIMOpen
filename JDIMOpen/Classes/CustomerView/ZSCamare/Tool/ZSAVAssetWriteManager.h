//
//  ZSAVAssetWriteManager.h
//  RecordVideo
//
//  Created by 张森 on 17/6/22.
//  Copyright © 2017年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

//video
static CGFloat const TIMER_INTERVAL  = 0.01;  // 计时器刷新频率
static NSString *const VIDEO_FOLDER = @"videoFolder";  // 视频录制存放文件夹


//录制状态，（这里把视频录制与写入合并成一个状态）
typedef NS_ENUM(NSInteger, ZSRecordState) {
    ZSRecordStateInit = 0,
    ZSRecordStatePrepareRecording,
    ZSRecordStateRecording,
    ZSRecordStateFinish,
    ZSRecordStateFail,
};

//录制视频的长宽比
typedef NS_ENUM(NSInteger, ZSVideoModelType) {
    ZSVideoModelType_1X1 = 0,
    ZSVideoModelType_4X3,
    ZSVideoModelTypeFullScreen
};

@protocol ZSAVAssetWriteManagerDelegate <NSObject>

- (void)finishWriting;
- (void)updateWritingProgress:(CGFloat)progress;

@end

@interface ZSAVAssetWriteManager : NSObject
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, assign) ZSRecordState writeState;
@property (nonatomic, assign) NSInteger recordMaxTime;  // 最长录制时间
@property (nonatomic, weak) id <ZSAVAssetWriteManagerDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)URL videoModelType:(ZSVideoModelType )type;
- (void)startWrite;
- (void)stopWrite;
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer oediaType:(NSString *)mediaType;
- (void)destroyWrite;
@end

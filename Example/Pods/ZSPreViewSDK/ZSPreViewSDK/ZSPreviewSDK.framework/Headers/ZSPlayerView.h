//
//  ZSPlayerView.h
//  JadeKing
//
//  Created by 张森 on 2018/10/15.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <AVKit/AVKit.h>

typedef NS_ENUM(NSInteger, ZSVideoStatus) {
    videoStatusDefualt,
    videoStatusReadyToPlay,
    videoStatusUnknown,
    videoStatusFailed
};

typedef NS_ENUM(NSInteger, ZSPlayStatus) {
    playStatusBegin = 1,
    playStatusPlay  = 2,
    playStatusPause = 3,
    playStatusStop = 0,
    playStatusEnd   = 4,
    playStatusBackGround  = 5
};


@protocol ZSPlayerViewDelegate <NSObject>

@optional
- (void)videoLoadReadyToPlay;
- (void)videoLoadFailed;
- (void)videoLoadUnknown;
- (void)videoLoadedTimeRanges:(NSArray *)loadedTimeRanges;
- (void)videoPlaybackBufferEmpty;

- (void)movieToEnd;
- (void)movieJumped;
- (void)backGroundPauseMoive;

@end


@interface ZSPlayerView : UIView
@property (nonatomic, strong) id videoUrl;
@property (nonatomic, weak) id<ZSPlayerViewDelegate> delegate;

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign, readonly) float currentTimeValue;
@property (nonatomic, copy, readonly) NSString *currentTimeString;
@property (nonatomic, assign, readonly) float endTimeValue;
@property (nonatomic, copy, readonly) NSString *endTimeString;
@property (nonatomic, assign, readonly) ZSPlayStatus playStatus;

- (void)stopPlay;
- (void)pasue;
- (void)replay;
- (void)preparePlay;
- (void)play;
- (void)seekToTimeScale:(float)scale;
- (NSString *)getStringFromCMTime:(CMTime)time;
- (void)destroy;
@end



@protocol ZSPlayControlViewDelegate <NSObject>

- (void)controlUpInside;
- (void)sliderValueChanged:(CGFloat)value;
- (void)sliderUpInside:(CGFloat)value;

@end


// Mark - 播放控制器
@interface ZSPlayControlView : UIView
@property (nonatomic, strong, readonly) UIButton *controlBtn;  // 控制按钮
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;  // 当前播放时长
@property (nonatomic, strong, readonly) UILabel *endTimeLabel;  // 总时长
@property (nonatomic, strong, readonly) UISlider *progressView;  // 播放进度
@property (nonatomic, weak) id<ZSPlayControlViewDelegate> delegate;  // 代理
+ (NSString *)getVideoLengthFromTimeLength:(NSInteger)timeLength;
@end

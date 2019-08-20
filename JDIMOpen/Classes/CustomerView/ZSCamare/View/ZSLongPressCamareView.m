//
//  ZSLongPreeCamareView.m
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "ZSLongPressCamareView.h"
#import "ZSCamareView.h"
#import "ZSCircleProgress.h"
#import "ZSBaseUtil-Swift.h"
#import "FrameLayoutTool.h"
#import "UIImage+ProjectTool.h"
#import "UIColor+ProjectTool.h"
#import <ZSPreviewSDK/ZSPreviewSDK.h>

// Mark - 相机的操控图层
@interface ZSCamareMakeView : UIView
@property (nonatomic, strong) UIImageView *smallImageView;  // 小圈
@property (nonatomic, strong) UIImageView *backImageView;  // 背景图层
@property (nonatomic, strong) ZSCircleProgress *progressView;  // 进度
@property (nonatomic, strong) UIButton *closeBtn;  // 关闭按钮
@property (nonatomic, strong) UILabel *tipLabel;  // 提示信息
@end

@implementation ZSCamareMakeView

- (UIImageView *)smallImageView{
    if (!_smallImageView) {
        _smallImageView = [[UIImageView alloc] initWithImage:[UIImage img_setImageName:@"camare_long_press_small"]];
        _smallImageView.zs_w = 55 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _smallImageView.zs_h = 55 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        [self addSubview:_smallImageView];
    }
    return _smallImageView;
}

- (UIImageView *)backImageView{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage img_setImageName:@"camare_long_press_big"]];
        _backImageView.zs_w = 75 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _backImageView.zs_h = 75 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _backImageView.userInteractionEnabled = YES;
        [self addSubview:_backImageView];
    }
    return _backImageView;
}

- (ZSCircleProgress *)progressView{
    if (!_progressView) {
        _progressView = [ZSCircleProgress new];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progressWidth = 5 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _progressView.progressColor = [UIColor darkGreenColor];
        [self.backImageView insertSubview:_progressView atIndex:0];
    }
    return _progressView;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_closeBtn setImage:[UIImage img_setImageOriginalName:@"camare_back"] forState:UIControlStateNormal];
        [self addSubview:_closeBtn];
    }
    return _closeBtn;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.font = [FrameLayoutTool UnitFont:16];//KFONT(16);
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"轻触拍照，按住摄像";
        _tipLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _tipLabel.layer.shadowOffset = CGSizeMake(0, 0);
        _tipLabel.layer.shadowOpacity = 1;
        [self addSubview:_tipLabel];
        __weak typeof (self) weak_self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                weak_self.tipLabel.alpha = 0;
            }];
        });
    }
    return _tipLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.backImageView.frame = CGRectMake((self.width - self.backImageView.width) * 0.5, (self.height - _backImageView.height) * 0.5, _backImageView.width, _backImageView.height);
    self.backImageView.frame = CGRectMake((self.zs_w - self.backImageView.zs_w) * 0.5, (self.zs_h - _backImageView.zs_h) * 0.5, _backImageView.zs_w, _backImageView.zs_h);
    self.progressView.frame = _backImageView.bounds;
    //self.closeBtn.frame = CGRectMake(_backImageView.x - 62 * KUNIT_WIDTH - 27 * KUNIT_HEIGHT, self.height - 95 * KUNIT_HEIGHT, 27 * KUNIT_HEIGHT, 27 * KUNIT_HEIGHT);
    self.closeBtn.frame = CGRectMake(_backImageView.zs_x - 62 * FrameLayoutTool.UnitWidth - 27 * FrameLayoutTool.UnitHeight, self.zs_h - 95 * FrameLayoutTool.UnitHeight, 27 * FrameLayoutTool.UnitHeight, 27 * FrameLayoutTool.UnitHeight);
    //self.tipLabel.frame = CGRectMake(0, _backImageView.y - 50 * KUNIT_HEIGHT, self.width, 20 * KUNIT_HEIGHT);
    self.tipLabel.frame = CGRectMake(0, _backImageView.zs_y - 50 * FrameLayoutTool.UnitHeight, self.zs_w, 20 * FrameLayoutTool.UnitHeight);
    //self.smallImageView.frame = CGRectMake((self.width - self.smallImageView.width) * 0.5, (self.height - _smallImageView.height) * 0.5, _smallImageView.width, _smallImageView.height);
    self.smallImageView.frame = CGRectMake((self.zs_w - self.smallImageView.zs_w) * 0.5, (self.zs_h - _smallImageView.zs_h) * 0.5, _smallImageView.zs_w, _smallImageView.zs_h);
}
@end


// Mark - 拍摄完毕预览
@interface ZSCamarePreview : UIView<ZSPlayerViewDelegate>
@property (nonatomic, strong) UIImageView *photoPreview;  // 拍照预览
@property (nonatomic, strong) ZSPlayerView *playerPreview;  // 视频预览
@property (nonatomic, strong) UIButton *resetButton;  // 重新拍摄
@property (nonatomic, strong) UIButton *doneButton;  // 确认按钮
@end

@implementation ZSCamarePreview

- (UIImageView *)photoPreview{
    if (!_photoPreview) {
        _photoPreview = [UIImageView new];
        _photoPreview.hidden = YES;
        [self insertSubview:_photoPreview atIndex:0];
    }
    return _photoPreview;
}

- (ZSPlayerView *)playerPreview{
    if (!_playerPreview) {
        _playerPreview = [ZSPlayerView new];
        _playerPreview.hidden = YES;
        _playerPreview.delegate = self;
        [self insertSubview:_playerPreview atIndex:0];
    }
    return _playerPreview;
}

- (UIButton *)resetButton{
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_resetButton setImage:[UIImage img_setImageOriginalName:@"news_ back"] forState:UIControlStateNormal];
        [self addSubview:_resetButton];
    }
    return _resetButton;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneButton setImage:[UIImage img_setImageOriginalName:@"news_selected"] forState:UIControlStateNormal];
        [self addSubview:_doneButton];
    }
    return _doneButton;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.photoPreview.frame  = self.bounds;
    self.playerPreview.frame = self.bounds;
    //self.resetButton.frame = CGRectMake(_resetButton.x, self.height - 120 * KUNIT_HEIGHT, 80 * KUNIT_HEIGHT, 80 * KUNIT_HEIGHT);
    self.resetButton.frame = CGRectMake(_resetButton.zs_x, self.zs_h - 120 * FrameLayoutTool.UnitHeight, 80 * FrameLayoutTool.UnitHeight, 80 * FrameLayoutTool.UnitHeight);
    self.doneButton.frame = _resetButton.frame;
}

- (void)startAnimation{
    //_doneButton.center = CGPointMake((self.width - _doneButton.width) * 0.5, _doneButton.center.y);
    _doneButton.center = CGPointMake((self.zs_w - _doneButton.zs_w) * 0.5, _doneButton.center.y);
    //_resetButton.center = CGPointMake((self.width - _resetButton.width) * 0.5, _resetButton.center.y);
    _resetButton.center = CGPointMake((self.zs_w - _resetButton.zs_w) * 0.5, _resetButton.center.y);
    __weak typeof (self)weak_self = self;
    [UIView animateWithDuration:0.5 animations:^{
        weak_self.doneButton.center = CGPointMake(weak_self.zs_w / 4 * 3, weak_self.doneButton.center.y);
        weak_self.resetButton.center = CGPointMake(weak_self.zs_w / 4, weak_self.resetButton.center.y);
    }];
}

- (void)showPreviewMediaType:(ZSCamareMediaType)type mediaFile:(id)mediaFile {
    if (type == ZSCamareMediaVideo) {
        _playerPreview.hidden = NO;
        _photoPreview.hidden  = YES;
        _playerPreview.videoUrl = mediaFile;
        [_playerPreview preparePlay];
    }else{
        _playerPreview.hidden = YES;
        _photoPreview.hidden  = NO;
        _photoPreview.image = mediaFile;
    }
    [self startAnimation];
}

// Mark - ZSPlayerViewDelegate
- (void)videoLoadReadyToPlay {
    [_playerPreview play];
}

- (void)videoLoadFailed {
    
}

- (void)videoLoadUnknown {
    
}

- (void)movieToEnd {
    [_playerPreview replay];
}

@end


// Mark - 拍摄视图
@interface ZSLongPressCamareView ()<ZSCamareViewDelegate>
@property (nonatomic, strong) UIButton *switchCamare;  // 转换摄像头
@property (nonatomic, strong) ZSCamareMakeView *camareMakeView;  // 相机操作面板
@property (nonatomic, strong) ZSCamareView *camareView;  // 相机
@property (nonatomic, strong) ZSCamarePreview *preview;  // 预览图层

@property (nonatomic, assign) ZSCamareMediaType type;  // 媒体类型
@property (nonatomic, strong) id mediaFile;  // 媒体文件
@end


@implementation ZSLongPressCamareView

- (UIButton *)switchCamare{
    if (!_switchCamare) {
        _switchCamare = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCamare setImage:[UIImage img_setImageOriginalName:@"news_ swap"] forState:UIControlStateNormal];
        [_switchCamare addTarget:self action:@selector(switchCamareAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCamare];
    }
    return _switchCamare;
}

- (ZSCamareMakeView *)camareMakeView{
    if (!_camareMakeView) {
        _camareMakeView = [ZSCamareMakeView new];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.5;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        tap.numberOfTapsRequired = 1;
        
        [_camareMakeView.backImageView addGestureRecognizer:longPress];
        [_camareMakeView.backImageView addGestureRecognizer:tap];
        [_camareMakeView.closeBtn addTarget:self action:@selector(closeCamareAction) forControlEvents:UIControlEventTouchUpInside];
        [self.camareView addSubview:_camareMakeView];
    }
    return _camareMakeView;
}

- (ZSCamareView *)camareView{
    if (!_camareView) {
        _camareView = [[ZSCamareView alloc] initWithVideoModelType:ZSVideoModelTypeFullScreen recordMaxTime:10];
        _camareView.backgroundColor = [UIColor blackColor];
        _camareView.delegate = self;
        [self insertSubview:_camareView atIndex:0];
    }
    return _camareView;
}

- (ZSCamarePreview *)preview{
    if (!_preview) {
        _preview = [ZSCamarePreview new];
        _preview.backgroundColor = [UIColor blackColor];
        _preview.hidden = YES;
        [_preview.resetButton addTarget:self action:@selector(resetCamare) forControlEvents:UIControlEventTouchUpInside];
        [_preview.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_preview];
    }
    return _preview;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat statusBarH = FrameLayoutTool.IsIphoneXSeries ? 34 : 0;
    //(KABOVE_iPhoneX ? 34 : 0);
    //self.switchCamare.frame = CGRectMake(self.width - 53 * KUNIT_WIDTH, statusBarH + 10 * KUNIT_HEIGHT, 39 * KUNIT_WIDTH, 30 * KUNIT_HEIGHT);
    self.switchCamare.frame = CGRectMake(self.zs_w - 53 * FrameLayoutTool.UnitWidth, statusBarH + 10 * FrameLayoutTool.UnitHeight, 39 * FrameLayoutTool.UnitWidth, 30 * FrameLayoutTool.UnitHeight);
    self.camareView.frame = self.bounds;
    //self.camareMakeView.frame = CGRectMake(0, _camareView.height - 175 * KUNIT_HEIGHT, _camareView.width, 175 * KUNIT_HEIGHT);
    self.camareMakeView.frame = CGRectMake(0, _camareView.zs_h - 175 * FrameLayoutTool.UnitHeight, _camareView.zs_w, 175 * FrameLayoutTool.UnitHeight);
    self.preview.frame = self.bounds;
}

- (void)showPreview{
    _preview.hidden = NO;
    [_preview showPreviewMediaType:_type mediaFile:_mediaFile];
}

// Mark - RecordAction
- (void)longPress:(UIGestureRecognizer *)sender {  // 录像
    if (sender.state == UIGestureRecognizerStateBegan) {
        _camareMakeView.closeBtn.hidden = YES;
        __weak typeof (self) weak_self = self;
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.camareMakeView.backImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            weak_self.camareMakeView.smallImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        }];
        [_camareView startRecord];
    }else if (sender.state == UIGestureRecognizerStateEnded){
        __weak typeof (self) weak_self = self;
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.camareMakeView.backImageView.transform = CGAffineTransformMakeScale(1, 1);
            weak_self.camareMakeView.smallImageView.transform = CGAffineTransformMakeScale(1, 1);
        }];
        if (_camareView.recordState < ZSRecordStateFinish) {
            [_camareView stopRecord];
            [self recordFinish];
        }
    }
}

- (void)tapPress:(UIGestureRecognizer *)sender {  // 拍照
    _camareMakeView.userInteractionEnabled = NO;
    _camareMakeView.closeBtn.hidden = YES;
    
    CAKeyframeAnimation *backImgAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    backImgAni.duration = 0.3;
    backImgAni.values = @[@(1.1), @(1.2), @(1.1), @(1.0)];
    backImgAni.cumulative = NO;
    backImgAni.removedOnCompletion = NO;
    [_camareMakeView.backImageView.layer addAnimation:backImgAni forKey:@"Scale"];
    
    CAKeyframeAnimation *smallImgAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    smallImgAni.duration = 0.3;
    smallImgAni.values = @[@(0.9), @(0.8), @(0.9), @(1.0)];
    smallImgAni.cumulative = NO;
    smallImgAni.removedOnCompletion = NO;
    [_camareMakeView.smallImageView.layer addAnimation:smallImgAni forKey:@"Scale"];
    
    __weak typeof (self) weak_self = self;
    [_camareView takePicturesCompletionHandler:^(UIImage *img) {
        weak_self.mediaFile = img;
        weak_self.type = ZSCamareMediaImage;
        [weak_self showPreview];
    }];
}

// Mark - CamareMakeAction
- (void)closeCamareAction{
    [self.delegate closeCamareControll];
}

- (void)switchCamareAction{
    [_camareView turnCameraAction];
}

// Mark - PreviewAction
- (void)resetCamare{
    [_camareView resetRecord];
    [_preview.playerPreview destroy];
    _preview.hidden = YES;
    _camareMakeView.closeBtn.hidden = NO;
    _camareMakeView.progressView.progress = 0;
    _camareMakeView.userInteractionEnabled = YES;
}

- (void)done{
    [self.delegate camareFinish:_type mediaFile:_mediaFile];
}

// Mark - ZSCamareDelegate
- (void)updateFlashState:(ZSCamareFlashState)state {
    
}

- (void)updateRecordingProgress:(CGFloat)progress {
    _camareMakeView.progressView.progress = progress;
}

- (void)updateRecordingTime:(NSString *)time {
    
}

- (void)updateRecordState:(ZSRecordState)recordState {
    if (recordState == ZSRecordStateFinish) {
        NSLog(@"%@", _camareView.videoFilePath);
    }
}

- (void)recordFinish{
    _mediaFile = _camareView.videoFilePath;
    _type = ZSCamareMediaVideo;
    [self showPreview];
}

@end

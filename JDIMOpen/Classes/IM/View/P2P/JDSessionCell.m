//
//  JDSessionCell.m
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionCell.h"
#import "FrameLayoutTool.h"
#import "UIColor+ProjectTool.h"
#import "UIImage+ProjectTool.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "LiveModuleStringTool.h"
#import <Lottie/Lottie.h>
#import "LOTAnimationView+Tool.h"
#import "NSString+ProjectTool.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JDSessionCell ()
@property (nonatomic, strong) UILabel *dateLabel;  // 时间
@property (nonatomic, assign) CGSize dateTimeSize;  // 消息时间尺寸
@end


@implementation JDSessionCell

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [FrameLayoutTool UnitFont:12];
        //KFONT(12);
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor rgb139Color];
        _dateLabel.layer.cornerRadius = 3 * FrameLayoutTool.UnitHeight; //KUNIT_HEIGHT
        _dateLabel.clipsToBounds = YES;
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIButton *)retryButton{
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_retryButton setImage:[UIImage img_setImageOriginalName:@"news_ getfail"] forState:UIControlStateNormal];
        _retryButton.hidden = YES;
        [_retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_retryButton];
    }
    return _retryButton;
}

- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.hidesWhenStopped = NO;
        _activityView.hidden = YES;
        [self.contentView addSubview:_activityView];
    }
    return _activityView;
}

- (GIFImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [GIFImageView new];
        _avatarImageView.layer.cornerRadius = 5 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _avatarImageView.clipsToBounds = YES;
        [self.contentView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (GIFImageView *)contentImageView{
    if (!_contentImageView) {
        _contentImageView = [GIFImageView new];
        _contentImageView.userInteractionEnabled = YES;
        [self addLongPressMenu];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        tap.numberOfTapsRequired = 1;
        [_contentImageView addGestureRecognizer:tap];
        [self.contentView addSubview:_contentImageView];
    }
    return _contentImageView;
}

- (NSArray *)menuItems{
    if (_model.canMessageBeRevoked) {
        return @[
                 [[UIMenuItem alloc] initWithTitle:@"撤回"
                                            action:@selector(revoked:)]
                 ];
    }
    return nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self refreshUI];
    //CGFloat y = _dateLabel.maxY + 7 * KUNIT_HEIGHT;
    CGFloat y = _dateLabel.zs_maxY + 7 * FrameLayoutTool.UnitHeight;
    //self.avatarImageView.frame = CGRectMake(_avatarImageView.x, y, 40 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT);
    self.avatarImageView.frame = CGRectMake(_avatarImageView.zs_x, y, 40 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight);
    //CGFloat contentW = MAX(_contentImageView.width, 30 * KUNIT_WIDTH);
    CGFloat contentW = MAX(_contentImageView.zs_w, 30 * FrameLayoutTool.UnitWidth);
    //self.contentImageView.frame = CGRectMake(_contentImageView.x, y, contentW, MAX(_contentImageView.height, 40 * KUNIT_HEIGHT));
    self.contentImageView.frame = CGRectMake(_contentImageView.zs_x, y, contentW, MAX(_contentImageView.zs_h, 40 * FrameLayoutTool.UnitHeight));
    _contentImageView.hidden = NO;
    
    //self.retryButton.frame = CGRectMake(_retryButton.x, y + (_contentImageView.height - 30 * KUNIT_HEIGHT) * 0.5, 30 * KUNIT_HEIGHT, 30 * KUNIT_HEIGHT);
    self.retryButton.frame = CGRectMake(_retryButton.zs_x, y + (_contentImageView.zs_h - 30 * FrameLayoutTool.UnitHeight) * 0.5, 30 * FrameLayoutTool.UnitHeight, 30 * FrameLayoutTool.UnitHeight);
    self.activityView.frame = _retryButton.frame;
    //self.dateLabel.frame = CGRectMake((self.contentView.width - _dateLabel.width) * 0.5, _dateLabel.y, _dateLabel.width, _dateLabel.height);
    self.dateLabel.frame = CGRectMake((self.contentView.zs_w - _dateLabel.zs_w) * 0.5, _dateLabel.zs_y, _dateLabel.zs_w, _dateLabel.zs_h);
}

- (void)refreshUI{
    //CGFloat avatarX = _model.isMySelf ? (self.contentView.width - 10 * KUNIT_WIDTH - 40 * KUNIT_HEIGHT) : 10 * KUNIT_WIDTH;
    CGFloat avatarX = _model.isMySelf ? (self.contentView.zs_w - 10 * FrameLayoutTool.UnitWidth - 40 * FrameLayoutTool.UnitHeight) : 10 * FrameLayoutTool.UnitWidth;
    self.avatarImageView.zs_x = avatarX;
    
    CGFloat contentW = MAX(_contentImageView.zs_w, 30 * FrameLayoutTool.UnitWidth);
    //CGFloat contentX = _model.isMySelf ? (_avatarImageView.x - 6 * KUNIT_WIDTH - contentW) : _avatarImageView.maxX + 6 * KUNIT_WIDTH;
    CGFloat contentX = _model.isMySelf ? (_avatarImageView.zs_x - 6 * FrameLayoutTool.UnitWidth - contentW) : _avatarImageView.zs_maxX + 6 * FrameLayoutTool.UnitWidth;
    self.contentImageView.zs_x = contentX;
    
    NSString *imgName = _model.isMySelf ? @"news_bubble" : @"news_bubble2";
    _contentImageView.image = [[UIImage img_setImageName:imgName] img_resizableWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 10)];
    
    //CGFloat retryX =  _model.isMySelf ? (_contentImageView.x - 30 * KUNIT_HEIGHT) : _contentImageView.maxX;
    CGFloat retryX =  _model.isMySelf ? (_contentImageView.zs_x - 30 * FrameLayoutTool.UnitHeight) : _contentImageView.zs_maxX;
    self.retryButton.zs_x = retryX;
}

- (void)setTimestamp:(NSTimeInterval)timestamp{
    _timestamp = timestamp;
    if (timestamp == 0) {
        _dateTimeSize = CGSizeZero;
    }else{
        NSString *dateTime = [LiveModuleStringTool getTimeFrame:timestamp showOclock:YES hideTodayOclock:NO timingMode:TimingMode_24];
        //[ZSStringTool getTimeFrame:timestamp showOclock:YES hideTodayOclock:NO timingMode:ZSTimingMode_24];
        self.dateLabel.text = dateTime;
        //_dateTimeSize = [dateTime sizeWithFont:KFONT(12) maxSize:CGSizeMake(MAXFLOAT, 24 * KUNIT_HEIGHT)];
        _dateTimeSize = [dateTime zs_sizeWithFont:[FrameLayoutTool UnitFont:12] textMaxSize:CGSizeMake(MAXFLOAT, 24*FrameLayoutTool.UnitHeight)];
    }
    
    CGFloat dateTimeW = (timestamp > 0 ? (_dateTimeSize.width + 20 * FrameLayoutTool.UnitWidth) : 0);
    CGFloat dateTimeH = timestamp > 0 ? 24 * FrameLayoutTool.UnitHeight : 0;
    CGFloat dateTimeY = timestamp > 0 ? 18 * FrameLayoutTool.UnitHeight : 0;
    self.dateLabel.frame = CGRectMake((self.contentView.zs_w - dateTimeW) * 0.5, dateTimeY, dateTimeW, dateTimeH);
    _dateLabel.hidden = !timestamp;
}

- (void)setModel:(JDSessionModel *)model{
    _model = model;
    self.retryButton.hidden = !_model.isSendError;
    self.activityView.hidden = !_model.isSending;
    [self layoutSubviews];
    _model.isSending ? [_activityView startAnimating] : [_activityView stopAnimating];
}

- (void)addLongPressMenu{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5;
    [_contentImageView addGestureRecognizer:longPress];
}

- (void)addMenuItems{
    [self becomeFirstResponder];
    UIMenuController *controller = [UIMenuController sharedMenuController];
    controller.menuItems = [self menuItems];
    [controller setTargetRect:_contentImageView.bounds inView:_contentImageView];
    [controller setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (![sender isKindOfClass:[UIMenuController class]]) {
        return NO;
    }
    
    if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(revoked:)) {
        return YES;
    }
    return NO;
}

// Mark - press
- (void)longPress:(UIGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self addMenuItems];
    }
}

- (void)tapPress:(UIGestureRecognizer *)sender {
    [self.delegate didSelectCellAtMessage:_model];
}

// Mark - retryAction
- (void)retryAction{
    [self.delegate onRetryMessage:_model];
}

// Mark - menuAction
- (void)revoked:(id)sender{
    [self.delegate onRevokedMessage:_model];
}

@end




// Mark - 文本消息
@interface JDSessionTextView : UITextView
@property (nonatomic, assign) BOOL canMessageBeRevoked;  // 是否可以撤回
@property (nonatomic, copy) void (^didSelectedRevoked)(void);  // 撤回的回调
@property (nonatomic, copy) void (^didSelectedCopy)(void);  // 复制的回调
@end

@implementation JDSessionTextView

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (![sender isKindOfClass:[UIMenuController class]]) {
        return NO;
    }
    
    if (_canMessageBeRevoked) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems =
        @[
          [[UIMenuItem alloc] initWithTitle:@"撤回"
                                     action:@selector(revoked:)]
          ];
    }
    
    if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(selectAll:)) {
        return YES;
    } else if (action == @selector(revoked:)) {
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender{
    if (_didSelectedCopy) {
        _didSelectedCopy();
    }
}

- (void)revoked:(id)sender{
    if (_didSelectedRevoked) {
        _didSelectedRevoked();
    }
}

@end


// Mark - 文本消息
@interface JDSessionTextCell ()<UITextViewDelegate>
@property (nonatomic, strong) JDSessionTextView *contentTextView;  // 消息内容
@end

@implementation JDSessionTextCell

- (JDSessionTextView *)contentTextView{
    if (!_contentTextView) {
        _contentTextView = [JDSessionTextView new];
        _contentTextView.scrollEnabled = NO;
        _contentTextView.editable = NO;
        _contentTextView.font = [FrameLayoutTool UnitFont:15]; //KFONT(15);
        _contentTextView.delegate = self;
        _contentTextView.backgroundColor = [UIColor clearColor];
        _contentTextView.showsVerticalScrollIndicator = NO;
        _contentTextView.showsHorizontalScrollIndicator = NO;
        _contentTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        _contentTextView.textContainer.lineFragmentPadding = 0;
        _contentTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
        __weak typeof (self) weak_self = self;
        _contentTextView.didSelectedRevoked = ^{
            [weak_self.delegate onRevokedMessage:weak_self.model];
        };
        _contentTextView.didSelectedCopy = ^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSObject zs_paramsValue:weak_self.model.message.text];
        };
        [self.contentImageView addSubview:_contentTextView];
    }
    return _contentTextView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentTextView.frame = CGRectMake(self.model.isMySelf ? 0 : 5 * FrameLayoutTool.UnitWidth, 0, self.contentImageView.zs_w - 5 * FrameLayoutTool.UnitWidth, self.contentImageView.zs_h);
    //CGRectMake(self.model.isMySelf ? 0 : 5 * KUNIT_WIDTH, 0, self.contentImageView.width - 5 * KUNIT_WIDTH, self.contentImageView.height);
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    self.contentTextView.canMessageBeRevoked = model.canMessageBeRevoked;
    //self.contentImageView.width = model.textSize.width + 5 * KUNIT_WIDTH + 2 * _contentTextView.textContainerInset.left;
    self.contentImageView.zs_w = model.textSize.width + 5 * FrameLayoutTool.UnitWidth + 2 * _contentTextView.textContainerInset.left;
    //self.contentImageView.height = model.textSize.height + 2 * _contentTextView.textContainerInset.top;
    self.contentImageView.zs_h = model.textSize.height + 2 * _contentTextView.textContainerInset.top;
    self.contentTextView.attributedText = model.attributeText;
    self.contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (BOOL)canOpenUrlLink:(NSURL *)url{
    BOOL canOpen = url.host != nil;
    
    if (canOpen) {
        for (UIGestureRecognizer *gesture in _contentTextView.gestureRecognizers) {
            if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
                canOpen = gesture.state != UIGestureRecognizerStateBegan;
                break;
            }
        }
        
        if (canOpen) {
            // App内部跳转的回调
            [self.delegate onOpenLink:url];
        }
    }
    return canOpen;
}

- (void)addLongPressMenu{ }

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

- (void)showMenu:(NSRange)range{
    _contentTextView.selectedRange = range;
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

// Mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{

    return ![self canOpenUrlLink:URL];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)){

    return ![self canOpenUrlLink:URL];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0){
    [self showMenu:characterRange];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
    [self showMenu:characterRange];
    return NO;
}
@end




// Mark - 语音消息
@interface JDSessionAudioCell ()
@property (nonatomic, strong) UIImageView *audioImageView;  // 语音的图标
@property (nonatomic, strong) UILabel *timeLabel;  // 语音时间
@property (nonatomic, strong) UILabel *unreadLabel;  // 语音未读标识
@property (nonatomic, strong) LOTAnimationView *animation;  // 语音动画
@end

@implementation JDSessionAudioCell

- (UIImageView *)audioImageView{
    if (!_audioImageView) {
        _audioImageView = [[UIImageView alloc] init];
        [self.contentImageView addSubview:_audioImageView];
    }
    return _audioImageView;
}

- (UILabel *)unreadLabel{
    if (!_unreadLabel) {
        _unreadLabel = [UILabel new];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.clipsToBounds = YES;
        [self.contentView addSubview:_unreadLabel];
    }
    return _unreadLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [FrameLayoutTool UnitFont:14]; //KFONT(14);
        _timeLabel.textColor = [UIColor rgb139Color];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //CGFloat audioImgX = self.model.isMySelf ? self.contentImageView.width - 28 * KUNIT_WIDTH : 14 * KUNIT_WIDTH;
    CGFloat audioImgX = self.model.isMySelf ? self.contentImageView.zs_w - 28 * FrameLayoutTool.UnitWidth : 14 * FrameLayoutTool.UnitWidth;
    //self.audioImageView.frame = CGRectMake(audioImgX, (self.contentImageView.height - 20 * KUNIT_HEIGHT) * 0.5, 14 * KUNIT_WIDTH, 20 * KUNIT_HEIGHT);
    self.audioImageView.frame = CGRectMake(audioImgX, (self.contentImageView.zs_h - 20 * FrameLayoutTool.UnitHeight) * 0.5, 14 * FrameLayoutTool.UnitWidth, 20 * FrameLayoutTool.UnitHeight);
    _animation.frame = _audioImageView.frame;
    //CGFloat timeX = self.model.isMySelf ? self.contentImageView.x - 8 * KUNIT_WIDTH - _timeLabel.width : self.contentImageView.maxX + 8 * KUNIT_WIDTH;
    CGFloat timeX = self.model.isMySelf ? self.contentImageView.zs_x - 8 * FrameLayoutTool.UnitWidth - _timeLabel.zs_w : self.contentImageView.zs_maxX + 8 * FrameLayoutTool.UnitWidth;
    //self.timeLabel.frame = CGRectMake(timeX, self.contentImageView.y + (self.contentImageView.height - 20 * KUNIT_HEIGHT) * 0.5, _timeLabel.width, 20 * KUNIT_HEIGHT);
    self.timeLabel.frame = CGRectMake(timeX, self.contentImageView.zs_y + (self.contentImageView.zs_h - 20 * FrameLayoutTool.UnitHeight) * 0.5, _timeLabel.zs_w, 20 * FrameLayoutTool.UnitHeight);
    //CGFloat unreadX = self.model.isMySelf ? _timeLabel.x - 5 * KUNIT_WIDTH - 8 * KUNIT_HEIGHT : _timeLabel.maxX + 5 * KUNIT_WIDTH;
    CGFloat unreadX = self.model.isMySelf ? _timeLabel.zs_x - 5 * FrameLayoutTool.UnitWidth - 8 * FrameLayoutTool.UnitHeight : _timeLabel.zs_maxX + 5 * FrameLayoutTool.UnitWidth;
    //self.unreadLabel.frame = CGRectMake(unreadX, self.contentImageView.y + (self.contentImageView.height - 8 * KUNIT_HEIGHT) * 0.5, 8 * KUNIT_HEIGHT, 8 * KUNIT_HEIGHT);
    self.unreadLabel.frame = CGRectMake(unreadX, self.contentImageView.zs_y + (self.contentImageView.zs_h - 8 * FrameLayoutTool.UnitHeight) * 0.5, 8 * FrameLayoutTool.UnitHeight, 8 * FrameLayoutTool.UnitHeight);
    //_unreadLabel.layer.cornerRadius = 8 * KUNIT_HEIGHT * 0.5;
    _unreadLabel.layer.cornerRadius = 8 * FrameLayoutTool.UnitHeight * 0.5;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (![sender isKindOfClass:[UIMenuController class]]) {
        return NO;
    }
    
    if (action == @selector(revoked:)) {
        return YES;
    }
    return NO;
}

- (void)refreshUI{
    [super refreshUI];
    self.audioImageView.image = [UIImage img_setImageName:self.model.isMySelf ? @"news_ Voice Chat" : @"news_ Voice Chat4"];
}

- (void)startAnimation{
    if (!_animation.isAnimationPlaying) {
        NSString *name = self.model.isMySelf ? @"news_voice_right" : @"news_voice_left";
        _animation = [LOTAnimationView animationWithFilePath:[LOTAnimationView animationFilePathFromFlieName:name]];
        _animation.loopAnimation = YES;
        [_animation play];
        _audioImageView.hidden = YES;
        [self.contentImageView addSubview:_animation];
    }
}

- (void)stopAnimation{
    [_animation stop];
    _audioImageView.hidden = NO;
    [_animation removeFromSuperview];
    _animation = nil;
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    self.contentImageView.zs_w = model.audioWidth;
    self.timeLabel.text = model.messageObjectModel.timeString;
    _timeLabel.zs_w = [model.messageObjectModel.timeString zs_sizeWithFont:[FrameLayoutTool UnitFont:14] textMaxSize:CGSizeMake(MAXFLOAT, 20 * FrameLayoutTool.UnitHeight)].width;
    //[model.messageObjectModel.timeString sizeWithFont:KFONT(14) maxSize:CGSizeMake(MAXFLOAT, 20 * KUNIT_HEIGHT)].width;
    _timeLabel.hidden = (model.isSending || model.isSendError);
    self.unreadLabel.hidden = (model.isAudioPlayed || model.isMySelf);
    model.isAnimation ? [self startAnimation] : [self stopAnimation];
}

@end




// Mark - 图片消息
@interface JDSessionImageCell ()
@property (nonatomic, strong) LOTAnimationView *progress;  // 发送进度动画
@property (nonatomic, strong) GIFImageView *sessionImageView;  // 图片
@end

@implementation JDSessionImageCell

- (GIFImageView *)sessionImageView{
    if (!_sessionImageView) {
        _sessionImageView = [GIFImageView new];
        _sessionImageView.backgroundColor = [UIColor blackColor];
        _sessionImageView.clipsToBounds = YES;
        _sessionImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sessionImageView.layer.cornerRadius = 5 * FrameLayoutTool.UnitHeight; //KUNIT_HEIGHT;
        [self.contentImageView addSubview:_sessionImageView];
    }
    return _sessionImageView;
}

- (LOTAnimationView *)progress{
    if (!_progress) {
        _progress = [LOTAnimationView animationWithFilePath:[LOTAnimationView animationFilePathFromFlieName:@"news_video_loading"]];
        _progress.hidden = YES;
        [self.sessionImageView addSubview:_progress];
    }
    return _progress;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.sessionImageView.frame = self.contentImageView.bounds;
    //_progress.frame = CGRectMake((_sessionImageView.width - 40 * KUNIT_HEIGHT) * 0.5, (_sessionImageView.height - 40 * KUNIT_HEIGHT) * 0.5, 40 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT);
    _progress.frame = CGRectMake((_sessionImageView.zs_w - 40 * FrameLayoutTool.UnitHeight) * 0.5, (_sessionImageView.zs_h - 40 * FrameLayoutTool.UnitHeight) * 0.5, 40 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight);
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    self.activityView.hidden = YES;
    
    BOOL isVertical = [model.messageObjectModel.h floatValue] >= [model.messageObjectModel.w floatValue];  // 是否是竖屏媒体
    //CGFloat height = (isVertical ? 141 * KUNIT_HEIGHT : 82 * KUNIT_HEIGHT);
    CGFloat height = (isVertical ? 141 * FrameLayoutTool.UnitHeight : 82 * FrameLayoutTool.UnitHeight);
    //CGFloat width  = (isVertical ? 82 * KUNIT_HEIGHT : 141 * KUNIT_HEIGHT);
    CGFloat width  = (isVertical ? 82 * FrameLayoutTool.UnitHeight : 141 * FrameLayoutTool.UnitHeight);
    self.contentImageView.zs_w  = width;
    self.contentImageView.zs_h = height;
    
    self.progress.hidden = !model.isSending;
    self.progress.animationProgress = model.progress;
    if (model.isMySelf) {
        self.sessionImageView.image = [UIImage imageWithContentsOfFile:(model.thumbPath ? model.thumbPath : model.coverPath)];
    }else{
        [self.sessionImageView sd_setImageWithURL:model.thumbUrl ? model.thumbUrl.URLWithString : model.coverUrl.URLWithString placeholderImage:[UIImage imgLogoGrayscaleSquare]];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (![sender isKindOfClass:[UIMenuController class]]) {
        return NO;
    }
    
    if (action == @selector(revoked:)) {
        return YES;
    }
    return NO;
}

@end



// Mark - 视频消息
@interface JDSessionVideoCell ()
@property (nonatomic, strong) UILabel *timeLabel;  // 视频时长
@property (nonatomic, strong) LOTAnimationView *animation;  // 视频导出动画
@property (nonatomic, strong) GIFImageView *playImageView;  // 播放图标
@end

@implementation JDSessionVideoCell

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [FrameLayoutTool UnitFont:9]; //KFONT(9);
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _timeLabel.layer.shadowOffset = CGSizeMake(0, 0);
        _timeLabel.layer.shadowOpacity = 1;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.sessionImageView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (GIFImageView *)playImageView{
    if (!_playImageView) {
        _playImageView = [[GIFImageView alloc] initWithImage:[UIImage img_setImageName:@"news_play"]];
        [self.sessionImageView insertSubview:_playImageView atIndex:0];
    }
    return _playImageView;
}

- (void)startAnimation{
    if (!_animation.isAnimationPlaying) {
        _animation = [LOTAnimationView animationWithFilePath:[LOTAnimationView animationFilePathFromFlieName:@"news_video_loading1"]];
        _animation.loopAnimation = YES;
        [_animation play];
        [self.sessionImageView addSubview:_animation];
    }
}

- (void)stopAnimation{
    [_animation stop];
    [_animation removeFromSuperview];
    _animation = nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //self.timeLabel.frame = CGRectMake(0, self.sessionImageView.height - 13 * KUNIT_HEIGHT, self.sessionImageView.width - 3 * KUNIT_WIDTH, 10 * KUNIT_HEIGHT);
    self.timeLabel.frame = CGRectMake(0, self.sessionImageView.zs_h - 13 * FrameLayoutTool.UnitHeight, self.sessionImageView.zs_w - 3 * FrameLayoutTool.UnitWidth, 10 * FrameLayoutTool.UnitHeight);
    //self.playImageView.frame = CGRectMake((self.sessionImageView.width - 40 * KUNIT_HEIGHT) * 0.5, (self.sessionImageView.height - 40 * KUNIT_HEIGHT) * 0.5, 40 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT);
    self.playImageView.frame = CGRectMake((self.sessionImageView.zs_w - 40 * FrameLayoutTool.UnitHeight) * 0.5, (self.sessionImageView.zs_h - 40 * FrameLayoutTool.UnitHeight) * 0.5, 40 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight);
    self.animation.frame = _playImageView.frame;
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    model.isExport ? [self startAnimation] : [self stopAnimation];
    self.playImageView.hidden = model.isSending || model.isExport;
    self.timeLabel.hidden = model.isExport;
    self.timeLabel.text = model.messageObjectModel.timeString;
}

@end

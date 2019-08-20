//
//  JDInputToolBar.m
//  JadeKing
//
//  Created by 张森 on 2018/9/25.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDInputToolBar.h"
#import "GIFImageView.h"
#import "CustomButton.h"
#import "ZSBaseUtil-Swift.h"
#import "FrameLayoutTool.h"
#import "UIImage+ProjectTool.h"
#import "UIColor+ProjectTool.h"
#import "JDIMTool.h"
#import <AVFoundation/AVFoundation.h>

// Mark - 录制语音的提示框
@interface JDRecordTipView : UIView
@property (nonatomic, strong) GIFImageView *imageVew;  // 图片
@property (nonatomic, strong) UILabel *descLabel;  // 文字描述
- (void)recordErrorTip;
- (void)updateDescLabelStatus:(BOOL)isCancel;
@end


// Mark - emoji底部操作视图
@interface JDEmojiBottomToolView : UIView
@property (nonatomic, strong) UIButton *emojiBtn;  // emoji表情按钮
@property (nonatomic, strong) UIButton *sendBtn;  // 发送按钮
@end


// Mark - emoji操作板
@interface JDEmojiBoard : UIView<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *emojiScrollView;  // emoji表情集合
@property (nonatomic, strong) JDEmojiBottomToolView *bottomToolView;  // 底部操作视图
@property (nonatomic, strong) UIPageControl *pageControl;  // 页码
@property (nonatomic, copy) NSArray *emojiArray;  // emoji表情组
@property (nonatomic, copy) void(^didSelectedEmoji)(NSString *tag);  // 选中emoji的回调
@property (nonatomic, copy) void(^didSelectedSend)(void);  // 点击发送的回调
@end


// Mark - 更多操作板
@interface JDMoreBoard : UIView
@property (nonatomic, strong) CustomButton *albumBtn;  // 相册
@property (nonatomic, strong) CustomButton *cameraBtn;  // 相机
@property (nonatomic, strong) CustomButton *adviceBtn;  // 投诉建议
@property (nonatomic, copy) void(^didSelectedAlbum)(void);  // 调取相册
@property (nonatomic, copy) void(^didSelectedCamera)(void);  // 调取相机
@property (nonatomic, copy) void(^didSelectedAdvice)(void);  // 调取投诉建议
@end


// Mark - InputToolBar
@interface JDInputToolBar ()<UITextViewDelegate, ZSNoticeToolDelegate>
@property (nonatomic, strong) UIView *toolView;  // 可操作区域
@property (nonatomic, strong) UIButton *audioBtn;  // 语音
@property (nonatomic, strong) UIButton *recordBtn;  // 录制按钮
@property (nonatomic, strong) UITextView *textView;  // 文本输入框
@property (nonatomic, strong) UIButton *emoticonBtn;  // 表情输入框
@property (nonatomic, strong) UIButton *moreBtn;  // 更多功能输入框
@property (nonatomic, strong) UIButton *toolSelectBtn;  // 当前被选择的功能按钮
@property (nonatomic, strong) JDRecordTipView *recordTipView;  // 语音录制的提示窗
@property (nonatomic, strong) JDEmojiBoard *emojiBoard;  // emoji操作板
@property (nonatomic, strong) JDMoreBoard *moreBoard;  // 更多操作板
@property (nonatomic, strong) ZSNoticeTool *noticeTool;  // 通知tool
@property (nonatomic, assign) BOOL isRecordOutside;  // 手指是否上滑要取消录制
@property (nonatomic, assign) CGFloat textViewH;  // textView的高度
@property (nonatomic, assign) CGFloat boardH;  // board的高度
@property (nonatomic, assign) CGFloat toolViewH;  // 工具栏的高度

@property (nonatomic, strong) NSTimer *timer;  // 定时器
@property (nonatomic, assign) NSInteger second;  // 倒计时秒
@property (nonatomic, assign) BOOL isShowOtherBoard;  // 是否展示其他的操作盘
@end


@implementation JDInputToolBar

+ (instancetype)new{
    return [[self alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        [self.noticeTool addAllObservers];
    }
    return self;
}

- (UIView *)toolView{
    if (!_toolView) {
        _toolView = [UIView new];
        _toolViewH = toolBarH * FrameLayoutTool.UnitHeight; //KUNIT_HEIGHT;
        [self addSubview:_toolView];
    }
    return _toolView;
}

- (UIButton *)audioBtn{
    if (!_audioBtn) {
        _audioBtn = [self createBtn:[UIImage img_setImageOriginalName:@"news_ voice"]];
        _audioBtn.restorationIdentifier = @"switchRecord";
    }
    return _audioBtn;
}

- (UIButton *)emoticonBtn{
    if (!_emoticonBtn) {
        _emoticonBtn = [self createBtn:[UIImage img_setImageOriginalName:@"news_eif"]];
        _emoticonBtn.restorationIdentifier = @"switchEmotion";
    }
    return _emoticonBtn;
}

- (UIButton *)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [self createBtn:[UIImage img_setImageOriginalName:@"news_add"]];
        _moreBtn.restorationIdentifier = @"switchMore";
    }
    return _moreBtn;
}

- (UIButton *)createBtn:(UIImage *)image{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = [UIColor clearColor];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:[UIImage img_setImageOriginalName:@"news_key"] forState:UIControlStateSelected];
    button.zs_w  = 29 * FrameLayoutTool.UnitHeight; //KUNIT_HEIGHT;
    button.zs_h = 29 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    [button addTarget:self action:@selector(switchTool:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:button];
    return button;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [UITextView new];
        _textView.font = [FrameLayoutTool UnitFont:18];//KFONT(18);
        _textView.delegate = self;
        _textViewH = 32 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _textView.textColor = [UIColor rgb51Color];
        _textView.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0]; //KCOLOR(239, 239, 239, 1);
        _textView.layer.cornerRadius = 5 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.textContainerInset = UIEdgeInsetsMake(8*FrameLayoutTool.UnitHeight, 0, 8*FrameLayoutTool.UnitHeight, 0);
        // UIEdgeInsetsMake(8 * KUNIT_HEIGHT, 0, 8 * KUNIT_HEIGHT, 0);
        [self.toolView addSubview:_textView];
    }
    return _textView;
}

- (UIButton *)recordBtn{
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor rgb82Color] forState:UIControlStateNormal];
        if (@available(iOS 9.0, *)) {
            [_recordBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:16 * FrameLayoutTool.UnitHeight]]; //KUNIT_HEIGHT
        } else {
            [_recordBtn.titleLabel setFont:[UIFont fontWithName:@"HiraginoSansGB-W3" size:16 * FrameLayoutTool.UnitHeight]]; //KUNIT_HEIGHT
        }
        _recordBtn.hidden = YES;
        _recordBtn.backgroundColor = [UIColor whiteColor];
        _recordBtn.layer.cornerRadius = 5 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _recordBtn.layer.borderColor = [UIColor rgb194Color].CGColor;
        _recordBtn.layer.borderWidth = 0.5;
        
        [_recordBtn addTarget:self action:@selector(onTouchRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(onTouchRecordBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtn addTarget:self action:@selector(onTouchRecordBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_recordBtn addTarget:self action:@selector(onTouchRecordBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
        [_recordBtn addTarget:self action:@selector(onTouchRecordBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [self.toolView addSubview:_recordBtn];
    }
    return _recordBtn;
}

- (JDRecordTipView *)recordTipView{
    if (!_recordTipView) {
        _recordTipView = [JDRecordTipView new];
        _recordTipView.hidden = YES;
        _recordTipView.frame = CGRectMake((FrameLayoutTool.Width-163*FrameLayoutTool.UnitHeight)*0.5, (FrameLayoutTool.Height-163*FrameLayoutTool.UnitHeight)*0.5, 163*FrameLayoutTool.UnitHeight, 163*FrameLayoutTool.UnitHeight);
        //CGRectMake((KSWIDTH - 163 * KUNIT_HEIGHT) * 0.5, (KSHEIGHT - 163 * KUNIT_HEIGHT) * 0.5, 163 * KUNIT_HEIGHT, 163 * KUNIT_HEIGHT);
        _recordTipView.backgroundColor = [UIColor colorWithRed:67.0/255 green:67.0/255 blue:67.0/255 alpha:1.0];
        //KCOLOR(67, 67, 67, 0.8);
        _recordTipView.layer.cornerRadius = 8 * FrameLayoutTool.UnitHeight;
        //KUNIT_HEIGHT;
        _recordTipView.clipsToBounds = YES;
        [_recordTipView addSubviewToControllerView];
    }
    return _recordTipView;
}

- (JDEmojiBoard *)emojiBoard{
    if (!_emojiBoard) {
        _emojiBoard = [JDEmojiBoard new];
        _emojiBoard.hidden = YES;
        __weak typeof (self) weak_self = self;
        _emojiBoard.didSelectedEmoji = ^(NSString *tag) {
            [weak_self didSelectedEmoji:tag];
        };
        _emojiBoard.didSelectedSend = ^{
            [weak_self sendMsg];
        };
        _emojiBoard.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
        //KCOLOR(239, 239, 239, 1);
        [self addSubview:_emojiBoard];
    }
    return _emojiBoard;
}

- (JDMoreBoard *)moreBoard{
    if (!_moreBoard) {
        _moreBoard = [JDMoreBoard new];
        _moreBoard.hidden = YES;
        _moreBoard.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
        //KCOLOR(239, 239, 239, 1);
        __weak typeof (self) weak_self = self;
        _moreBoard.didSelectedAlbum = ^{
            [weak_self.delegate didSelectedAlbum];
        };
        _moreBoard.didSelectedCamera = ^{
            [weak_self.delegate didSelectedCamera];
        };
        _moreBoard.didSelectedAdvice = ^{
            [weak_self.delegate didSelectedAdvice];
        };
        [self addSubview:_moreBoard];
    }
    return _moreBoard;
}

- (ZSNoticeTool *)noticeTool{
    if (!_noticeTool) {
        _noticeTool = [ZSNoticeTool new];
        _noticeTool.delegate = self;
    }
    return _noticeTool;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.toolView.frame = CGRectMake(0, 0, self.zs_w, _toolViewH);//CGRectMake(0, 0, self.width, _toolViewH);
    
    self.audioBtn.frame = CGRectMake(12 * FrameLayoutTool.UnitWidth, 10 * FrameLayoutTool.UnitHeight, self.audioBtn.zs_w, self.audioBtn.zs_h);
    //CGRectMake(12 * KUNIT_WIDTH, 10 * KUNIT_HEIGHT, self.audioBtn.width, self.audioBtn.height);
    
    self.moreBtn.frame = CGRectMake(_toolView.zs_w - self.moreBtn.zs_w - 12 * FrameLayoutTool.UnitWidth, _audioBtn.zs_y, _moreBtn.zs_w, _moreBtn.zs_h);
    //CGRectMake(_toolView.width - self.moreBtn.width - 12 * KUNIT_WIDTH, _audioBtn.y, _moreBtn.width, _moreBtn.height);
    
    self.emoticonBtn.frame = CGRectMake(_moreBtn.zs_x-self.emoticonBtn.zs_w-7*FrameLayoutTool.UnitWidth, _audioBtn.zs_y, _emoticonBtn.zs_w, _emoticonBtn.zs_h);
    // CGRectMake(_moreBtn.x - self.emoticonBtn.width - 7 * KUNIT_WIDTH, _audioBtn.y, _emoticonBtn.width, _emoticonBtn.height);
    self.textView.frame = CGRectMake(_audioBtn.zs_maxX + 9 * FrameLayoutTool.UnitWidth, 5 * FrameLayoutTool.UnitHeight, _emoticonBtn.zs_x - _audioBtn.zs_maxX - 18 * FrameLayoutTool.UnitWidth, MAX(40 * FrameLayoutTool.UnitHeight, _textViewH));
    //CGRectMake(_audioBtn.maxX + 9 * KUNIT_WIDTH, 5 * KUNIT_HEIGHT, _emoticonBtn.x - _audioBtn.maxX - 18 * KUNIT_WIDTH, MAX(40 * KUNIT_HEIGHT, _textViewH));
    
    self.recordBtn.frame = CGRectMake(_textView.zs_x, 5 * FrameLayoutTool.UnitHeight, _textView.zs_w, 40 * FrameLayoutTool.UnitHeight);
    //CGRectMake(_textView.x, 5 * KUNIT_HEIGHT, _textView.width, 40 * KUNIT_HEIGHT);
    
    self.emojiBoard.frame = CGRectMake(0, self.zs_h - _boardH, self.zs_w, 230 * FrameLayoutTool.UnitHeight + FrameLayoutTool.HomeBtnHeight);
    //CGRectMake(0, self.height - _boardH, self.width, 230 * KUNIT_HEIGHT + KHOME_HEIGHT);
    self.moreBoard.frame = CGRectMake(0, self.zs_h - _boardH, self.zs_w, 186 * FrameLayoutTool.UnitHeight + FrameLayoutTool.HomeBtnHeight);
    //CGRectMake(0, self.height - _boardH, self.width, 186 * KUNIT_HEIGHT + KHOME_HEIGHT);
}

- (void)sendMsg{
    [self.delegate didSelectedSendMsg:_textView.text];
    _textView.text = nil;
    [self textViewDidChange:_textView];
}

- (void)updateRecordUIFromPower:(NSInteger)power{
    NSString *imgName = @"news_service_ voice";
    if (_isRecordOutside) {
        imgName = @"service_ cancel sending";
    }else if(power < -25){
        imgName = [imgName stringByAppendingString:@"1"];
    }else if (power < -15) {
        imgName = [imgName stringByAppendingString:@"2"];
    }else if (power < -10){
        imgName = [imgName stringByAppendingString:@"3"];
    }else {
        imgName = [imgName stringByAppendingString:@"4"];
    }
    _recordTipView.imageVew.image = [UIImage img_setImageName:imgName];
}

// Mark - ZSNoticeToolDelegate
- (void)keyboardWillShowFrame:(CGRect)keyboardFrame{
    _boardH = keyboardFrame.size.height;
    _isShowOtherBoard = NO;
    __weak typeof (self) weak_self = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //weak_self.height = weak_self.boardH + weak_self.toolView.height;
        weak_self.zs_h = weak_self.boardH + weak_self.toolView.zs_h;
        //weak_self.y = weak_self.superview.height - weak_self.height;
        weak_self.zs_y = weak_self.superview.zs_h - weak_self.zs_h;
    } completion:^(BOOL finished) {
        if (weak_self.keyBoardDidShow) {
            weak_self.keyBoardDidShow();
        }
    }];
}

- (void)keyboardWillHide{
    if (!_isShowOtherBoard) {
        [self keyBoardHide];
    }
}

- (void)zs_keyboardWillShowWithFrame:(CGRect)frame{
    _boardH = frame.size.height;
    _isShowOtherBoard = NO;
    __weak typeof (self) weak_self = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //weak_self.height = weak_self.boardH + weak_self.toolView.height;
        weak_self.zs_h = weak_self.boardH + weak_self.toolView.zs_h;
        //weak_self.y = weak_self.superview.height - weak_self.height;
        weak_self.zs_y = weak_self.superview.zs_h - weak_self.zs_h;
    } completion:^(BOOL finished) {
        if (weak_self.keyBoardDidShow) {
            weak_self.keyBoardDidShow();
        }
    }];
}

- (void)zs_keyboardWillHide{
    if (!_isShowOtherBoard) {
        [self keyBoardHide];
    }
}

// Mark - 删除输入框的内容
- (BOOL)onTextDeleteFromEmoji:(BOOL)isEmojiBoard {
    NSRange range = [self delRangeForEmoticon];
    
    if (range.length == 1 && !isEmojiBoard) {
        return YES;
    }
    [self deleteText:range];
    return NO;
}

- (void)deleteText:(NSRange)range {
    NSString *text = _textView.text;
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound && range.length != 0){
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        _textView.text = newText;
        _textView.selectedRange = newSelectRange;
        [self textViewDidChange:_textView];
    }
}

- (NSRange)deleteRangeForPrefix:(NSString *)prefix suffix:(NSString *)suffix {
    
    NSRange selectedRange = _textView.selectedRange;
    NSString *text = _textView.text;
    
    if (selectedRange.location <= 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    NSRange delRange = selectedRange.length > 0 ? selectedRange : NSMakeRange(selectedRange.location - 1, 1);
    NSString *selectedText = [text substringWithRange:delRange];
    NSString *preLocationText = [text substringWithRange:NSMakeRange(0, selectedRange.location)];
    
    if ([selectedText isEqualToString:suffix]) {
        NSRange range = [preLocationText rangeOfString:prefix options:NSBackwardsSearch];
        delRange = range.location == NSNotFound ? delRange : NSMakeRange(range.location, selectedRange.location - range.location);
    }
    return delRange;
}

- (NSRange)delRangeForEmoticon{
    NSString *text = _textView.text;
    NSRange range = [self deleteRangeForPrefix:@"[" suffix:@"]"];
    NSRange selectedRange = _textView.selectedRange;
    if (range.length > 1) {
        NSString *name = [text substringWithRange:range];
        NSString *emojiPath = [JDIMTool getEmojiFileFromTag:name];
        range = emojiPath? range : NSMakeRange(selectedRange.location - 1, 1);
    }
    return range;
}

// Mark - 插入emoji表情
- (void)insertText:(NSString *)text {
    NSRange selectedRange = _textView.selectedRange;
    NSString *replaceText = [_textView.text stringByReplacingCharactersInRange:selectedRange withString:text];
    selectedRange = NSMakeRange(selectedRange.location + text.length, 0);
    _textView.text = replaceText;
    _textView.selectedRange = selectedRange;
    // 滚动到光标末尾
    _textView.layoutManager.allowsNonContiguousLayout = NO;
    NSInteger allStrCount = _textView.text.length;
    [_textView scrollRangeToVisible:NSMakeRange(0, allStrCount)];
    [self textViewDidChange:_textView];
}

- (void)showOtherBoard:(UIView *)board{
    board.hidden = NO;
    _boardH = board.zs_h;//board.height;
    CGFloat selfHeight = _boardH + _toolViewH;
    if (self.zs_h < selfHeight) {
        self.zs_h = selfHeight;
    }
    __weak typeof (self) weak_self = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weak_self.zs_y =  weak_self.superview.zs_h - selfHeight;
    } completion:^(BOOL finished) {
        weak_self.zs_h = selfHeight;
        if (weak_self.keyBoardDidShow) {
            weak_self.keyBoardDidShow();
        }
    }];
}

- (void)keyBoardHide{
    _boardH = 0;
    _emojiBoard.hidden = YES;
    _moreBoard.hidden = YES;
    _emojiBoard.zs_y = self.zs_h;
    _moreBoard.zs_y = self.zs_h;
    _emoticonBtn.selected = NO;
    _moreBtn.selected = NO;
    [_emojiBoard layoutIfNeeded];
    [_moreBoard layoutIfNeeded];
    CGFloat selfHeight = _toolViewH + FrameLayoutTool.HomeBtnHeight;//KHOME_HEIGHT;
    __weak typeof (self) weak_self = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weak_self.zs_y = weak_self.superview.zs_h - selfHeight;
    } completion:^(BOOL finished) {
        weak_self.zs_h = selfHeight;
    }];
}

- (void)refreshTextUI{
    _toolViewH = MAX(toolBarH * FrameLayoutTool.UnitHeight, _textViewH + 10 * FrameLayoutTool.UnitHeight);
    self.zs_h = _boardH + _toolViewH;
    self.zs_y = self.superview.zs_h - self.zs_h;
}

- (void)resetRecord{
    [self resetRecordBtn];
    self.recordTipView.hidden = YES;
}

- (void)recordErrorTip{
    _second = 2;
    [self startTimer];
    _recordTipView.hidden = NO;
    [_recordTipView recordErrorTip];
}

- (void)dealloc{
    [self stopTimer];
    [_noticeTool removeAllObservers];
    [_recordTipView removeFromSuperview];
    [self removeFromSuperview];
}

// Mark - timer
- (void)startTimer{
    if (!_timer) {
        __weak typeof (self) weak_self = self;
        _timer = [NSTimer zs_supportiOS_10EarlierTimer:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weak_self recordTimer];
        }];
        //[NSTimer supportiOS_10EarlierVersionsScheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
        //    [weak_self recordTimer];
        //}];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)recordTimer{
    _second -= 1;
    if (_second <= 0) {
        [self stopTimer];
        _recordTipView.hidden = YES;
    }
}


// Mark - EmojiAction
- (void)didSelectedEmoji:(NSString *)tag {
    if ([NSObject zs_isEmpty:tag]) {
        [self onTextDeleteFromEmoji:YES];
    }else{
        [self insertText:tag];
    }
}


// Mark - SwitchAction
- (void)switchTool:(UIButton *)sender {
    if(sender != _toolSelectBtn){
        _toolSelectBtn.selected = NO;
        _toolSelectBtn = sender;
    }
    sender.selected = !sender.isSelected;
    _toolViewH = MAX(toolBarH * FrameLayoutTool.UnitHeight, _textViewH + 10 * FrameLayoutTool.UnitHeight);
    if (sender.isSelected) {
        _isShowOtherBoard = YES;
        [_textView resignFirstResponder];
    }else{
        [_textView becomeFirstResponder];
    }
    
    if ([sender.restorationIdentifier isEqualToString:@"switchMore"]) {
        [self switchMore:sender];
    }else if ([sender.restorationIdentifier isEqualToString:@"switchEmotion"]){
        [self switchEmotion:sender];
    }else if ([sender.restorationIdentifier isEqualToString:@"switchRecord"]) {
        [self switchRecord:sender];
    }
}

- (void)switchMore:(UIButton *)sender {
    if (sender.isSelected) {
        _recordBtn.hidden = YES;
        _textView.hidden  = NO;
        _emojiBoard.hidden = YES;
        [self showOtherBoard:_moreBoard];
    }else{
        _moreBoard.hidden = YES;
    }
}

- (void)switchEmotion:(UIButton *)sender {
    if (sender.isSelected) {
        _recordBtn.hidden = YES;
        _textView.hidden  = NO;
        _moreBoard.hidden = YES;
        [self showOtherBoard:_emojiBoard];
    }else{
        _emojiBoard.hidden = YES;
    }
}

- (void)switchRecord:(UIButton *)sender {
    if (sender.isSelected) {
        _recordBtn.hidden = NO;
        _textView.hidden  = YES;
        _toolViewH = toolBarH * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        [self keyBoardHide];
    }else{
        [self refreshTextUI];
        _recordBtn.hidden = YES;
        _textView.hidden  = NO;
    }
}

// Mark - RecordAction
- (void)onTouchRecordBtnDown:(id)sender {
    // start Recording
    [self stopTimer];
    _isRecordOutside = NO;
    
     AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionGranted) {
        [self.delegate recordStart];
        [sender setBackgroundColor:[UIColor rgb194Color]];
        self.recordTipView.hidden = NO;
        [_recordTipView updateDescLabelStatus:NO];
        _recordTipView.imageVew.image = [UIImage img_setImageName:@"news_service_ voice1"];
        [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
    }else{
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL isOpen) {
        }];
    }
}

- (void)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    [self resetRecordBtn];
    //[JDNIMP2PManager recordStop];
    [[NIMSDK sharedSDK].mediaManager stopRecord];
    self.recordTipView.hidden = YES;
}

- (void)onTouchRecordBtnUpOutside:(id)sender {
    // cancel Recording
    [self resetRecordBtn];
    //[JDNIMP2PManager recordCancel];
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
    self.recordTipView.hidden = YES;
}

- (void)resetRecordBtn{
    [_recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor whiteColor]];
}

- (void)onTouchRecordBtnDragInside:(id)sender {
    // "手指上滑，取消发送"
    _isRecordOutside = NO;
    [_recordTipView updateDescLabelStatus:NO];
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
}

- (void)onTouchRecordBtnDragOutside:(id)sender {
    // "松开手指，取消发送"
    _isRecordOutside = YES;
    [_recordTipView updateDescLabelStatus:YES];
    [sender setTitle:@"松开 取消" forState:UIControlStateNormal];
}

// Mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _audioBtn.selected = NO;
    _emoticonBtn.selected = NO;
    _moreBtn.selected = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){
        // 发送
        [self sendMsg];
        return NO;
    }
    
    if ([text isEqualToString:@""] && range.length == 1 ){
        //非选择删除
        return [self onTextDeleteFromEmoji:NO];
    }
    
    if ([text isEqualToString:@""]) {//删除
        if (range.location + range.length > textView.text.length) {
            textView.text = text;
            return NO;
        }
        return YES;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    _textViewH = MAX(40 * FrameLayoutTool.UnitHeight, [textView.text zs_sizeWithFont:[FrameLayoutTool UnitFont:18] textMaxSize:CGSizeMake(_emoticonBtn.zs_x-_audioBtn.zs_maxX-18*FrameLayoutTool.UnitWidth, 100*FrameLayoutTool.UnitHeight)].height + 16 * FrameLayoutTool.UnitHeight);
    //MAX(40 * KUNIT_HEIGHT, [textView.text sizeWithFont:KFONT(18) maxSize:CGSizeMake(_emoticonBtn.x - _audioBtn.maxX - 18 * KUNIT_WIDTH, 100 * KUNIT_HEIGHT)].height + 16 * KUNIT_HEIGHT);
    _emojiBoard.bottomToolView.sendBtn.userInteractionEnabled = textView.text.length;
    _emojiBoard.bottomToolView.sendBtn.backgroundColor = textView.text.length > 0 ? [UIColor colorWithRed:23.0/255 green:128.0/255 blue:250.0/255 alpha:1.0] : [UIColor rgb194Color];
    //_emojiBoard.bottomToolView.sendBtn.backgroundColor = textView.text.length > 0 ? KCOLOR(23, 128, 250, 1) : [UIColor rgb194Color];
    [self refreshTextUI];
    [self layoutIfNeeded];
}

@end



// Mark - 录制语音的提示框
@implementation JDRecordTipView

- (GIFImageView *)imageVew{
    if (!_imageVew) {
        _imageVew = [[GIFImageView alloc] initWithImage:[UIImage img_setImageName:@"news_service_ voice1"]];
        _imageVew.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageVew];
    }
    return _imageVew;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [UILabel new];
        _descLabel.text = @"手指上滑，取消发送";
        _descLabel.font = [FrameLayoutTool UnitFont:14];//KFONT(14);
        _descLabel.zs_h = 35 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.backgroundColor = [UIColor colorWithRed:67.0/255 green:67.0/255 blue:67.0/255 alpha:0.8];
        //KCOLOR(67, 67, 67, 0.8);
        _descLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_descLabel];
    }
    return _descLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.descLabel.frame = CGRectMake(0, self.zs_h - 35 * FrameLayoutTool.UnitHeight, self.zs_w, self.descLabel.zs_h);
    //CGRectMake(0, self.height - 35 * KUNIT_HEIGHT, self.width, self.descLabel.height);
    self.imageVew.frame = CGRectMake((self.zs_w - 103 * FrameLayoutTool.UnitWidth) * 0.5, (_descLabel.zs_y - 83 * FrameLayoutTool.UnitHeight) * 0.5, 103 * FrameLayoutTool.UnitWidth, 83 * FrameLayoutTool.UnitHeight);
    //CGRectMake((self.width - 103 * KUNIT_WIDTH) * 0.5, (_descLabel.y - 83 * KUNIT_HEIGHT) * 0.5, 103 * KUNIT_WIDTH, 83 * KUNIT_HEIGHT);
}

- (void)updateDescLabelStatus:(BOOL)isCancel{
    _descLabel.zs_h = 35 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    NSString *desc  = isCancel ? @"松开手指，取消发送" : @"手指上滑，取消发送";
    UIColor  *color = isCancel ? [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:0.6] : [UIColor colorWithRed:67.0/255 green:67.0/255 blue:67.0/255 alpha:0.6];
    // isCancel ? KCOLOR(236, 43, 36, 0.6) : KCOLOR(67, 67, 67, 0.6);
    _descLabel.text = desc;
    _descLabel.backgroundColor = color;
}

- (void)recordErrorTip{
    _descLabel.zs_h = 17 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    _descLabel.backgroundColor = [UIColor clearColor];
    _descLabel.text = @"说话时间太短";
    _imageVew.image = [UIImage img_setImageName:@"service_ plaint"];
}

@end



// Mark - emoji底部
@implementation JDEmojiBottomToolView

- (UIButton *)emojiBtn{
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        NSString *imgName = @"emoj_s_pressed";
        NSString *path = [[[JDIMTool getEmojisBundlePath] stringByAppendingPathComponent:@"emoji"] stringByAppendingPathComponent:imgName];
        _emojiBtn.tintColor = [UIColor clearColor];
        [_emojiBtn setImage:[UIImage img_setImageOriginalName:imgName bundlePath:path] forState:UIControlStateSelected];
        _emojiBtn.selected = YES;
        _emojiBtn.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
        //KCOLOR(239, 239, 239, 1);
        [self addSubview:_emojiBtn];
    }
    return _emojiBtn;
}

- (UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _sendBtn.userInteractionEnabled = NO;
        _sendBtn.titleLabel.font = [FrameLayoutTool UnitFont:17];
        //KFONT(17);
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.backgroundColor = [UIColor rgb194Color];
        [self addSubview:_sendBtn];
    }
    return _sendBtn;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.emojiBtn.frame = CGRectMake(0, 0, self.zs_h, 44 * FrameLayoutTool.UnitHeight);
    self.sendBtn.frame  = CGRectMake(self.zs_w - 65 * FrameLayoutTool.UnitWidth, 0, 65 * FrameLayoutTool.UnitWidth, 44 * FrameLayoutTool.UnitHeight);
}

@end



// Mark - emoji操作板
@implementation JDEmojiBoard

- (UIScrollView *)emojiScrollView{
    if (!_emojiScrollView) {
        _emojiScrollView = [UIScrollView new];
        _emojiScrollView.pagingEnabled = YES;
        _emojiScrollView.showsVerticalScrollIndicator = NO;
        _emojiScrollView.showsHorizontalScrollIndicator = NO;
        _emojiScrollView.delegate = self;
        [self insertSubview:_emojiScrollView atIndex:0];
        [self refreshUI];
    }
    return _emojiScrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:216.0/255 green:216.0/255 blue:216.0/255 alpha:1.0];
        //KCOLOR(216, 216, 216, 1);
        _pageControl.currentPageIndicatorTintColor = [UIColor rgb139Color];
        [_pageControl addTarget:self action:@selector(pageControlValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (JDEmojiBottomToolView *)bottomToolView{
    if (!_bottomToolView) {
        _bottomToolView = [JDEmojiBottomToolView new];
        _bottomToolView.backgroundColor = [UIColor whiteColor];
        [_bottomToolView.sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bottomToolView];
    }
    return _bottomToolView;
}

- (NSArray *)emojiArray{
    if (!_emojiArray) {
        _emojiArray = [NSArray arrayWithContentsOfFile:[[JDIMTool getEmojisBundlePath] stringByAppendingPathComponent:@"emoji.plist"]];
    }
    return _emojiArray;
}

- (void)refreshUI{
    NSInteger line = 3;
    NSInteger list = [FrameLayoutTool IsIpad] ? 17 : 8;
    __weak typeof (self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSInteger numberOfPages = ceil(((CGFloat)weak_self.emojiArray.count) / (line * list - 1));
        NSInteger emojiRemain = weak_self.emojiArray.count % (line * list - 1);  // 最后一页剩余的emoji数量
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.pageControl.numberOfPages = numberOfPages;
            weak_self.emojiScrollView.contentSize = CGSizeMake(numberOfPages * self.zs_w, 0);
        });
        
        for (NSInteger page = 0; page < numberOfPages; page++) {
            __block UIView *emojiBackView = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                emojiBackView = [weak_self createEmojiBackView:page];
                [emojiBackView addSubview:[weak_self createBtnOrigin:CGPointMake((list - 1) * 43 * FrameLayoutTool.UnitWidth, (line - 1) * 50 * FrameLayoutTool.UnitHeight) emojiDict:@{ @"tag" : @"删除", @"file" : @"emoji_del" }]];
            });
            
            NSInteger pageEmojiCount = ((emojiRemain > 0) && (page == numberOfPages - 1)) ? emojiRemain : line * list;
            
            for (NSInteger idx = 0; idx < pageEmojiCount; idx++) {
                if (idx < line * list - 1) {
                    NSInteger index = page * (line * list - 1) + idx;  // emoji数组下标
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [emojiBackView addSubview:[self createBtnOrigin:CGPointMake((idx % list) * 43 * FrameLayoutTool.UnitWidth, (idx / list) * 50 * FrameLayoutTool.UnitHeight) emojiDict:weak_self.emojiArray[index]]];
                    });
                }
            }
        }
    });
}

- (UIView *)createEmojiBackView:(NSInteger)page {
    UIView *emojiBacck = [UIView new];
    //emojiBacck.x = page * self.width + 20 * KUNIT_WIDTH;
    emojiBacck.zs_x = page * self.zs_w + 20 * FrameLayoutTool.UnitWidth;
    //emojiBacck.y = 15 * KUNIT_HEIGHT;
    emojiBacck.zs_y = 15 * FrameLayoutTool.UnitHeight;
    //emojiBacck.width  = self.width - 40 * KUNIT_WIDTH;
    emojiBacck.zs_w  = self.zs_w - 40 * FrameLayoutTool.UnitWidth;
    //emojiBacck.height = self.height - emojiBacck.y - 25 * KUNIT_HEIGHT;
    emojiBacck.zs_h = self.zs_h - emojiBacck.zs_y - 25 * FrameLayoutTool.UnitHeight;
    [_emojiScrollView addSubview:emojiBacck];
    return emojiBacck;
}

- (UIButton *)createBtnOrigin:(CGPoint)origin emojiDict:(NSDictionary *)emojiDict {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //button.width  = 30 * KUNIT_WIDTH;
    button.zs_w = 30*FrameLayoutTool.UnitWidth;
    //button.height = 30 * KUNIT_WIDTH;
    button.zs_h = 30*FrameLayoutTool.UnitWidth;
    button.zs_x = origin.x;
    button.zs_y = origin.y;
    
    NSString *imgName = [emojiDict[@"tag"] isEqualToString:@"删除"] ? [NSString stringWithFormat:@"%@_normal@2x.png", emojiDict[@"file"]] : [JDIMTool getEmojiFileFromName:emojiDict[@"file"]];
    NSString *path = [[[JDIMTool getEmojisBundlePath] stringByAppendingPathComponent:@"emoji"] stringByAppendingPathComponent:imgName];
    [button setImage:[UIImage img_setImageOriginalName:imgName bundlePath:path] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didSelectedEmoji:) forControlEvents:UIControlEventTouchUpInside];
    
    button.restorationIdentifier = [emojiDict[@"tag"] isEqualToString:@"删除"] ? nil : emojiDict[@"tag"];
    
    return button;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.emojiScrollView.frame = self.bounds;
    self.bottomToolView.frame = CGRectMake(0, self.zs_h - FrameLayoutTool.HomeBtnHeight - 44 * FrameLayoutTool.UnitHeight, self.zs_w, 44 * FrameLayoutTool.UnitHeight + FrameLayoutTool.HomeBtnHeight);
    // CGRectMake(0, self.height - KHOME_HEIGHT - 44 * KUNIT_HEIGHT, self.width, 44 * KUNIT_HEIGHT + KHOME_HEIGHT);
    //self.pageControl.frame = CGRectMake(0, _bottomToolView.y - 20 * KUNIT_HEIGHT, self.width, 20 * KUNIT_HEIGHT);
    self.pageControl.frame = CGRectMake(0, _bottomToolView.zs_y - 20 * FrameLayoutTool.UnitHeight, self.zs_w, 20 * FrameLayoutTool.UnitHeight);
}

// Mark - action
- (void)didSelectedEmoji:(UIButton *)sender {
    if (_didSelectedEmoji) {
        _didSelectedEmoji(sender.restorationIdentifier);
    }
}

- (void)sendAction{
    if (_didSelectedSend) {
        _didSelectedSend();
    }
}

- (void)pageControlValueChange:(UIPageControl *)pageControl {
    pageControl.tag = 1;
    [self.emojiScrollView setContentOffset:CGPointMake(pageControl.currentPage * self.emojiScrollView.zs_w, 0) animated:YES];
}

// Mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_pageControl.tag == 1) {
        return;
    }
    
    NSInteger page = scrollView.contentOffset.x / scrollView.zs_w + 0.5;
    _pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _pageControl.tag = 0;
}

@end



// Mark - 更多操作板
@implementation JDMoreBoard

- (CustomButton *)albumBtn{
    if (!_albumBtn) {
        _albumBtn = [self createBtn:@"照片" imgName:@"news_pic"];
    }
    return _albumBtn;
}

- (CustomButton *)cameraBtn{
    if (!_cameraBtn) {
        _cameraBtn = [self createBtn:@"拍摄" imgName:@"news_film"];
    }
    return _cameraBtn;
}

- (CustomButton *)adviceBtn{
    if (!_adviceBtn) {
        _adviceBtn = [self createBtn:@"投诉建议" imgName:@"news_complain"];
    }
    return _adviceBtn;
}

- (CustomButton *)createBtn:(NSString *)title imgName:(NSString *)imgName{
    CustomButton *button = [CustomButton buttonWithType:UIButtonTypeSystem];
    button.zs_w  = 60 * FrameLayoutTool.UnitWidth;//KUNIT_WIDTH;
    button.zs_h = 90 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    button.zs_y = 31 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    button.contentComposing = ButtonImageTopWithTitleBottom;
    button.titleLabel.font = [FrameLayoutTool UnitFont:14];//KFONT(14);
    [button setTitleColor:[UIColor rgb82Color] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage img_setImageOriginalName:imgName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.cameraBtn.frame = CGRectMake((self.width - self.cameraBtn.width) * 0.5, _cameraBtn.y, _cameraBtn.width, _cameraBtn.height);
    self.cameraBtn.frame = CGRectMake((self.zs_w - self.cameraBtn.zs_w) * 0.5, _cameraBtn.zs_y, _cameraBtn.zs_w, _cameraBtn.zs_h);
    //self.albumBtn.frame = CGRectMake(_cameraBtn.x - 54 * KUNIT_WIDTH - self.albumBtn.width, _albumBtn.y, _albumBtn.width, _albumBtn.height);
    self.albumBtn.frame = CGRectMake(_cameraBtn.zs_x - 54 * FrameLayoutTool.UnitWidth - self.albumBtn.zs_w, _albumBtn.zs_y, _albumBtn.zs_w, _albumBtn.zs_h);
    //self.adviceBtn.frame = CGRectMake(_cameraBtn.maxX + 54 * KUNIT_WIDTH, self.adviceBtn.y, _adviceBtn.width, _adviceBtn.height);
    self.adviceBtn.frame = CGRectMake(_cameraBtn.zs_maxX + 54 * FrameLayoutTool.UnitWidth, self.adviceBtn.zs_y, _adviceBtn.zs_w, _adviceBtn.zs_h);
}

- (void)moreAction:(UIButton *)sender{
    if (sender == _albumBtn) {
        if (_didSelectedAlbum) {
            _didSelectedAlbum();
        }
    }else if(sender == _cameraBtn){
        if (_didSelectedCamera) {
            _didSelectedCamera();
        }
    }else{
        if (_didSelectedAdvice) {
            _didSelectedAdvice();
        }
    }
}

@end

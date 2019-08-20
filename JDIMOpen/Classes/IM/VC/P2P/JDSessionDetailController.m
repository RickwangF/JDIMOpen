//
//  JDSessionController.m
//  JadeKing
//
//  Created by 张森 on 2018/9/18.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionDetailController.h"
#import "JDMediaCcontroller.h"
#import "JDPreviewTool.h"
#import "TZImagePickerController.h"
#import "JDSeverListController.h"
#import "UIColor+ProjectTool.h"
#import "FrameLayoutTool.h"
#import "ZSBaseUtil-Swift.h"
#import "UIImage+ProjectTool.h"
#import "JDNetService-Swift.h"
#import "JDIMNetworkSetting.h"
#import "TZImageManager+Tool.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JDIMService-Swift.h"
#import "JDIMTool.h"
#import "ZSToastUtil-Swift.h"
#import "RefreshTool.h"
//#import "JDSVideoDetailController.h"
//#import "JDLiveWindow.h"

static const NSInteger pageOfNumber = 20;

@interface JDSessionDetailController ()<NIMChatManagerDelegate, NIMMediaManagerDelegate, NIMConversationManagerDelegate, JDInputToolBarDelegate, JDSessionViewDelegate, JDCamareCcontrollerDelegate, TZImagePickerControllerDelegate, ZSPreviewToolDelegate, JDNIMChatDelegate, JDNIMLoginDelegate>
@property (nonatomic, strong) JDSessionView *sessionView;  // 聊天详情
@property (nonatomic, strong) NSMutableArray *modelArray;  // 消息模型数组
@property (nonatomic, strong) NSMutableArray *messageArray;  // 消息数组
@property (nonatomic, strong) NSMutableArray *exportVideoQueue;  // 导出视频的队列
@property (nonatomic, strong) NSMutableArray *exportModelQueue;  // 填充位置的消息模型
@property (nonatomic, assign) NSInteger appendMsgCount;  // 新增数量
@property (nonatomic, assign) NSInteger audioRetryCount;  // 语音播放重试的次数，最多3次
@property (nonatomic, assign) NSInteger exportRetryCount;  // 视频导出重试的次数，最多3次
@property (nonatomic, strong) JDSessionModel *pendingAudioModel;  // 正在播放的语音
@property (nonatomic, assign) BOOL isAudioAutoStop;  // 是否自动停止
@property (nonatomic, assign) BOOL isExporting;  // 是否正在导出
@property (nonatomic, assign) BOOL isGotHistory;  // 是否获取过历史记录
@property (nonatomic, assign) BOOL isOffline;  // 客服是否离线
@end

@implementation JDSessionDetailController

- (NSMutableArray *)modelArray{
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (NSMutableArray *)messageArray{
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

- (NSMutableArray *)exportVideoQueue{
    if (!_exportVideoQueue) {
        _exportVideoQueue = [NSMutableArray array];
    }
    return _exportVideoQueue;
}

- (NSMutableArray *)exportModelQueue{
    if (!_exportModelQueue) {
        _exportModelQueue = [NSMutableArray array];
    }
    return _exportModelQueue;
}

- (JDSessionView *)sessionView{
    if (!_sessionView) {
        _sessionView = [JDSessionView new];
        _sessionView.inputToolBar.delegate = self;
        _sessionView.delegate = self;
        [self.view addSubview:_sessionView];
    }
    return _sessionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _audioRetryCount = 3;
    _exportRetryCount = 3;
    self.navigationItem.title = @"收取中...";
    self.view.backgroundColor = [UIColor whiteLeadColor];
    //[[NIMSDK sharedSDK].chatManager addDelegate:self];
    [[NIMSDK sharedSDK].mediaManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    
    /////////////////////////////JDNIM/////////////////////////////
    [JDNIM.defult.chatManager addWithDelegate:self];
    [JDNIM.defult.loginManager addWithDelegate:self];
    /////////////////////////////JDNIM/////////////////////////////

//    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem *connect = [[UIBarButtonItem alloc] initWithImage:[UIImage img_setImageOriginalName:@"news_nav_customer service"] style:UIBarButtonItemStylePlain target:self action:@selector(didSelectedSeverList)];
    self.navigationItem.rightBarButtonItems = @[connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_sessionView keyBoardHide];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.sessionView.frame = self.view.bounds;
}

- (void)setRequestParams:(id)requestParams{
    _requestParams = requestParams;
    //[super setRequestParams:requestParams];
    if ([self.requestParams isKindOfClass:[NSDictionary class]]) {
        NIMSession *session = [NIMSession session:self.requestParams[@"accid"] type:NIMSessionTypeP2P];
        self.session = session;
    }else{
        self.navigationItem.title = @"未知账户";
    }
}

- (void)setSession:(NIMSession *)session{
    _session = session;
    //[JDNIMP2PManager shareManager].session = session;
    [self requestServerInfo];
    [self nim_getConversationMessage];
}

- (void)requestServerInfo{
    
    if (![JDSessionKitUtil isAdminSessionId:_session.sessionId]) {
        return;
    }
    
    __weak typeof(self)weak_self = self;
    [JDNetWorkTool GET:NATIVE_BASE_HOST url:JD_Ser_Status parameters:@{@"accid" : [NSObject zs_paramsValue:_session.sessionId]} contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            [weak_self updateNavgationTitle];
            return ;
        }
       
        if ([info isKindOfClass:[NSDictionary class]]) {
            NSString *nickName = info[@"username"];
            nickName = [NSObject zs_isEmpty:nickName] ? weak_self.session.sessionId : nickName;
            //weak_self.avatarUrl = [JDOSSTool getOSSImageUrl:info[@"avatar"]];
            weak_self.nickName = nickName;
            
            if ([info[@"online"] isKindOfClass:[NSString class]] ||
                [info[@"online"] isKindOfClass:[NSNumber class]]) {
                weak_self.isOffline = ([info[@"online"] integerValue] != 1);
            }
        }
        
    }];

}

- (void)setAvatarUrl:(NSString *)avatarUrl{
    _avatarUrl = avatarUrl;
    self.sessionView.avatarUrl = _avatarUrl;
}

- (void)nim_getConversationMessage{
    if ([NIMSDK sharedSDK].loginManager.isLogined) {
        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:_session];
        __weak typeof (self) weak_self = self;
        [self messagesHistoryInMessage:nil complete:^{
            if (weak_self.getHistoryComplete) {
                weak_self.getHistoryComplete();
            }
        }];
    }
}

- (void)updateNavgationTitle{
    
    if (!_isGotHistory) {
        return;
    }
    
    if ([NSObject zs_isEmpty:_nickName]) {
        __weak typeof (self) weak_self = self;
        [JDNIM getUserInfoWithAccount:weak_self.session.sessionId complete:^(NIMUser * _Nullable user, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weak_self.nickName  = [NSObject zs_isEmpty:user.userInfo.nickName] ? weak_self.session.sessionId : user.userInfo.nickName;
                weak_self.avatarUrl = user.userInfo.avatarUrl;
                weak_self.navigationItem.title = weak_self.isOffline ? [NSString stringWithFormat:@"%@（离线）", weak_self.nickName] : weak_self.nickName;
            });
        }];
    }else{
       self.navigationItem.title = _isOffline ? [NSString stringWithFormat:@"%@（离线）", _nickName] : _nickName;
    }
}

- (void)messagesHistoryInMessage:(NIMMessage *)message complete:(void(^)(void))complete{
    __weak typeof (self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:weak_self.session message:message limit:pageOfNumber];
        weak_self.appendMsgCount = messages.count;
        NSMutableArray *modelArray = [NSMutableArray array];
        [messages enumerateObjectsUsingBlock:^(NIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JDSessionModel *model = [JDSessionModel new];
            model.message = obj;
            [modelArray addObject:model];
        }];
        
        [weak_self.messageArray insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count)]];
        [weak_self.modelArray insertObjects:[modelArray copy] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, modelArray.count)]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.isGotHistory = YES;
            [weak_self updateNavgationTitle];
            weak_self.sessionView.modelArray = [weak_self.modelArray copy];
            [weak_self.sessionView reloadData];
            message == nil ? [weak_self.sessionView scrollToBottom] : [weak_self.sessionView scrollToRowAtIndex:weak_self.appendMsgCount];
            if (complete) {
                complete();
            }
        });
    });
}

- (void)messageAddModel:(NIMMessage *)message{
    NSMutableArray *modelArray = [NSMutableArray array];
    NSMutableArray *msgArray   = [NSMutableArray array];
    if (message.session.sessionType == NIMSessionTypeP2P) {
        JDSessionModel *model = [JDSessionModel new];
        model.message = message;
        [modelArray addObject:model];
        [msgArray addObject:message];
        [self.messageArray addObject:message];
        [self.modelArray addObject:model];
    }
    self.sessionView.modelArray = [_modelArray copy];
    [_sessionView reloadData];
}

- (void)sendingMessage:(NIMMessage *)message{
    JDSessionModel *model = [JDSessionModel new];
    model.message = message;
    [self.modelArray addObject:model];
    [self.messageArray addObject:message];
    self.sessionView.modelArray = [_modelArray copy];
    [_sessionView reloadData];
    [_sessionView scrollToBottom];
}

// Mark - Action
- (void)didSelectedSeverList{
    JDSeverListController *controller = [JDSeverListController new];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// Mark - 语音播放
- (void)playAudio:(JDSessionModel *)model{
    // 悬浮窗静音
    //[JDLiveWindow openMute];
    
    if ([[NIMSDK sharedSDK].mediaManager isPlaying]) {
        [[NIMSDK sharedSDK].mediaManager stopPlay];
    }
    
    if (model != _pendingAudioModel) {
        [[NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:NIMAudioOutputDeviceSpeaker];
        NIMAudioObject *audioObject = (NIMAudioObject *)model.message.messageObject;
        
        if ([audioObject isKindOfClass:[NIMAudioObject class]]) {
            model.isAudioPlayed = YES;
            model.isAnimation = YES;
            model.message.isPlayed = YES;
            [self setDeactivateAudioSessionAfterComplete];
            [[NIMSDK sharedSDK].mediaManager play:[NSObject zs_paramsValue:audioObject.path]];
        }
        NSInteger index = [_modelArray indexOfObject:model];
        
        if (index != NSNotFound) {
            [_modelArray replaceObjectAtIndex:index withObject:model];
        }
        
        self.sessionView.modelArray = [_modelArray copy];
        [_sessionView reloadData];
        _pendingAudioModel = model;
    }else{
        _isAudioAutoStop = NO;
        [self endAudioPlay];
        _pendingAudioModel = nil;
    }
}

- (BOOL)beginPlay{
    return YES;
}

- (void)setDeactivateAudioSessionAfterComplete{
    [[NIMSDK sharedSDK].mediaManager setDeactivateAudioSessionAfterComplete:NO];
}

- (void)endAudioPlay{
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    _pendingAudioModel.isAnimation = NO;
    NSInteger index = [_modelArray indexOfObject:_pendingAudioModel];
    
    if (index != NSNotFound) {
        [_modelArray replaceObjectAtIndex:index withObject:_pendingAudioModel];
    }
    
    self.sessionView.modelArray = [_modelArray copy];
    [_sessionView reloadData];
}

// Mark - 媒体放大查看
- (ZSPreviewModel *)createPreviewModel:(JDSessionModel *)model{
    if (model.message.messageType == NIMMessageTypeVideo || model.message.messageType == NIMMessageTypeImage) {
        ZSPreviewModel *preModel = [ZSPreviewModel new];
        preModel.type = (model.message.messageType == NIMMessageTypeVideo ? ZSPreviewVDO : ZSPreviewIMG);
        
        if (model.message.messageType == NIMMessageTypeVideo) {
            NSString *mediaPath = model.messageObjectModel.url;
            preModel.mediaFile = mediaPath ? model.messageObjectModel.url : model.path;
        }else{
            id image = ([[NSFileManager defaultManager] fileExistsAtPath: model.path] ? [UIImage imageWithContentsOfFile:model.path] : model.messageObjectModel.url);
            preModel.mediaFile = image;
        }
        
        id cover = (model.coverPath ? [UIImage imageWithContentsOfFile:model.coverPath] : model.coverUrl);
        id thumb = (model.thumbPath ? [UIImage imageWithContentsOfFile:model.thumbPath] : model.thumbUrl);
        preModel.thumbImage = (model.message.messageType == NIMMessageTypeVideo ? cover : thumb);
        preModel.mediaFileBtye = [model.messageObjectModel.size floatValue];
        return preModel;
    }
    return nil;
}

- (void)viewLargerMedia:(JDSessionModel *)model{
    [_sessionView keyBoardHide];
    JDPreviewTool *previewTool = [[JDPreviewTool alloc] init];
    NSMutableArray *preArray = [NSMutableArray array];
    __block NSInteger firstMediaIndx = 0;
    __weak typeof (self) weak_self = self;
    [_modelArray enumerateObjectsUsingBlock:^(JDSessionModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof (weak_self) strong_self = weak_self;
        ZSPreviewModel *preModel = [strong_self createPreviewModel:obj];
        if (preModel) {
            [preArray addObject:preModel];
            if (model == obj) {
                previewTool.firstMediaIndx = firstMediaIndx;
            }else{
                firstMediaIndx += 1;
            }
        }
    }];
    previewTool.originalMedias = [preArray copy];
    previewTool.isPageHidden = YES;
    previewTool.isLongPress  = YES;
    previewTool.delegate = self;
    [previewTool preview];
}

- (void)mediaLongPress:(ZSPreviewType)type mediaFile:(id)mediaFile{
    // 保存媒体的代码
    ZSSheetView *alertSheetView = [[ZSSheetView alloc] init];
    alertSheetView.sheetSpace = 10*FrameLayoutTool.UnitWidth;
    alertSheetView.sheetActionHeight = FrameLayoutTool.IsIpad ? 80*FrameLayoutTool.UnitHeight : 60*FrameLayoutTool.UnitHeight;
    ZSPopAction *save = [ZSPopAction zs_initWithType:ZSPopActionTypeDone action:^{
        [JDPreviewTool saveAlbum:type mediaFile:mediaFile];
    }];
    [save setTitle:@"保存" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor colorWithRed:87.0/255 green:87.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateNormal];
    
    ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithRed:18.0/255 green:125.0/255 blue:198.0/255 alpha:1.0] forState:UIControlStateNormal];
    
    [alertSheetView addWithAction:save];
    [alertSheetView addWithAction:cancel];
    [alertSheetView sheetWithTitle:nil];
}

// Mark - 获取到图片和视频以发送
- (void)getAlbumImage:(PHAsset *)asset image:(UIImage *)img{
    if (asset) {
        __weak typeof (self) weak_self = self;
        [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
            // old
            //[weak_self sendingMessage:[JDNIMP2PMsg sendMsgWithImage:photo]];
            // new
            NIMMessage *message = [JDNIMSendMessageUntil getImageMessage:nil image:photo];
            NSError *error = [JDNIMSendMessageUntil sendImageMessage:message session:weak_self.session];
            if (error == nil) {
                [weak_self sendingMessage:message];
            }
        }];
    }else{
        // old
        //[self sendingMessage:[JDNIMP2PMsg sendMsgWithImage:img]];
        // new
        NIMMessage *message = [JDNIMSendMessageUntil getImageMessage:nil image:img];
        NSError *error = [JDNIMSendMessageUntil sendImageMessage:message session:_session];
        if (error == nil) {
            [self sendingMessage:message];
        }
    }
}

- (void)getAlbumVideo:(PHAsset *)asset{
    
    JDSessionModel *model = [JDSessionModel new];
    // old
    //NIMMessage *message = [JDNIMP2PMsg getMsgWithVideo];
    // new
    NIMMessage *message = [JDNIMSendMessageUntil getVideoMessage:@""];
    model.message = message;
    model.isSending = NO;
    model.isMySelf = YES;
    model.isSendError = NO;
    model.isExport = YES;
    [self.modelArray addObject:model];
    [self.messageArray addObject:message];
    self.sessionView.modelArray = [_modelArray copy];
    [_sessionView reloadData];
    [_sessionView scrollToBottom];
    
    [self.exportModelQueue insertObject:model atIndex:0];
    [self.exportVideoQueue insertObject:asset atIndex:0];
    [self exportVideo];
}

- (void)dealloc{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [JDNIM.defult.chatManager removeWithDelegate:self];
    [JDNIM.defult.loginManager removeWithDelegate:self];
    [[NIMSDK sharedSDK].mediaManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    if ([[NIMSDK sharedSDK].mediaManager isPlaying]) {
        [[NIMSDK sharedSDK].mediaManager stopPlay];
    }
}

- (void)exportVideo{
    if(_exportVideoQueue.count && !_isExporting && _exportModelQueue.count){
        _isExporting = YES;
        __weak typeof (self) weak_self = self;
        [[TZImageManager manager] getVideoOutputPathWithAsset:[_exportVideoQueue lastObject] success:^(NSString *outputPath) {
            
            JDSessionModel *exportModel = [weak_self.exportModelQueue lastObject];
            NSInteger index = [weak_self.modelArray indexOfObject:exportModel];
            
            if (index != NSNotFound) {
                NIMMessage *message = [weak_self.messageArray objectAtIndex:index];
                // old
                //message = [JDNIMP2PMsg sendMsgWithVideo:message path:outputPath];
                // new
                message = [JDNIMSendMessageUntil getVideoMessage:outputPath];
                NSError *error = [JDNIMSendMessageUntil sendVideoMessage:message session:weak_self.session];
                
                if (error == nil){
                    [weak_self.messageArray replaceObjectAtIndex:index withObject:message];
                    exportModel.message = message;
                    exportModel.isExport = NO;
                    [weak_self.modelArray replaceObjectAtIndex:index withObject:exportModel];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weak_self.sessionView.modelArray = [weak_self.modelArray copy];
                [weak_self.sessionView reloadData];
            });
            
            [weak_self.exportModelQueue removeLastObject];
            [weak_self.exportVideoQueue removeLastObject];
            weak_self.exportRetryCount = 3;
            weak_self.isExporting = NO;
            [weak_self exportVideo];
            
        } failure:^(NSString *errorMessage, NSError *error) {
            weak_self.isExporting = NO;
            if (weak_self.exportRetryCount > 0) {
                [weak_self exportVideo];
                weak_self.exportRetryCount -= 1;
            }else{
                ZSAlertView *alertView = [[ZSAlertView alloc] init];
                ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
                [cancel setTitle:@"知道了" forState:UIControlStateNormal];
                [cancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                [alertView addWithAction:cancel];
                [alertView alertWithTitle:@"温馨提示" message:@"视频获取失败"];
                
                JDSessionModel *exportModel = [weak_self.exportModelQueue lastObject];
                NSInteger index = [weak_self.modelArray indexOfObject:exportModel];
                
                if (index != NSNotFound) {
                    [weak_self.messageArray removeObjectAtIndex:index];
                    [weak_self.modelArray removeObject:exportModel];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak_self.sessionView.modelArray = [weak_self.modelArray copy];
                    [weak_self.sessionView reloadData];
                });
                
                [weak_self.exportModelQueue removeLastObject];
                [weak_self.exportVideoQueue removeLastObject];
                weak_self.exportRetryCount = 3;
            }
        }];
    }
}

// Mark - ZSPreviewToolDelegate
- (BOOL)zs_previewIsBeginPlay{
    // 悬浮窗静音
    //[JDLiveWindow openMute];
    return [self beginPlay];
}

- (void)zs_previewLongPressAction:(ZSPreviewType)type mediaFile:(id)mediaFile{
    [self mediaLongPress:type mediaFile:mediaFile];
}

- (void)zs_imageView:(UIImageView *)imageView loadImageUrl:(NSURL *)url{
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imgLogoGrayscaleSquare]];
}

// Mark - JDInputToolBarDelegate
- (void)didSelectedAlbum{
    // 悬浮窗静音
    //[JDLiveWindow openMute];
    JDAlbumController *albumVC = [JDAlbumController new];
    albumVC.pickerDelegate = self;
    [self presentViewController:albumVC animated:YES completion:^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ZSAlertView *alertView = [[ZSAlertView alloc] init];
            ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
            [cancel setTitle:@"知道了" forState:UIControlStateNormal];
            [cancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            [alertView addWithAction:cancel];
            [alertView alertWithTitle:@"温馨提示" message:@"发送的视频时长不可以超过2分钟,\n超过2分钟的视频将自动过滤"];
        });
    }];
}

- (void)didSelectedCamera{
    // 悬浮窗静音
    //[JDLiveWindow openMute];
    JDCamareCcontroller *camareVC = [JDCamareCcontroller new];
    camareVC.delegate = self;
    [self presentViewController:camareVC animated:YES completion:nil];
}


- (void)didSelectedAdvice{
    // 投诉主播的objectType由2改成3
//    NSDictionary *query = @{
//                            @"objectId"   : [NSObject zs_paramsValue:_session.sessionId],
//                            @"objectType" : @"3"
//                            };
    
//    if ([JDIMTool sharedInstance].adviceBlock) {
//        [JDIMTool sharedInstance].adviceBlock(query);
//    }
    // NSString *route_link = [NSString stringWithFormat:@"%@?%@", RT_Advice_FDBa, [ZSStringTool getUrlQueryString:query]];
    // [JDRouteTool jd_pushRoute:route_link];
    // 修改投诉建议打开的控制器为JDAdviceMainController
    //NSString *routeLink = [NSString stringWithFormat:@"%@?%@", RT_Advice_Main, [ZSStringTool getUrlQueryString:query]];
    //[JDRouteTool jd_pushRoute:routeLink];
}

- (void)didSelectedSendMsg:(NSString *)msg{
    if (![NSObject zs_isEmpty:msg]) {
        //old
        //[self sendingMessage:[JDNIMP2PMsg sendMsgWithText:msg]];
        //new
        NIMMessage *message = [JDNIMSendMessageUntil getTextMessage:msg];
        NSError *error = [JDNIMSendMessageUntil sendTextMessage:message session:_session];
        if (error == nil) {
            [self sendingMessage:message];
        }
    }
}

#pragma mark - JDInputToolBarDelegate
// JDInputToolBar的开始录音的代理方法
- (void)recordStart{
    // 悬浮窗静音
    //[JDLiveWindow openMute];
    //[JDNIMP2PManager recordStartDeactivate:NO];
    [[NIMSDK sharedSDK].mediaManager setDeactivateAudioSessionAfterComplete:NO];
    [[NIMSDK sharedSDK].mediaManager record:NIMAudioTypeAAC duration:60];
}

// Mark - JDMediaControllerDelegate
- (void)camareImageFinish:(UIImage *)image{
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    // old
    //[self sendingMessage:[JDNIMP2PMsg sendMsgWithImage:image]];
    // new
    NIMMessage *message = [JDNIMSendMessageUntil getImageMessage:nil image:image];
    NSError *error = [JDNIMSendMessageUntil sendImageMessage:message session:_session];
    if (error == nil) {
        [self sendingMessage:message];
    }
}

- (void)camareVideoFinish:(PHAsset *)asset{
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    [self getAlbumVideo:asset];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    __weak typeof (self) weak_self = self;
    [assets enumerateObjectsUsingBlock:^(PHAsset *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (obj.mediaType) {
            case PHAssetMediaTypeVideo:{
                [weak_self getAlbumVideo:obj];
                break;
            }
            case PHAssetMediaTypeImage:{
                isSelectOriginalPhoto ? [weak_self getAlbumImage:obj image:photos[idx]] : [weak_self getAlbumImage:nil image:photos[idx]];
                break;
            }
            default:
                break;
        }
    }];
}

- (BOOL)isAssetCanSelect:(PHAsset *)asset{
    return [TZImageManager isVideoCanSelect:asset videoMaximumDuration:120];
}

// Mark - JDSessionViewDelegate
- (void)onOpenLink:(NSURL *)url{
    //JDWebViewController *webVC = [JDWebViewController new];
    //[webVC loadWithoutUrl:url];
    //[self.navigationController pushViewController:webVC animated:YES];
}

- (void)tableView:(UITableView *)tableView pullGetDataSource:(NIMMessage *)message{
    [self messagesHistoryInMessage:message complete:^{
        // TODO: 已完成接入下拉刷新工具
        //[ZSRefreshViewTool scrollViewEndRefreshing:tableView];
        [RefreshTool endRefreshingForScrollView:tableView];
    }];
}

- (void)didSelectCellAtMessage:(JDSessionModel *)model{
    
    switch (model.message.messageType) {
        case NIMMessageTypeImage:
        case NIMMessageTypeVideo:{
            [self viewLargerMedia:model];
            break;
        }
        case NIMMessageTypeAudio:{
            _isAudioAutoStop = YES;
            [self playAudio:model];
            break;
        }
        default:
            break;
    }
}

- (void)onRetryMessage:(JDSessionModel *)model{
    __weak typeof (self) weak_self = self;
    
    ZSAlertView *alertView = [[ZSAlertView alloc] init];
    ZSPopAction *done = [ZSPopAction zs_initWithType:ZSPopActionTypeDone action:^{
        [[[NIMSDK sharedSDK] chatManager] resendMessage:model.message
                                                  error:nil];
        model.isSending = YES;
        model.isSendError = NO;
        
        NSInteger index = [weak_self.modelArray indexOfObject:model];
        
        if (index != NSNotFound) {
            [weak_self.modelArray replaceObjectAtIndex:index withObject:model];
        }
        
        weak_self.sessionView.modelArray = [weak_self.modelArray copy];
        [weak_self.sessionView reloadData];
    }];
    [done setTitle:@"确定" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor themeRedColor] forState:UIControlStateNormal];
    ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor themeRedColor] forState:UIControlStateNormal];
    [alertView addWithAction:done];
    [alertView addWithAction:cancel];
    [alertView alertWithTitle:@"温馨提示" message:@"确定重新发送消息"];
}

- (void)onRevokedMessage:(JDSessionModel *)model{
    __weak typeof(self) weakSelf = self;
    // new
    [JDNIMSendMessageUntil revoke:model.message handle:^(NSError * _Nullable error) {
        if (error) {
            [weakSelf revokeMessageFaile:error];
        }else{
            [weakSelf revokeMessageSuccess:model];
        }
    }];
}

- (void)revokeMessageFaile:(NSError *)error{
    if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
        ZSAlertView *alertView = [[ZSAlertView alloc] init];
        ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
        [cancel setTitle:@"确定" forState:UIControlStateNormal];
        [cancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [alertView addWithAction:cancel];
        [alertView alertWithTitle:@"撤回失败" message:@"发送时间超过2分钟的消息，不能被撤回"];
    }else{
        [ZSTipView showTip:@"网络异常，请重试"];
    }
}

- (void)revokeMessageSuccess:(JDSessionModel *)model{
    [_modelArray removeObject:model];
    [_messageArray removeObject:model.message];
    // old
    //[JDNIMP2PMsg saveMessageWithRevoke:model.message];
    // new
    [JDNIMSendMessageUntil syncRevoke:model.message session:_session block:^(NSError * _Nullable error) {
        
    }];
}


// Mark - NIMChatManagerNotifaction
//- (void)willSendMessage:(NSNotification *)notification{
//
//}
//
//- (void)sendMessageProgress:(NSNotification *)notification{
//    NIMMessage *message = [notification.userInfo objectForKey:@"message"];
//    if ([_session.sessionId isEqualToString:message.session.sessionId]) {
//        CGFloat progress = [[notification.userInfo objectForKey:@"progress"] floatValue];
//        NSInteger index = [_messageArray indexOfObject:message];
//
//        if (index != NSNotFound && index < _modelArray.count) {
//            JDSessionModel *model = _modelArray[index];
//            model.progress = progress;
//            [_modelArray replaceObjectAtIndex:index withObject:model];
//            self.sessionView.modelArray = [_modelArray copy];
//            [_sessionView reloadData];
//        }else{
//            JDSessionModel *model = [JDSessionModel new];
//            model.message  = message;
//            model.progress = progress;
//            [_modelArray addObject:model];
//            [_messageArray addObject:message];
//            self.sessionView.modelArray = [_modelArray copy];
//            [_sessionView reloadData];
//            [_sessionView scrollToBottom];
//        }
//    }
//}
//
//- (void)sendMessageComplete:(NSNotification *)notification{
//    NIMMessage *message = [notification.userInfo objectForKey:@"message"];
//    if ([_session.sessionId isEqualToString:message.session.sessionId]) {
//        NSInteger index = [_messageArray indexOfObject:message];
//
//        if (index != NSNotFound && index < _modelArray.count) {
//            JDSessionModel *model = _modelArray[index];
//            model.message = message;
//            [_modelArray replaceObjectAtIndex:index withObject:model];
//            self.sessionView.modelArray = [_modelArray copy];
//            [_sessionView reloadData];
//        }else{
//            JDSessionModel *model = [JDSessionModel new];
//            model.message = message;
//            [_modelArray addObject:model];
//            [_messageArray addObject:message];
//            self.sessionView.modelArray = [_modelArray copy];
//            [_sessionView reloadData];
//            [_sessionView scrollToBottom];
//        }
//    }
//}
//
//- (void)onRecvMessage:(NSNotification *)notification{
//    NIMMessage *message = [notification.userInfo objectForKey:@"message"];
//
//    BOOL isOtherMsg = (message.isReceivedMsg &&  // 别人发送的消息
//                       [_session.sessionId isEqualToString:message.from]);  // 是否是同一个人的消息，多窗口的时候过滤其他窗口的消息
//
//    BOOL isSelfMsg = (message.isOutgoingMsg &&  // 自己发送的消息，但是是外来消息，比如撤回
//                      [_session.sessionId isEqualToString:message.session.sessionId]);  // 是否是同一个人的消息，多窗口的时候过滤其他窗口的消息
//
//    if (isOtherMsg || isSelfMsg) {
//        [self messageAddModel:message];
//        [_sessionView scrollToBottom];
//        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:_session];
//    }
//}
//
//- (void)onRecvRevokeMessage:(NSNotification *)notification{
//
//    NIMRevokeMessageNotification *notic = [notification.userInfo objectForKey:@"notification"];
//
//    if ([_session.sessionId isEqualToString:notic.messageFromUserId] && notic.message) {
//        NSInteger index = [_messageArray indexOfObject:notic.message];
//        [_modelArray removeObjectAtIndex:index];
//        [_messageArray removeObject:notic.message];
//        // old
//        //[JDNIMP2PMsg saveMessageWithRevoke:notic.message];
//        // new
//        [JDNIMSendMessageUntil syncRevoke:notic.message session:_session block:^(NSError * _Nullable error) {
//
//        }];
//    }
//}
//
//- (void)loginComplete:(NSNotification *)notification{
//    if ([NSObject zs_isEmpty:[notification.userInfo valueForKey:@"error"]] && !_isGotHistory) {
//        [self nim_getConversationMessage];
//    }
//}

#pragma mark - JDNIMLoginDelegate

- (void)nim_loginSuccess{
    [self nim_getConversationMessage];
}

#pragma mark - JDNIMChatDelegate

- (void)nim_willSendWithMessage:(NIMMessage *)message{
    
}

- (void)nim_sendChatWithMessage:(NIMMessage *)message progress:(float)progress{
    if ([_session.sessionId isEqualToString:message.session.sessionId]) {
        NSInteger index = [_messageArray indexOfObject:message];
        
        if (index != NSNotFound && index < _modelArray.count) {
            JDSessionModel *model = _modelArray[index];
            model.progress = progress;
            [_modelArray replaceObjectAtIndex:index withObject:model];
            self.sessionView.modelArray = [_modelArray copy];
            [_sessionView reloadData];
        }else{
            JDSessionModel *model = [JDSessionModel new];
            model.message  = message;
            model.progress = progress;
            [_modelArray addObject:model];
            [_messageArray addObject:message];
            self.sessionView.modelArray = [_modelArray copy];
            [_sessionView reloadData];
            [_sessionView scrollToBottom];
        }
    }
}

- (void)nim_sendChatCompleteWithMessage:(NIMMessage *)message error:(NSError *)error{
    if ([_session.sessionId isEqualToString:message.session.sessionId]) {
        NSInteger index = [_messageArray indexOfObject:message];
        
        if (index != NSNotFound && index < _modelArray.count) {
            JDSessionModel *model = _modelArray[index];
            model.message = message;
            [_modelArray replaceObjectAtIndex:index withObject:model];
            self.sessionView.modelArray = [_modelArray copy];
            [_sessionView reloadData];
        }else{
            JDSessionModel *model = [JDSessionModel new];
            model.message = message;
            [_modelArray addObject:model];
            [_messageArray addObject:message];
            self.sessionView.modelArray = [_modelArray copy];
            [_sessionView reloadData];
            [_sessionView scrollToBottom];
        }
    }
}

- (void)nim_onRecvChatWithMessage:(NIMMessage *)message{
    BOOL isOtherMsg = (message.isReceivedMsg &&  // 别人发送的消息
                       [_session.sessionId isEqualToString:message.from]);  // 是否是同一个人的消息，多窗口的时候过滤其他窗口的消息
    
    BOOL isSelfMsg = (message.isOutgoingMsg &&  // 自己发送的消息，但是是外来消息，比如撤回
                      [_session.sessionId isEqualToString:message.session.sessionId]);  // 是否是同一个人的消息，多窗口的时候过滤其他窗口的消息
    
    if (isOtherMsg || isSelfMsg) {
        [self messageAddModel:message];
        [_sessionView scrollToBottom];
        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:_session];
    }
}

- (void)nim_onRecvRevokeWithNotification:(NIMRevokeMessageNotification *)notification{
    if ([_session.sessionId isEqualToString:notification.messageFromUserId] && notification.message) {
        NSInteger index = [_messageArray indexOfObject:notification.message];
        [_modelArray removeObjectAtIndex:index];
        [_messageArray removeObject:notification.message];
        // old
        //[JDNIMP2PMsg saveMessageWithRevoke:notic.message];
        // new
        [JDNIMSendMessageUntil syncRevoke:notification.message session:_session block:^(NSError * _Nullable error) {
            
        }];
    }
}



// Mark - NIMConversationManagerDelegate

#pragma mark - NIMConversationManagerDelegate
- (void)messagesDeletedInSession:(NIMSession *)session{
    
}

- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}


- (void)changeUnreadCount:(NIMRecentSession *)recentSession
         totalUnreadCount:(NSInteger)totalUnreadCount{
    
}

#pragma mark - NIMMediaManagerDelegate
// Mark - NIMMediaManagerDelegate
- (void)playAudio:(NSString *)filePath didBeganWithError:(NSError *)error{
    if (error){
        if (_audioRetryCount > 0){
            // iPhone4 和 iPhone 4S 上连播会由于设备释放过慢导致 AudioQueue 启动不了的问题，这里做个延迟重试，最多重试 3 次 ( code -66681 )
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NIMSDK sharedSDK].mediaManager play:filePath];
            });
        }else{
            _audioRetryCount = 3;
        }
    }else{
        _audioRetryCount = 3;
    }
}


- (void)playAudio:(NSString *)filePath didCompletedWithError:(nullable NSError *)error{
    
    if (_isAudioAutoStop) {
        //        NSInteger index = [_modelArray indexOfObject:_pendingAudioModel];
        //
        //        for (NSInteger idx = index + 1; idx < MIN(_modelArray.count, 50); idx ++) {
        //            JDSessionModel *model = _modelArray[idx];
        //            if (model.message.messageType == NIMMessageTypeAudio && model.isAudioPlayed) {
        //                [self playAudio:model];
        //                break;
        //            }
        //        }
        [self endAudioPlay];
        [[NIMSDK sharedSDK].mediaManager stopPlay];
    }else{
        
    }
}

- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error{
    if (!filePath || error) {
        [self onRecordFailed:error];
        // 悬浮窗关闭静音
        //[JDLiveWindow closeMute];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    [_sessionView resetRecord];
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            // old
            //[self sendingMessage:[JDNIMP2PMsg sendMsgWithAudio:filePath]];
            // new
            NIMMessage *message = [JDNIMSendMessageUntil getAudioMessage:filePath];
            NSError *error = [JDNIMSendMessageUntil sendAudioMessage:message session:_session];
            if (error == nil) {
                [self sendingMessage:message];
            }
        }else{
            [_sessionView.inputToolBar recordErrorTip];
        }
    } else {
        [self onRecordFailed:error];
    }
    
}

- (void)recordAudioDidCancelled {
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    // old
    //[_sessionView.inputToolBar updateRecordUIFromPower:[JDNIMP2PManager recordPeakPower]];
    // new
    [_sessionView.inputToolBar updateRecordUIFromPower: [[NIMSDK sharedSDK].mediaManager recordPeakPower] + 0.5];
}

- (void)recordAudioInterruptionBegin {
    // 悬浮窗关闭静音
    //[JDLiveWindow closeMute];
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

#pragma mark - Record
// Mark - 录音相关接口
- (void)onRecordFailed:(NSError *)error{}

- (BOOL)recordFileCanBeSend:(NSString *)filepath{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 0.8;
}

@end

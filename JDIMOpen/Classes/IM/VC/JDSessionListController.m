//
//  JDSessionListController.m
//  JadeKing
//
//  Created by 张森 on 2018/9/7.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionListController.h"
#import "JDSessionListView.h"
#import "JDSysMsgController.h"
#import "JDSessionDetailController.h"
#import "JDSeverListController.h"
#import "FrameLayoutTool.h"
#import "ZSBaseUtil-Swift.h"
#import "UIColor+ProjectTool.h"
#import <MJExtension/MJExtension.h>
#import "JDIMNetworkSetting.h"
#import "JDNetService-Swift.h"
#import "JDIMTool.h"

@interface JDSessionListController ()<NIMConversationManagerDelegate, JDSessionListViewDelegate, JDNIMLoginDelegate, JDNIMChatDelegate>
@property (nonatomic, strong) JDSessionListView *sessionView;  // 消息列表
@property (nonatomic, strong) NSMutableArray *recentModels;  // 最近Model集合
@property (nonatomic, strong) JDSysMsgUnreadModel* model;
@end

@implementation JDSessionListController

- (NSMutableArray *)recentModels{
    if (!_recentModels) {
        _recentModels = [NSMutableArray array];
    }
    return _recentModels;
}

- (JDSessionListView *)sessionView{
    if (!_sessionView) {
        _sessionView = [JDSessionListView new];
        _sessionView.delegate = self;
        [self.view addSubview:_sessionView];
    }
    return _sessionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteLeadColor];
    // 请求未读信息和会话列表
    [self requestSessionList];
    // old
    //_sessionView.model = [JDNIMManager shareManager].model;
    // new
    //_sessionView.model = _model;
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    
    ///////////////////JDNIM////////////////////////
    [JDNIM.defult.loginManager addWithDelegate:self];
    [JDNIM.defult.chatManager addWithDelegate:self];
    ///////////////////JDNIM////////////////////////
    
    ///////////////////测试/////////////////////////
    
    ///////////////////测试/////////////////////////
    
    self.navigationItem.title = @"消息中心";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (animated) {
        [self requestSessionList];
    }
    
    self.view.backgroundColor = [UIColor whiteLeadColor];
    self.navigationController.navigationBar.barTintColor = [UIColor navigationColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.sessionView.frame = self.view.bounds;
}

#pragma mark - Life Circle
- (void)dealloc{
    //[[JDNIMManager shareManager] removeObserver:self forKeyPath:@"model"];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [JDNIM.defult.loginManager removeWithDelegate:self];
    [JDNIM.defult.chatManager removeWithDelegate:self];
}

- (void)syncRequestSessionList{

    if ([JDIMTool userToken]) {
        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
        [self.recentModels removeAllObjects];
        __weak typeof (self) weak_self = self;
        [recentSessions enumerateObjectsUsingBlock:^(NIMRecentSession  *_Nonnull recentSession, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![recentSession.session.sessionId isEqualToString:@"jaadee_live_helper"]) {  // 过滤小组手
                [weak_self.recentModels addObject:[weak_self getSessionListModel:recentSession]];
            }
        }];
        self.sessionView.recentModels = [_recentModels copy];
    }
}

- (void)requestUnreadMsg{
    [JDNetWorkTool GET:NATIVE_BASE_HOST url:JD_Unread_Msg parameters:nil contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            self.model = [JDSysMsgUnreadModel new];
            self.sessionView.model = self.model;
            return;
        }
        
        if ([NSObject zs_isEmpty:info] ||[NSObject zs_isEmpty:[info objectForKey:@"info"]]) {
            return;
        }
        
        self.model = [JDSysMsgUnreadModel mj_objectWithKeyValues:[info objectForKey:@"info"]];
        self.sessionView.model = self.model;
    }];
}

- (void)requestSessionList{
    // old
    //[JDNIMManager requestUnreadMsgApi];
    // new
    [self requestUnreadMsg];
    [self syncRequestSessionList];
}

- (JDSessionListModel *)getSessionListModel:(NIMRecentSession *)recentSession{
    JDSessionListModel *model = [JDSessionListModel new];
    model.recentSession = recentSession;
    return model;
}

- (NSInteger)indexRecentSession:(NIMRecentSession *)recentSession{
    __block NSInteger index = NSNotFound;
    [self.recentModels enumerateObjectsUsingBlock:^(JDSessionListModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.recentSession.session.sessionId isEqualToString:recentSession.session.sessionId]) {
            index = idx;
            *stop = YES;
            return ;
        }
    }];
    
    return index;
}

- (void)loginOut{
    [_recentModels removeAllObjects];
    _sessionView.recentModels = nil;
    // old
    //[JDNIMManager clearUnreadCount];
    // new
    _model = [[JDSysMsgUnreadModel alloc] init];
}

// Mark - NSNotification
//- (void)onRecvMessage:(NSNotification *)notification{
//    [self syncRequestSessionList];
//}
//
//- (void)loginFromOtherDevice:(NSNotification *)notifation{
//    [self loginOut];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}
//
//- (void)loginComplete:(NSNotification *)notifation{
//    [self requestSessionList];
//}
//
//- (void)nimLoginOut:(NSNotification *)notifation{
//    [self loginOut];
//}

///////////////////测试/////////////////////////

///////////////////测试/////////////////////////

#pragma mark - JDNIMLoginDelegate

- (void)nim_loginSuccess{
    [self requestSessionList];
}

- (void)nim_loginOut{
   [self loginOut];
}

- (void)nim_loginOfOtherDevice{
    [self loginOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - JDNIMChatDelegate

- (void)nim_onRecvChatWithMessage:(NIMMessage *)message{
    [self syncRequestSessionList];
}

#pragma mark - JDSessionListViewDelegate
// Mark - JDSessionListViewDelegate
- (void)refreshMsgList{
    [self requestSessionList];
}

- (void)didSelectServerList{
    JDSeverListController *controller = [JDSeverListController new];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didSelectSysMessage:(JDSysMsgType)type{
    JDSysMsgController *controller = type == JDSysMsgNotice ? [JDNoticeListController new] : [JDActionListController new];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didSelectConnectServer{
    [self didSelectServerList];
}

- (void)didSelectRowAtSession:(JDSessionListModel *)model userInfo:(NIMUserInfo *)userInfo{
    // TODO: 依靠外部传进模块的userToken来判断是否登录
    if ([JDIMTool userToken]) {
        JDSessionDetailController *controller = [JDSessionDetailController new];
        controller.hidesBottomBarWhenPushed = YES;
        controller.session   = model.recentSession.session;
        controller.nickName  = userInfo.nickName;
        controller.avatarUrl = userInfo.avatarUrl;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didDeleteRowAtSession:(JDSessionListModel *)model{
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager deleteRecentSession:model.recentSession];
}

// Mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self.recentModels addObject:[self getSessionListModel:recentSession]];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{

    NSInteger index = [self indexRecentSession:recentSession];
    
    if (index != NSNotFound) {
        JDSessionListModel *model = _recentModels[index];
        model.recentSession = recentSession;
        [_recentModels replaceObjectAtIndex:index withObject:model];
        _sessionView.recentModels = [_recentModels copy];
    }
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    
    NSInteger index = [self indexRecentSession:recentSession];
    
    if (index != NSNotFound) {
        JDSessionListModel *model = _recentModels[index];
        model.recentSession = recentSession;
        [_recentModels removeObjectAtIndex:index];
        //如果删除本地会话后就不允许漫游当前会话，则需要进行一次删除服务器会话的操作
        [[NIMSDK sharedSDK].conversationManager deleteRemoteSessions:@[recentSession.session]
                                                          completion:nil];
        _sessionView.recentModels = [_recentModels copy];
    }
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    [self requestSessionList];
}

@end

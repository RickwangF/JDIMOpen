//
//  JDSeverListController.m
//  JadeKing
//
//  Created by 张森 on 2018/11/20.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSeverListController.h"
#import "JDSessionDetailController.h"
#import "JDSeverListView.h"
#import "FrameLayoutTool.h"
#import "ZSBaseUtil-Swift.h"
#import "UIColor+ProjectTool.h"
#import "JDNetService-Swift.h"
#import "JDIMNetworkSetting.h"
#import "JDIMTool.h"
#import <MJExtension/MJExtension.h>

@interface JDSeverListController ()
@property (nonatomic, strong) JDSeverListView *listView;  // 客服列表
@end

@implementation JDSeverListController

- (JDSeverListView *)listView{
    if (!_listView) {
        _listView = [JDSeverListView new];
        __weak typeof (self) weak_self = self;
        _listView.onSever = ^(JDSeverModel *model) {
            [weak_self connectSever:model];
        };
        [self.view addSubview:_listView];
    }
    return _listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"客服列表";
    self.view.backgroundColor = [UIColor whiteColor];
    [self requestDataSource];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.listView.frame = self.view.bounds;
}

- (void)connectSever:(JDSeverModel *)model{
    // TODO: 依靠外部传进来的userToken来判断是否已经登录
    if ([JDIMTool userToken]) {
        JDSessionDetailController *controller = [JDSessionDetailController new];
        controller.session   = [NIMSession session:model.easeAcountUser type:NIMSessionTypeP2P];
        controller.nickName  = model.username;
        controller.avatarUrl = model.avatar;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        // TODO: 已经完成打开登录控制器的block调用
        if ([JDIMTool sharedInstance].loginBlock) {
            [JDIMTool sharedInstance].loginBlock();
        }
    }
}

- (void)severListResolve:(id)responseObject{
    self.listView.severGroups = [JDSeverListModel mj_objectArrayWithKeyValuesArray:responseObject];
}

- (void)requestDataSource{

    __weak typeof (self) weak_self = self;
    
    [JDNetWorkTool GET:NATIVE_BASE_HOST url:JD_Ser_List parameters:nil contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            return;
        }
        
        if ([NSObject zs_isEmpty:info]) {
            return;
        }

        if (![NSObject zs_isEmpty:[info objectForKey:@"info"]]) {
            [weak_self severListResolve:[info objectForKey:@"info"]];
        }
    }];
    
}

@end

//
//  JDSysMsgController.m
//  JadeKing
//
//  Created by 张森 on 2018/9/14.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSysMsgController.h"
#import "JDSysMsgView.h"
#import "FrameLayoutTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIColor+ProjectTool.h"
#import <JDNetService/JDNetService-Swift.h>
#import "JDIMNetworkSetting.h"
#import "LiveModuleStringTool.h"
#import "JDIMTool.h"
#import "RefreshTool.h"
#import <MJExtension/MJExtension.h>

@interface JDSysMsgController ()<JDSysMsgViewDelegate>
@property (nonatomic, strong) JDSysMsgView *msgView;  // 详情
@property (nonatomic, strong) UIBarButtonItem *allReadButton;  // 全部已读
@property (nonatomic, strong) NSNumber *type;  // 消息类型
@property (nonatomic, copy) NSMutableArray *groupArray;  // 分组数组
@end

@implementation JDSysMsgController

- (JDSysMsgView *)msgView{
    if (!_msgView) {
        _msgView = [JDSysMsgView new];
        _msgView.delegate = self;
        [self.view addSubview:_msgView];
    }
    return _msgView;
}

- (UIBarButtonItem *)allReadButton{
    if (!_allReadButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [FrameLayoutTool UnitFont:15];//KFONT(15);
        [button setTitle:@"全部已读" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(allReadAction) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 65 * FrameLayoutTool.UnitWidth, 44);
        _allReadButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        _allReadButton.tintColor = [UIColor whiteColor];
    }
    return _allReadButton;
}

- (NSMutableArray *)groupArray{
    if (!_groupArray) {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.msgView.frame = self.view.bounds;
}

- (void)allReadAction{
    [self requestAllReadMsg];
}

- (void)requestAllReadMsg{
    
    NSDictionary *params =
    @{
      @"type" : [NSObject zs_paramsValue:_type]
      };
    __weak typeof (self) weak_self = self;

    [JDNetWorkTool PUT:NATIVE_BASE_HOST url:JD_ReadA_Msg parameters:params contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            return;
        }

        [weak_self allReadSuccess];
    }];
}

- (void)allReadSuccess{ }

- (void)requestReadMsg:(NSNumber *)msgId{
    
    NSDictionary *params =
    @{
      @"msgId"   : [NSObject zs_paramsValue:msgId]
      };
    __weak typeof (self) weak_self = self;

    [JDNetWorkTool PUT:NATIVE_BASE_HOST url:JD_Read_Msg parameters:params contentId:msgId timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            return;
        }
        [weak_self.groupArray enumerateObjectsUsingBlock:^(JDSysMsgGroupModel *groupModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [groupModel.msgArray enumerateObjectsUsingBlock:^(JDSysMsgModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([msgId integerValue] == [obj.msgId integerValue]) {
                    obj.isRead = @(1);
                    *stop = YES;
                    return ;
                }
            }];
        }];
        weak_self.msgView.groupArray = [weak_self.groupArray copy];
    }];

}

- (void)requesetDataSource:(NSNumber *)type{
    _type = type;
    [self loadMoreMsgId:nil];
}

- (void)requesetDataSourceComplete:(NSError *)error{
    
}

// Mark - JDSysMsgViewDelegate
- (void)refreshDataSource{
    [self loadMoreMsgId:nil];
}

- (void)loadMoreMsgId:(NSNumber *)msgId{
    NSDictionary *param =
    @{
      @"type"  : [NSObject zs_paramsValue:_type],
      @"msgId" : [NSObject zs_paramsValue:msgId]
      };
    __weak typeof (self) weak_self = self;
    
    [JDNetWorkTool GET:NATIVE_BASE_HOST url:JD_Fetch_Msg parameters:param contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDIMNetworkSetting.HttpHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error) {
        if (![NSObject zs_isEmpty:error]) {
            // TODO: 已完成接入下拉刷新
            [RefreshTool endRefreshingForScrollView:weak_self.msgView.tableView];
            [weak_self requesetDataSourceComplete:error];
            weak_self.msgView.groupArray = [weak_self.groupArray copy];
            return;
        }
        
        if ([NSObject zs_isEmpty:info]) {
            [RefreshTool endRefreshingForScrollView:weak_self.msgView.tableView];
            return;
        }

        // TODO: 已完成接入下拉刷新
        [RefreshTool endRefreshingForScrollView:weak_self.msgView.tableView];
        NSArray *modelArray = [JDSysMsgModel mj_objectArrayWithKeyValuesArray:[info objectForKey:@"info"]];

        if (modelArray.count) {

            if (!msgId) {
                [weak_self.groupArray removeAllObjects];
            }

            JDSysMsgGroupModel *model = [JDSysMsgGroupModel new];
            model.msgArray = modelArray;
            model.date = [LiveModuleStringTool getTimeFrame:[[[modelArray firstObject] pushTime] integerValue] showOclock:NO hideTodayOclock:YES timingMode:TimingMode_24];

            [weak_self.groupArray addObject:model];

            weak_self.msgView.groupArray = [weak_self.groupArray copy];
        }else if(msgId){
            // TODO: 已完成接入下拉刷新
            [RefreshTool endRefreshingWithNoMoreDataFor:weak_self.msgView.tableView];
        }else{
            weak_self.msgView.groupArray = nil;
        }
        [weak_self requesetDataSourceComplete:nil];
    }];
    
}

- (void)didSelectRowAtModel:(JDSysMsgModel *)model{
    [self requestReadMsg:model.msgId];
}

@end

@interface JDNoticeListController ()

@end

@implementation JDNoticeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"通知消息";
    [self requesetDataSource:@(1)];
    self.navigationItem.rightBarButtonItem = self.allReadButton;
}

- (void)allReadSuccess{
    [self.groupArray enumerateObjectsUsingBlock:^(JDSysMsgGroupModel *groupModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [groupModel.msgArray enumerateObjectsUsingBlock:^(JDSysMsgModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isRead = @(1);
        }];
    }];
    self.msgView.groupArray = [self.groupArray copy];
}

@end




@interface JDActionListController ()

@end

@implementation JDActionListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"活动优惠";
    [self requesetDataSource:@(2)];
}

- (void)requesetDataSourceComplete:(NSError *)error{
    [super requesetDataSourceComplete:error];
    [self requestAllReadMsg];
}

@end

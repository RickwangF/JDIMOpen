//
//  JDSessionListView.h
//  JadeKing
//
//  Created by 张森 on 2018/9/7.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSysMsgModel.h"
#import "JDSessionListModel.h"

typedef NS_ENUM(NSUInteger, JDSysMsgType) {
    JDSysMsgNotice = 1,
    JDSysMsgAction = 2
};


@protocol JDSessionListViewDelegate <NSObject>

- (void)refreshMsgList;
- (void)didSelectServerList;
- (void)didSelectSysMessage:(JDSysMsgType)type;
- (void)didSelectConnectServer;
- (void)didSelectRowAtSession:(JDSessionListModel *)model userInfo:(NIMUserInfo *)userInfo; 
- (void)didDeleteRowAtSession:(JDSessionListModel *)model;

@end


@interface JDSessionListView : UIView
@property (nonatomic, copy) NSArray *recentModels;  // 最近会话集合
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JDSysMsgUnreadModel *model;  // 未读消息的model
@property (nonatomic, weak) id<JDSessionListViewDelegate> delegate;  // delegate

/**
公共方法，自类实现自己的下拉刷新方法时，需要调用。
 
 */
- (void)refreshData;

@end

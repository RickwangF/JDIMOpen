//
//  JDSysMsgView.h
//  JadeKing
//
//  Created by 张森 on 2018/9/14.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSysMsgModel.h"
#import "CustomTableView.h"

@protocol JDSysMsgViewDelegate <NSObject>

- (void)refreshDataSource;
- (void)loadMoreMsgId:(NSNumber *)msgId;
- (void)didSelectRowAtModel:(JDSysMsgModel *)model;

@end


@interface JDSysMsgView : UIView
@property (nonatomic, copy) NSArray <JDSysMsgGroupModel *>*groupArray;  // 消息数组
@property (nonatomic, weak) id<JDSysMsgViewDelegate> delegate;  // 代理
@property (nonatomic, strong) CustomTableView *tableView;  // 系统消息tableView

/**
 下拉刷新的公共方法，子类自定义下拉刷新时需要调用该方法
 
 */
- (void)refreshData;

/**
 上拉加载的公共方法，子类自定义上拉加载时需要调用该方法
 
 */
- (void)loadMoreData;

@end

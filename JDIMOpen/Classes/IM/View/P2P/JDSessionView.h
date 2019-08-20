//
//  JDSessionView.h
//  JadeKing
//
//  Created by 张森 on 2018/9/18.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDInputToolBar.h"
#import "JDSessionCellFactory.h"

@interface JDSessionTable : UITableView

@end

@protocol JDSessionViewDelegate <NSObject>

- (void)tableView:(UITableView *)tableView pullGetDataSource:(NIMMessage *)message;
- (void)didSelectCellAtMessage:(JDSessionModel *)model;
- (void)onRevokedMessage:(JDSessionModel *)model;
- (void)onRetryMessage:(JDSessionModel *)model;
- (void)onOpenLink:(NSURL *)url;

@end


@interface JDSessionView : UIView
@property (nonatomic, strong, readonly) JDInputToolBar *inputToolBar;  // 输入工具栏
/// 聊天记录列表
@property (nonatomic, strong) JDSessionTable *tableView;
//@property (nonatomic, weak) id<JDSessionCellDelegate> delegate;  // cell的代理方法
@property (nonatomic, weak) id<JDSessionViewDelegate> delegate;
@property (nonatomic, copy) NSArray *modelArray;  // 消息数组
@property (nonatomic, copy) NSString *avatarUrl;  // 对方头像

/// 下拉刷新方法
- (void)refreshData;

- (void)resetRecord;
- (void)keyBoardHide;
- (void)scrollToBottom;
- (void)reloadData;
- (void)scrollToRowAtIndex:(NSInteger)index;
- (CGRect)cellFrameOfIndex:(NSInteger)index;
- (void)reloadCellOfIndex:(NSInteger)index;
@end

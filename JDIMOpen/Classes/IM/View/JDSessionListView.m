//
//  JDSessionListView.m
//  JadeKing
//
//  Created by 张森 on 2018/9/7.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionListView.h"
#import "FrameLayoutTool.h"
#import "UIColor+ProjectTool.h"
#import "UIImage+ProjectTool.h"
#import "GIFImageView.h"
#import "ZSBaseUtil-Swift.h"
#import "JDIMService-Swift.h"
#import "RefreshTool.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JDSessionListCellView : UIView
@property (nonatomic, strong) UIView *backView;  // 背景块
@property (nonatomic, strong) CAGradientLayer *gradientLayer;  // 分割线
@property (nonatomic, strong) GIFImageView *avatarImageView;  // 头像
@property (nonatomic, strong) UILabel *nicknameLabel;  // 昵称
@property (nonatomic, strong) GIFImageView *arrowImageView;  // 箭头图标
@property (nonatomic, copy) void(^didSelected)(void);  // 点击回调
@end

@implementation JDSessionListCellView

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSession)]];
        [self addSubview:_backView];
    }
    return _backView;
}

- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0.04, 0.04);
        _gradientLayer.endPoint = CGPointMake(1, 0.04);
//        _gradientLayer.colors = @[(__bridge id)KCOLOR(250, 250, 250, 1).CGColor,
//                                  (__bridge id)KCOLOR(235, 235, 237, 1).CGColor,
//                                  (__bridge id)KCOLOR(251, 251, 252, 1).CGColor];
        _gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:235.0/255 green:235.0/255 blue:237.0/255 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:251.0/255 green:251.0/255 blue:252.0/255 alpha:1.0].CGColor];
        _gradientLayer.locations = @[@(0), @(0.5f), @(1.0f)];
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

- (GIFImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [GIFImageView new];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 5 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        [self.backView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nicknameLabel{
    if (!_nicknameLabel) {
        _nicknameLabel = [UILabel new];
        //_nicknameLabel.font = IS_IPAD ? KFONT(18) : KFONT(16);
        _nicknameLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:18] : [FrameLayoutTool UnitFont:16];
        _nicknameLabel.textColor = [UIColor rgb51Color];
        [self.backView addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}

- (GIFImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[GIFImageView alloc] initWithImage:[UIImage img_setImageName:@"right arrow"]];
        _arrowImageView.hidden = YES;
        [self.backView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
//    CGFloat arrowWidth = self.arrowImageView.hidden ? 0 : 18 * KUNIT_WIDTH;
    CGFloat arrowWidth = self.arrowImageView.hidden ? 0 : 18 * FrameLayoutTool.UnitWidth;
//    self.backView.frame = CGRectMake(0, 0, self.width, (IS_IPAD ? 90 * KUNIT_HEIGHT : 75 * KUNIT_HEIGHT));
    self.backView.frame = CGRectMake(0, 0, self.zs_w, (FrameLayoutTool.IsIpad ? 90 * FrameLayoutTool.UnitHeight : 75 * FrameLayoutTool.UnitHeight));
//    self.gradientLayer.frame = CGRectMake(0, _backView.maxY - 1, _backView.width, 1);
    self.gradientLayer.frame = CGRectMake(0, _backView.zs_maxY - 1, _backView.zs_w, 1);
//
//    CGFloat avatarSize = IS_IPAD ? 60 * KUNIT_HEIGHT : 44 * KUNIT_HEIGHT;
    CGFloat avatarSize = FrameLayoutTool.IsIpad ? 60 * FrameLayoutTool.UnitHeight : 44 * FrameLayoutTool.UnitHeight;
//    self.avatarImageView.frame = CGRectMake(9 * KUNIT_WIDTH, (_backView.height - avatarSize) * 0.5, avatarSize, avatarSize);
    self.avatarImageView.frame = CGRectMake(9 * FrameLayoutTool.UnitWidth, (_backView.zs_h - avatarSize) * 0.5, avatarSize, avatarSize);
//    self.arrowImageView.frame = CGRectMake(_backView.width - 13 * KUNIT_WIDTH - arrowWidth, (_backView.height - 20 * KUNIT_HEIGHT) * 0.5, arrowWidth, 20 * KUNIT_HEIGHT);
    self.arrowImageView.frame = CGRectMake(_backView.zs_w - 13 * FrameLayoutTool.UnitWidth - arrowWidth, (_backView.zs_h - 20 * FrameLayoutTool.UnitHeight) * 0.5, arrowWidth, 20 * FrameLayoutTool.UnitHeight);
//    self.nicknameLabel.frame = CGRectMake(_avatarImageView.maxX + 8 * KUNIT_WIDTH, 0, _arrowImageView.x - _avatarImageView.maxX - 16 * KUNIT_WIDTH, _backView.height - 1);
    self.nicknameLabel.frame = CGRectMake(_avatarImageView.zs_maxX + 8 * FrameLayoutTool.UnitWidth, 0, _arrowImageView.zs_x - _avatarImageView.zs_maxX - 16 * FrameLayoutTool.UnitWidth, _backView.zs_h - 1);
}

- (void)clickSession{
    if (_didSelected) {
        _didSelected();
    }
}

@end



@interface JDSessionListMsgCellView : JDSessionListCellView
@property (nonatomic, strong) UILabel *messageLabel;  // 消息
@property (nonatomic, strong) UILabel *timeLabel;  // 时间
@property (nonatomic, strong) UILabel *badgeLabel;  // 小红标

@property (nonatomic, strong) JDSessionListModel *model;  // 会话模型
@property (nonatomic, strong) NIMUserInfo *userInfo;  // 用户信息
@property (nonatomic, copy) NSString *unreadCount;  // 未读消息数量
@property (nonatomic, assign) CGFloat unreadCountWidth;  // 未读消息宽度
@property (nonatomic, copy) NSString *dateTime;  // 消息时间
@property (nonatomic, assign) CGFloat dateTimeWidth;  // 消息时间宽度
@end

@implementation JDSessionListMsgCellView

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:14] : [FrameLayoutTool UnitFont:12];
        // IS_IPAD ? KFONT(14) : KFONT(12);
        _messageLabel.textColor = [UIColor rgb139Color];
        [self.backView addSubview:_messageLabel];
    }
    return _messageLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:14] : [FrameLayoutTool UnitFont:12];
        // IS_IPAD ? KFONT(14) : KFONT(12);
        _timeLabel.textColor = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1.0];
        //KCOLOR(180, 180, 180, 1);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.backView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [UILabel new];
        _badgeLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:14] : [FrameLayoutTool UnitFont:12];
        // IS_IPAD ? KFONT(14) : KFONT(12);
        _badgeLabel.textColor = UIColor.whiteColor;
        //KCOLOR(255, 255, 255, 1);
        _badgeLabel.backgroundColor = [UIColor themeRedColor];
        _badgeLabel.clipsToBounds = YES;
        _badgeLabel.hidden = YES;
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        [self.backView addSubview:_badgeLabel];
    }
    return _badgeLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.timeLabel.frame = CGRectMake(self.backView.width - _dateTimeWidth - 8 * KUNIT_WIDTH, self.avatarImageView.y, _dateTimeWidth, 17 * KUNIT_HEIGHT);
    self.timeLabel.frame = CGRectMake(self.backView.zs_w - _dateTimeWidth - 8 * FrameLayoutTool.UnitWidth, self.avatarImageView.zs_y, _dateTimeWidth, 17 * FrameLayoutTool.UnitHeight);
//    self.nicknameLabel.frame = CGRectMake(self.nicknameLabel.x, self.avatarImageView.y, _timeLabel.x - self.avatarImageView.maxX - 16 * KUNIT_WIDTH, (IS_IPAD ? 30 * KUNIT_HEIGHT : 22 * KUNIT_HEIGHT));
    self.nicknameLabel.frame = CGRectMake(self.nicknameLabel.zs_x, self.avatarImageView.zs_y, _timeLabel.zs_x - self.avatarImageView.zs_maxX - 16 * FrameLayoutTool.UnitWidth, (FrameLayoutTool.IsIpad ? 30 * FrameLayoutTool.UnitHeight : 22 * FrameLayoutTool.UnitHeight));
//    self.messageLabel.frame = CGRectMake(self.nicknameLabel.x, self.nicknameLabel.maxY, self.nicknameLabel.width, 21 * KUNIT_HEIGHT);
    self.messageLabel.frame = CGRectMake(self.nicknameLabel.zs_x, self.nicknameLabel.zs_maxY, self.nicknameLabel.zs_w, 21 * FrameLayoutTool.UnitHeight);
//
//    CGFloat badgeH = (IS_IPAD ? 22 * KUNIT_HEIGHT : 18 * KUNIT_HEIGHT);
    CGFloat badgeH = (FrameLayoutTool.IsIpad ? 22 * FrameLayoutTool.UnitHeight : 18 * FrameLayoutTool.UnitHeight);
//    CGFloat badgeW = MAX(_unreadCountWidth, badgeH);
    CGFloat badgeW = MAX(_unreadCountWidth, badgeH);
//
//    self.badgeLabel.frame = CGRectMake(self.backView.width - badgeW - 8 * KUNIT_WIDTH, _messageLabel.maxY - badgeH, badgeW, badgeH);
    self.badgeLabel.frame = CGRectMake(self.backView.zs_w - badgeW - 8 * FrameLayoutTool.UnitWidth, _messageLabel.zs_maxY - badgeH, badgeW, badgeH);
    _badgeLabel.layer.cornerRadius = _badgeLabel.zs_h * 0.5;
}

- (void)setDateTime:(NSString *)dateTime{
    _dateTime = dateTime;
    self.timeLabel.text = _dateTime;
    //_dateTimeWidth = [dateTime sizeWithFont:(IS_IPAD ? KFONT(14) : KFONT(12)) maxSize:CGSizeMake(MAXFLOAT, 17 * KUNIT_HEIGHT)].width;
    _dateTimeWidth = [dateTime zs_sizeWithFont:(FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:14] : [FrameLayoutTool UnitFont:12]) textMaxSize:CGSizeMake(MAXFLOAT, 17*FrameLayoutTool.UnitHeight)].width;
    [self layoutSubviews];
}

- (void)setUnreadCount:(NSString *)unreadCount{
    _unreadCount = unreadCount;
    _badgeLabel.text = _unreadCount;
    //_unreadCountWidth = [unreadCount sizeWithFont:(IS_IPAD ? KFONT(12) : KFONT(10)) maxSize:CGSizeMake(MAXFLOAT, 16 * KUNIT_HEIGHT)].width + 12 * KUNIT_WIDTH;
    _unreadCountWidth = [unreadCount zs_sizeWithFont:(FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:12] : [FrameLayoutTool UnitFont:10]) textMaxSize:CGSizeMake(MAXFLOAT, 16*FrameLayoutTool.UnitHeight )].width + 12 * FrameLayoutTool.UnitWidth;
    [self layoutSubviews];
}

- (void)setModel:(JDSessionListModel *)model{
    _model = model;
    self.messageLabel.text = model.msg;
    self.dateTime = model.msgTimeStr;
    self.badgeLabel.hidden = !model.isUnread;
    self.unreadCount = model.numStr;
}

- (void)setUserInfo:(NIMUserInfo *)userInfo{
    _userInfo = userInfo;
    self.nicknameLabel.text = userInfo.nickName;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:[UIImage defultAvatarImage]];
}

@end



@interface JDSessionListHeaderView : UIView
@property (nonatomic, strong) JDSessionListMsgCellView *notifiyMsgView;  // 通知消息
@property (nonatomic, strong) JDSessionListMsgCellView *actionMsgView;  // 活动优惠
@property (nonatomic, strong) JDSessionListCellView *serverListView;  // 客服列表
@property (nonatomic, strong) JDSysMsgUnreadModel *model;  // 未读消息的model
@end

@implementation JDSessionListHeaderView

- (JDSessionListMsgCellView *)notifiyMsgView{
    if (!_notifiyMsgView) {
        _notifiyMsgView = [JDSessionListMsgCellView new];
        _notifiyMsgView.nicknameLabel.text = @"通知消息";
        _notifiyMsgView.avatarImageView.image = [UIImage img_setImageName:@"news_news"];
        [self addSubview:_notifiyMsgView];
    }
    return _notifiyMsgView;
}

- (JDSessionListMsgCellView *)actionMsgView{
    if (!_actionMsgView) {
        _actionMsgView = [JDSessionListMsgCellView new];
        _actionMsgView.nicknameLabel.text = @"活动优惠";
        _actionMsgView.avatarImageView.image = [UIImage img_setImageName:@"news_promotions"];
        [self addSubview:_actionMsgView];
    }
    return _actionMsgView;
}

- (JDSessionListCellView *)serverListView{
    if (!_serverListView) {
        _serverListView = [JDSessionListCellView new];
        _serverListView.arrowImageView.hidden = NO;
        _serverListView.nicknameLabel.text = @"客服列表";
        _serverListView.avatarImageView.image = [UIImage img_setImageName:@"news_customer service list"];
        [self addSubview:_serverListView];
    }
    return _serverListView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat msgH = (IS_IPAD ? 90 * KUNIT_HEIGHT : 75 * KUNIT_HEIGHT);
    CGFloat msgH = (FrameLayoutTool.IsIpad ? 90 * FrameLayoutTool.UnitHeight : 75 * FrameLayoutTool.UnitHeight);
//    self.notifiyMsgView.frame = CGRectMake(0, 0, self.width, msgH);
    self.notifiyMsgView.frame = CGRectMake(0, 0, self.zs_w, msgH);
//    self.actionMsgView.frame  = CGRectMake(0, _notifiyMsgView.maxY, self.width, msgH);
    self.actionMsgView.frame  = CGRectMake(0, _notifiyMsgView.zs_maxY, self.zs_w, msgH);
//    self.serverListView.frame = CGRectMake(0, _actionMsgView.maxY + 15 * KUNIT_HEIGHT, self.width, msgH);
    self.serverListView.frame = CGRectMake(0, _actionMsgView.zs_maxY + 15 * FrameLayoutTool.UnitHeight, self.zs_w, msgH);
}

- (NSString *)getTitle:(NSString *)title{
    return [NSObject zs_isEmpty:title] ? @"暂时没有新的消息" : title;
}

- (void)setModel:(JDSysMsgUnreadModel *)model{
    _model = model;
    self.notifiyMsgView.messageLabel.text = [self getTitle:model.notify.title];
    self.actionMsgView.messageLabel.text  = [self getTitle:model.activity.title];
    self.notifiyMsgView.dateTime = model.notify.msgTimeStr;
    self.actionMsgView.dateTime  = model.activity.msgTimeStr;
    self.notifiyMsgView.badgeLabel.hidden = !model.notify.isUnread;
    self.actionMsgView.badgeLabel.hidden  = !model.activity.isUnread;
    self.notifiyMsgView.unreadCount = model.notify.numStr;
    self.actionMsgView.unreadCount  = model.activity.numStr;
}

@end



@interface JDSessionListMsgCell : UITableViewCell
@property (nonatomic, strong) JDSessionListMsgCellView *cellView;  // 单元栏
@end

@implementation JDSessionListMsgCell

- (JDSessionListMsgCellView *)cellView{
    if (!_cellView) {
        _cellView = [JDSessionListMsgCellView new];
        [self.contentView addSubview:_cellView];
    }
    return _cellView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cellView.frame = self.bounds;
}

@end




@interface JDSessionListView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) JDSessionListHeaderView *headerView;  // 头部视图
@property (nonatomic, strong) JDSessionListCellView *footerView;  // 尾部视图
@property (nonatomic, strong) NSMutableDictionary *userDict;  // 用户信息
@property (nonatomic, strong) dispatch_queue_t userInfoQueue;  // 用户信息队列
@end

@implementation JDSessionListView

- (JDSessionListHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [JDSessionListHeaderView new];
         __weak typeof (self) weak_self = self;
        _headerView.notifiyMsgView.didSelected = ^{
            [weak_self.delegate didSelectSysMessage:JDSysMsgNotice];
        };
        _headerView.actionMsgView.didSelected = ^{
            [weak_self.delegate didSelectSysMessage:JDSysMsgAction];
        };
        _headerView.serverListView.didSelected = ^{
            [weak_self.delegate didSelectServerList];
        };
        //_headerView.height = (IS_IPAD ? 285 * KUNIT_HEIGHT : 240 * KUNIT_HEIGHT);
        _headerView.zs_h = (FrameLayoutTool.IsIpad ? 285 * FrameLayoutTool.UnitHeight : 240 * FrameLayoutTool.UnitHeight);
    }
    return _headerView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate         = self;
        _tableView.dataSource       = self;
        _tableView.backgroundColor  = [UIColor whiteLeadColor];
        _tableView.tableHeaderView  = self.headerView;
        _tableView.tableFooterView  = self.footerView;
        _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_tableView registerClass:[JDSessionListMsgCell class] forCellReuseIdentifier:NSStringFromClass([JDSessionListMsgCell class])];
         __weak typeof (self) weak_self = self;
        // TODO: 已完成下拉刷新接入
        [RefreshTool initRefreshHeaderForScrollView:weak_self.tableView WithRefreshBlock:^{
            [weak_self refreshData];
        }];
        
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (JDSessionListCellView *)footerView{
    if (!_footerView) {
        _footerView = [JDSessionListCellView new];
         __weak typeof (self) weak_self = self;
        _footerView.didSelected = ^{
            [weak_self.delegate didSelectConnectServer];
        };
        _footerView.nicknameLabel.text = @"联系客服";
        _footerView.avatarImageView.image = [UIImage img_setImageName:@"news_service"];
        //_footerView.height = (IS_IPAD ? 90 * KUNIT_HEIGHT : 75 * KUNIT_HEIGHT);
        _footerView.zs_h = (FrameLayoutTool.IsIpad ? 90 * FrameLayoutTool.UnitHeight : 75 * FrameLayoutTool.UnitHeight);
    }
    return _footerView;
}

- (dispatch_queue_t)userInfoQueue{
    if (!_userInfoQueue) {
        _userInfoQueue = dispatch_queue_create("com.zhangsen", DISPATCH_QUEUE_SERIAL);
    }
    return _userInfoQueue;
}

- (NSMutableDictionary *)userDict{
    if (!_userDict) {
        _userDict = [NSMutableDictionary dictionary];
    }
    return _userDict;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame  = self.bounds;
}

- (void)setRecentModels:(NSArray *)recentModels{
    _recentModels = recentModels;
    if (!recentModels.count) {
        self.tableView.tableFooterView = self.footerView;
    }else{
        self.tableView.tableFooterView = [UIView new];
    }
    
    [self.tableView reloadData];
}

- (void)setModel:(JDSysMsgUnreadModel *)model{
    _model = model;
    self.headerView.model = [model isKindOfClass:[JDSysMsgUnreadModel class]] ? model : nil;
    // TODO: 已完成下拉刷新接入
    [RefreshTool endRefreshingForScrollView:_tableView];
}

- (void)getUserInfo:(NSString *)sessionId{
    __weak typeof (self) weak_self = self;
    dispatch_async(self.userInfoQueue, ^{
        NSString *key = sessionId;
        // new
        [JDNIM getUserInfoWithAccount:sessionId complete:^(NIMUser * _Nullable user, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weak_self.userDict setValue:[NSObject zs_paramsValue:user.userInfo] forKey:key];
                [weak_self.tableView reloadData];
            });
        }];
    });
}

- (void)refreshData{
    [RefreshTool resetNoMoreDataForScrollView:self.tableView];
    [RefreshTool resetNoSourceDataForScrollView:self.tableView];
    [self.delegate refreshMsgList];
}


// Mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recentModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JDSessionListModel *model = self.recentModels[indexPath.row];
    NSString *sessionId = model.recentSession.session.sessionId;
    
    JDSessionListMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JDSessionListMsgCell class]) forIndexPath:indexPath];
    
    cell.cellView.model = model;
    if ([NSObject zs_isEmpty:_userDict[sessionId]]) {
        [self getUserInfo:sessionId];
        cell.cellView.nicknameLabel.text = model.recentSession.session.sessionId;
        cell.cellView.avatarImageView.image = [UIImage defultAvatarImage];
    }else{
        cell.cellView.userInfo = _userDict[sessionId];
    }
    cell.cellView.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    return cell;
}

// Mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return (IS_IPAD ? 90 * KUNIT_HEIGHT : 75 * KUNIT_HEIGHT);
    return (FrameLayoutTool.IsIpad ? 90 * FrameLayoutTool.UnitHeight : 75 * FrameLayoutTool.UnitHeight);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JDSessionListModel *model = self.recentModels[indexPath.row];
    NSString *sessionId = model.recentSession.session.sessionId;
    NIMUserInfo *userInfo = [_userDict[sessionId] isKindOfClass:[NIMUserInfo class]] ? _userDict[sessionId] : nil;
    [self.delegate didSelectRowAtSession:model userInfo:userInfo];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    JDSessionListModel *model = self.recentModels[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.delegate didDeleteRowAtSession:model];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end


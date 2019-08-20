//
//  JDSeverListView.m
//  JadeKing
//
//  Created by 张森 on 2018/11/20.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSeverListView.h"
#import "GIFImageView.h"
#import "FrameLayoutTool.h"
#import "ZSBaseUtil-Swift.h"
#import "UIColor+ProjectTool.h"
#import "UIImage+ProjectTool.h"
#import "ZSToastUtil-Swift.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JDSeverListContent : UIView
@property (nonatomic, strong) UIView *backView;  // 背景
@property (nonatomic, strong) GIFImageView *avatar;  // 头像
@property (nonatomic, strong) UILabel *nameLabel;  // 昵称
@end

@implementation JDSeverListContent

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backView];
    }
    return _backView;
}

- (GIFImageView *)avatar{
    if (!_avatar) {
        _avatar = [GIFImageView new];
        _avatar.layer.cornerRadius = 8 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        [self.backView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor rgb51Color];
        [self.backView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.backView.frame = CGRectMake(0, 1 * KUNIT_HEIGHT, self.width, self.height - 1 * KUNIT_HEIGHT);
    self.backView.frame = CGRectMake(0, 1 * FrameLayoutTool.UnitHeight, self.zs_w, self.zs_h - 1 * FrameLayoutTool.UnitHeight);
    //CGFloat avatarSize = (IS_IPAD ? 55 * KUNIT_HEIGHT : 34 * KUNIT_HEIGHT);
    CGFloat avatarSize = (FrameLayoutTool.IsIpad ? 55 * FrameLayoutTool.UnitHeight : 34 * FrameLayoutTool.UnitHeight);
    //self.avatar.frame = CGRectMake(14 * KUNIT_WIDTH, (self.height - avatarSize) * 0.5, avatarSize, avatarSize);
    self.avatar.frame = CGRectMake(14 * FrameLayoutTool.UnitWidth, (self.zs_h - avatarSize) * 0.5, avatarSize, avatarSize);
    //self.nameLabel.frame = CGRectMake(_avatar.maxX + 12 * KUNIT_WIDTH, 0, _nameLabel.width, self.height);
    self.nameLabel.frame = CGRectMake(_avatar.zs_maxX + 12 * FrameLayoutTool.UnitWidth, 0, _nameLabel.zs_w, self.zs_h);
}

@end


@interface JDSeverListHeader : UITableViewHeaderFooterView
@property (nonatomic, strong) JDSeverListContent *content;  // 内容
@property (nonatomic, strong) UIImageView *arrowImage;  // 箭头
@property (nonatomic, assign) BOOL isFold;  // 是否折叠
@property (nonatomic, assign) NSInteger section;  // 记录当前的section
@property (nonatomic, copy) void(^didSelectHeader)(NSInteger section);  // 点击回调
@end

@implementation JDSeverListHeader

- (JDSeverListContent *)content{
    if (!_content) {
        _content = [JDSeverListContent new];
        _content.nameLabel.font = [FrameLayoutTool UnitFont:16];
        //KFONT(16);
        _content.backgroundColor = [UIColor whiteLeadColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectSection)];
        [_content addGestureRecognizer:tap];
        [self.contentView insertSubview:_content atIndex:0];
    }
    return _content;
}

- (UIImageView *)arrowImage{
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] initWithImage:[UIImage img_setImageName:@"btn_down_normal"]];
        _arrowImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_arrowImage];
    }
    return _arrowImage;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.arrowImage.frame = CGRectMake(self.contentView.width - 20 * KUNIT_WIDTH - 14 * KUNIT_HEIGHT, (self.contentView.height - 14 * KUNIT_HEIGHT) * 0.5, 14 * KUNIT_HEIGHT, 14 * KUNIT_HEIGHT);
    self.arrowImage.frame = CGRectMake(self.contentView.zs_w - 20 * FrameLayoutTool.UnitWidth - 14 * FrameLayoutTool.UnitHeight, (self.contentView.zs_h - 14 * FrameLayoutTool.UnitHeight) * 0.5, 14 * FrameLayoutTool.UnitHeight, 14 * FrameLayoutTool.UnitHeight);
    //self.content.nameLabel.width = _arrowImage.x - 10 * KUNIT_WIDTH;
    self.content.nameLabel.zs_w = _arrowImage.zs_x - 10 * FrameLayoutTool.UnitWidth;
    self.content.frame = self.contentView.bounds;
}

- (void)setIsFold:(BOOL)isFold{
    _isFold = isFold;
    self.arrowImage.image = isFold ? [UIImage img_setImageName:@"btn_right_normal"] : [UIImage img_setImageName:@"btn_down_normal"];
}

- (void)didSelectSection{
    if (_didSelectHeader) {
        _didSelectHeader(_section);
    }
}

@end


@interface JDSeverListCell : UITableViewCell
@property (nonatomic, strong) JDSeverListContent *content;  // 内容
@property (nonatomic, strong) UILabel *statusLabel;  // 在线状态
@property (nonatomic, assign) BOOL isOnline;  // 是否在线
@end

@implementation JDSeverListCell

- (JDSeverListContent *)content{
    if (!_content) {
        _content = [JDSeverListContent new];
        _content.nameLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:16] : [FrameLayoutTool UnitFont:14];
        // (IS_IPAD ? KFONT(16) : KFONT(14));
        _content.backgroundColor = [UIColor whiteLeadColor];
        [self.contentView insertSubview:_content atIndex:0];
    }
    return _content;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.font = FrameLayoutTool.IsIpad ? [FrameLayoutTool UnitFont:14] : [FrameLayoutTool UnitFont:12];
        // (IS_IPAD ? KFONT(14) : KFONT(12));
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.backgroundColor = [UIColor emeraldColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.clipsToBounds = YES;
        [self.contentView addSubview:_statusLabel];
    }
    return _statusLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat statusH = (IS_IPAD ? 30 * KUNIT_HEIGHT : 20 * KUNIT_HEIGHT);
    CGFloat statusH = (FrameLayoutTool.IsIpad ? 30 * FrameLayoutTool.UnitHeight : 20 * FrameLayoutTool.UnitHeight);
//    CGFloat statusW = (IS_IPAD ? 60 * KUNIT_WIDTH : 46 * KUNIT_WIDTH);
    CGFloat statusW = (FrameLayoutTool.IsIpad ? 60 * FrameLayoutTool.UnitWidth : 46 * FrameLayoutTool.UnitWidth);
//    self.statusLabel.frame = CGRectMake(self.contentView.width - 20 * KUNIT_WIDTH - statusW, (self.contentView.height - statusH) * 0.5, statusW, statusH);
    self.statusLabel.frame = CGRectMake(self.contentView.zs_w - 20 * FrameLayoutTool.UnitWidth - statusW, (self.contentView.zs_h - statusH) * 0.5, statusW, statusH);
//    _statusLabel.layer.cornerRadius = _statusLabel.height * 0.5;
    _statusLabel.layer.cornerRadius = _statusLabel.zs_h * 0.5;
//    self.content.nameLabel.width = _statusLabel.x - 10 * KUNIT_WIDTH;
    self.content.nameLabel.zs_w = _statusLabel.zs_x - 10 * FrameLayoutTool.UnitWidth;
    self.content.frame = self.contentView.bounds;
}

- (void)setIsOnline:(BOOL)isOnline{
    _isOnline = isOnline;
    self.statusLabel.text = isOnline ? @"在线" : @"离线";
    _statusLabel.backgroundColor = isOnline ? [UIColor emeraldColor] : [UIColor rgb194Color];
    self.content.nameLabel.textColor = isOnline ? [UIColor rgb51Color] : [UIColor rgb139Color];
    self.content.avatar.alpha = isOnline ? 1 : 0.7;
}

@end


@interface JDSeverListView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;  // 客服列表
@end

@implementation JDSeverListView

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor whiteLeadColor];
        _tableView.backgroundColor = [UIColor whiteLeadColor];
        [_tableView registerClass:[JDSeverListCell class] forCellReuseIdentifier:NSStringFromClass([JDSeverListCell class])];
        [_tableView registerClass:[JDSeverListHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([JDSeverListHeader class])];
        _tableView.rowHeight = FrameLayoutTool.IsIpad ? 70*FrameLayoutTool.UnitHeight : 50*FrameLayoutTool.UnitHeight;
        //(IS_IPAD ? 70 * KUNIT_HEIGHT : 50 * KUNIT_HEIGHT);
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)setSeverGroups:(NSArray *)severGroups{
    _severGroups = severGroups;
    [self.tableView reloadData];
}

// Mark - UITableViewDelegate | UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _severGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    JDSeverListModel *listModel = _severGroups[section];
    return listModel.isFold ? 0 : listModel.customerServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JDSeverListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JDSeverListCell class]) forIndexPath:indexPath];
    JDSeverListModel *listModel = _severGroups[indexPath.section];
    JDSeverModel *model = listModel.customerServices[indexPath.row];
    
    [cell.content.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage defultAvatarImage]];
    cell.content.nameLabel.text = model.username;
    cell.isOnline = [model.online integerValue] == 1;
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    JDSeverListHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([JDSeverListHeader class])];
    
    JDSeverListModel *listModel = _severGroups[section];
    header.content.avatar.image = [UIImage img_setImageName:[NSString stringWithFormat:@"news_avatar_%@", listModel.platCode]];
    header.content.nameLabel.text = listModel.platName;
    header.isFold = listModel.isFold;
    header.section = section;
    
    __weak typeof (self) weak_self = self;
    header.didSelectHeader = ^(NSInteger sec) {
        JDSeverListModel *listModel = weak_self.severGroups[sec];
        listModel.isFold = !listModel.isFold;
        [weak_self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sec] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //return (IS_IPAD ? 80 * KUNIT_HEIGHT : 60 * KUNIT_HEIGHT);
    return FrameLayoutTool.IsIpad ? 80*FrameLayoutTool.UnitHeight : 60*FrameLayoutTool.UnitHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 6 * FrameLayoutTool.UnitHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JDSeverListModel *listModel = _severGroups[indexPath.section];
    JDSeverModel *model = listModel.customerServices[indexPath.row];
    
    if ([model.online integerValue] != 1) {
        [ZSTipView showTip:[NSString stringWithFormat:@"客服 %@ 已离线，请联系其他客服", model.username]];
        return ;
    }
    
    if (_onSever) {
        _onSever(model);
    }
}

@end

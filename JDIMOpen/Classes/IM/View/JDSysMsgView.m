//
//  JDSysMsgView.m
//  JadeKing
//
//  Created by 张森 on 2018/9/14.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSysMsgView.h"
#import "JDChatTimeHeader.h"
#import "GIFImageView.h"
#import "FrameLayoutTool.h"
#import "ZSBaseUtil-Swift.h"
#import "UIColor+ProjectTool.h"
#import "UIImage+ProjectTool.h"
#import "RefreshTool.h"
#import "RefreshTool+EmptyData.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JDSysMsgCell : UITableViewCell
@property (nonatomic, strong) UIView *backView;  // 背景图层
@property (nonatomic, strong) UIView *foreView;  // 前景蒙版图层
@property (nonatomic, strong) GIFImageView *msgImageView;  // 消息图片
@property (nonatomic, strong) UILabel *titleLabel;  // 标题
@property (nonatomic, strong) UILabel *descLabel;  // 描述
@property (nonatomic, assign) CGFloat titleHeight;  // 标题高度
@property (nonatomic, assign) CGFloat descHeight;  // 描述高度
@property (nonatomic, strong) JDSysMsgModel *model;  // 模型
@end

@implementation JDSysMsgCell

- (UIView *)foreView{
    if (!_foreView) {
        _foreView = [UIView new];
        _foreView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        //KCOLOR(255, 255, 255, 0.5);
        _foreView.userInteractionEnabled = NO;
        _foreView.hidden = YES;
        [self.backView addSubview:_foreView];
    }
    return _foreView;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 8 * FrameLayoutTool.UnitHeight;
        //KUNIT_HEIGHT;
        [self.contentView insertSubview:_backView atIndex:0];
    }
    return _backView;
}

- (GIFImageView *)msgImageView{
    if (!_msgImageView) {
        _msgImageView = [GIFImageView new];
        _msgImageView.layer.cornerRadius = 6 * FrameLayoutTool.UnitHeight;
        //KUNIT_HEIGHT;
        _msgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _msgImageView.clipsToBounds = YES;
        _msgImageView.backgroundColor = [UIColor whiteFlowersColor];
        [self.backView insertSubview:_msgImageView atIndex:0];
    }
    return _msgImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 2;
        [self.backView insertSubview:_titleLabel atIndex:0];
    }
    return _titleLabel;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [UILabel new];
        _descLabel.font = [FrameLayoutTool UnitFont:12];//KFONT(12);
        _descLabel.numberOfLines = 2;
        _descLabel.textColor = [UIColor rgb109Color];
        [self.backView insertSubview:_descLabel atIndex:0];
    }
    return _descLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.backView.frame = CGRectMake(9 * KUNIT_WIDTH, 14 * KUNIT_HEIGHT, self.contentView.width - 18 * KUNIT_WIDTH, self.contentView.height - 14 * KUNIT_HEIGHT);
    self.backView.frame = CGRectMake(9 * FrameLayoutTool.UnitWidth, 14 * FrameLayoutTool.UnitHeight, self.contentView.zs_w - 18 * FrameLayoutTool.UnitWidth, self.contentView.zs_h - 14 * FrameLayoutTool.UnitHeight);
    self.foreView.frame = _backView.bounds;
    //self.msgImageView.frame = CGRectMake(12 * KUNIT_HEIGHT, 12 * KUNIT_HEIGHT, 88 * KUNIT_HEIGHT, 88 * KUNIT_HEIGHT);
    self.msgImageView.frame = CGRectMake(12 * FrameLayoutTool.UnitHeight, 12 * FrameLayoutTool.UnitHeight, 88 * FrameLayoutTool.UnitHeight, 88 * FrameLayoutTool.UnitHeight);
    //CGFloat titleMaxHeight = 45 * KUNIT_HEIGHT;
    CGFloat titleMaxHeight = 45 * FrameLayoutTool.UnitHeight;
    //CGFloat titleW = _backView.width - _msgImageView.maxX - 24 * KUNIT_WIDTH;
    CGFloat titleW = _backView.zs_w - _msgImageView.zs_maxX - 24 * FrameLayoutTool.UnitWidth;
    self.titleLabel.attributedTextTail = [_model getTitleAttributedWithMaxSize:CGSizeMake(titleW, titleMaxHeight)];
    //_titleLabel.frame = CGRectMake(_msgImageView.maxX + 12 * KUNIT_WIDTH, 12 * KUNIT_HEIGHT, titleW, _model.titleAttributedH > 0 ? _model.titleAttributedH : titleMaxHeight);
    _titleLabel.frame = CGRectMake(_msgImageView.zs_maxX + 12 * FrameLayoutTool.UnitWidth, 12 * FrameLayoutTool.UnitHeight, titleW, _model.titleAttributedH > 0 ? _model.titleAttributedH : titleMaxHeight);
    
    //CGFloat descMaxHeight = _backView.height - _titleLabel.maxY - 16 * KUNIT_HEIGHT;
    CGFloat descMaxHeight = _backView.zs_h - _titleLabel.zs_maxY - 16 * FrameLayoutTool.UnitHeight;
    //CGFloat descHeight = [_model.content sizeWithFont:KFONT(12) maxSize:CGSizeMake(_titleLabel.width, descMaxHeight)].height;
    CGFloat descHeight = [_model.content zs_sizeWithFont:[FrameLayoutTool UnitFont:12] textMaxSize:CGSizeMake(_titleLabel.zs_w, descMaxHeight)].height;
    //self.descLabel.frame = CGRectMake(_titleLabel.x, _titleLabel.maxY + 4 * KUNIT_HEIGHT, _titleLabel.width, descHeight > 0 ? descHeight : descMaxHeight);
    self.descLabel.frame = CGRectMake(_titleLabel.zs_x, _titleLabel.zs_maxY + 4 * FrameLayoutTool.UnitHeight, _titleLabel.zs_w, descHeight > 0 ? descHeight : descMaxHeight);
}

- (void)setModel:(JDSysMsgModel *)model{
    _model = model;
    [self.msgImageView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imgLogoGrayscaleSquare]];
    self.descLabel.text = model.content;
    self.foreView.hidden = ![model.isRead boolValue];
    
    [self layoutSubviews];
}

@end




@interface JDSysMsgView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation JDSysMsgView

- (CustomTableView *)tableView{
    if (!_tableView) {
        _tableView = [[CustomTableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.rowHeight  = 126 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _tableView.defultViewRowHeight = 126 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
        _tableView.backgroundColor = [UIColor whiteLeadColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[JDSysMsgCell class] forCellReuseIdentifier:NSStringFromClass([JDSysMsgCell class])];
        [_tableView registerClass:[JDChatTimeHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([JDChatTimeHeader class])];
        [_tableView displayClassForDefultView:[JDSysMsgCell class]];
         __weak typeof (self) weak_self = self;
        // TODO: 已完成接入下来刷新和上拉加载
        [RefreshTool initRefreshHeaderForScrollView:_tableView WithRefreshBlock:^{
            [weak_self refreshData];
        }];
        
        [RefreshTool initLoadMoreFooterFor:_tableView WithLoadMoreBlock:^{
            [weak_self loadMoreData];
        }];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)setGroupArray:(NSArray<JDSysMsgGroupModel *> *)groupArray{
    [self.tableView removeDefultView];
    if (groupArray.count) {
        // TODO: 已完成接入下拉刷新
        [RefreshTool clearEmptyViewForTableView:_tableView];
    }else{
        // TODO: 已完成接入下拉刷新
        [RefreshTool tableView:_tableView refreshEmptyDataForShowTitle:@"暂无活动优惠，去直播间看看" logo:[UIImage blankIndentImage] displayButton:NO displayTitle:nil buttonTarget:nil action:nil];
    }
    
    if (groupArray.count) {
        _groupArray = groupArray;
        [_tableView reloadData];
    }
}

- (void)refreshData{
    [RefreshTool resetNoSourceDataForScrollView:self.tableView];
    [RefreshTool resetNoMoreDataForScrollView:self.tableView];
    [self.delegate refreshDataSource];
}

- (void)loadMoreData{
    if (self.groupArray.count) {
        JDSysMsgGroupModel *model = [self.groupArray lastObject];
        if (model.msgArray.count) {
            JDSysMsgModel *sysModel = [model.msgArray lastObject];
            [self.delegate loadMoreMsgId:sysModel.msgId];
        }
    }
}

// Mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableVie{
    return _groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    JDSysMsgGroupModel *model = _groupArray[section];
    return model.msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JDSysMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JDSysMsgCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    JDSysMsgGroupModel *model = _groupArray[indexPath.section];
    JDSysMsgModel *msgModel = model.msgArray[indexPath.row];
    cell.model = msgModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42 * FrameLayoutTool.UnitHeight;
    //KUNIT_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    JDChatTimeHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([JDChatTimeHeader class])];
    header.contentView.backgroundColor = [UIColor clearColor];
    JDSysMsgGroupModel *model = _groupArray[section];
    header.dateTime = model.date;
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDSysMsgGroupModel *model = _groupArray[indexPath.section];
    JDSysMsgModel *msgModel = model.msgArray[indexPath.row];
    msgModel.isRead = @(1);
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.delegate didSelectRowAtModel:msgModel];
}

@end

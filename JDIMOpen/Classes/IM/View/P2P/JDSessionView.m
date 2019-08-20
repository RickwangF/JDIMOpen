//
//  JDSessionView.m
//  JadeKing
//
//  Created by 张森 on 2018/9/18.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionView.h"
#import "JDChatTimeHeader.h"
#import "FrameLayoutTool.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIColor+ProjectTool.h"
#import "NSString+ProjectTool.h"
#import "UIImage+ProjectTool.h"
#import "JDIMTool.h"
#import "NSString+ProjectTool.h"
#import "RefreshTool.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation JDSessionTable

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end


@interface JDSessionView ()<UITableViewDelegate, UITableViewDataSource, JDSessionCellDelegate>
/// 输入工具栏
@property (nonatomic, strong) JDInputToolBar *inputToolBar;

@end


@implementation JDSessionView

- (JDInputToolBar *)inputToolBar{
    if (!_inputToolBar) {
        _inputToolBar = [[JDInputToolBar alloc] init];
        _inputToolBar.zs_h = toolBarH * FrameLayoutTool.UnitHeight + FrameLayoutTool.HomeBtnHeight;//toolBarH * KUNIT_HEIGHT + KHOME_HEIGHT;
        _inputToolBar.backgroundColor = [UIColor whiteColor];
        __weak typeof (self) weak_self = self;
        _inputToolBar.keyBoardDidShow = ^{
            [weak_self scrollToBottom];
        };
        [self addSubview:_inputToolBar];
    }
    return _inputToolBar;
}

- (JDSessionTable *)tableView{
    if (!_tableView) {
        _tableView = [[JDSessionTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteLeadColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        __weak typeof (self) weak_self = self;
        //__weak typeof (_tableView) weak_tableView = _tableView;
       
        // TODO: 已完成接入下拉刷新        
        [RefreshTool initRefreshHeaderForScrollView:_tableView WithRefreshBlock:^{
            [weak_self refreshData];
        }];
        
        [self insertSubview:_tableView atIndex:0];
    }
    return _tableView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.inputToolBar.frame = CGRectMake(0, self.height - self.inputToolBar.height, KSWIDTH, _inputToolBar.height);
    self.inputToolBar.frame = CGRectMake(0, self.zs_h - self.inputToolBar.zs_h, FrameLayoutTool.Width, _inputToolBar.zs_h);
    //self.tableView.frame = CGRectMake(0, 0, self.width, _inputToolBar.y);
    self.tableView.frame = CGRectMake(0, 0, self.zs_w, _inputToolBar.zs_y);
}

- (void)refreshData{
    [RefreshTool resetNoSourceDataForScrollView:self.tableView];
    [RefreshTool resetNoMoreDataForScrollView:self.tableView];
    JDSessionModel *model = [self.modelArray firstObject];
    [self.delegate tableView:self.tableView pullGetDataSource:model.message];
}

- (void)scrollToBottom{
    if (_modelArray.count) {
        [self.tableView reloadData];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_modelArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)scrollToRowAtIndex:(NSInteger)index{
    if (index < _modelArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (CGRect)cellFrameOfIndex:(NSInteger)index{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    JDSessionCell *sessionCell = (JDSessionCell *)cell;
    CGRect frame = [sessionCell convertRect:sessionCell.contentImageView.frame toView:[UIApplication sharedApplication].keyWindow];
    return frame;
}

- (void)reloadCellOfIndex:(NSInteger)index{
    if (index < _modelArray.count) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)resetRecord{
    [_inputToolBar resetRecord];
}

- (void)keyBoardHide{
    [_inputToolBar endEditing:YES];
    [_inputToolBar keyBoardHide];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self keyBoardHide];
}

// Mark - JDSessionCellDelegate
- (void)onRevokedMessage:(JDSessionModel *)model{
    [self.delegate onRevokedMessage:model];
}

- (void)onRetryMessage:(JDSessionModel *)model{
    [self.delegate onRetryMessage:model];
}

- (void)didSelectCellAtMessage:(JDSessionModel *)model{
    [self.delegate didSelectCellAtMessage:model];
}

- (void)onOpenLink:(NSURL *)url{
    [self.delegate onOpenLink:url];
}

// Mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self keyBoardHide];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableVie{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JDSessionModel *model = _modelArray[indexPath.row];
    
    NSString *cellString = [JDSessionCellFactory sessionCellFactory:model.message];
    
    if (model.ext.type != JDSessionMsgUnknow) {
        cellString = [JDSessionCellFactory sessionCellFactoryType:model.ext.type];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if (!cell) {
        cell = [NSClassFromString(cellString) new];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    switch (model.message.messageType) {
        case NIMMessageTypeCustom:{
            JDSessionTipCell *tipCell = (JDSessionTipCell *)cell;
            tipCell.tipContent = @"当前版本不支持该消息类型";
            break;
        }
        case NIMMessageTypeTip:{
            JDSessionTipCell *tipCell = (JDSessionTipCell *)cell;
            tipCell.tipContent = model.message.text;
            break;
        }
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[JDSessionCell class]]) {
        JDSessionCell *sessionCell = (JDSessionCell *)cell;
        sessionCell.delegate = self;
        sessionCell.model = model;
        
        NSString *userAvater = [JDIMTool userAvatar];
        if (![userAvater isKindOfClass:[NSString class]]) {
            userAvater = nil;
        }
        NSURL *url = model.isMySelf ? [userAvater getOSSImageURL].URLWithString : _avatarUrl.URLWithString;
        [sessionCell.avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage defultAvatarImage]];
        if (indexPath.row > 0) {
            JDSessionModel *proModel = _modelArray[indexPath.row - 1];
            sessionCell.timestamp = ((proModel.timestamp == model.timestamp) ? 0 : model.message.timestamp);
        }else{
            sessionCell.timestamp = model.message.timestamp;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rowHeight = 0;
    CGFloat space = 14 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    CGFloat popSpace = 20 + space;
    CGFloat timeH = 42 * FrameLayoutTool.UnitHeight;//KUNIT_HEIGHT;
    
    JDSessionModel *model = _modelArray[indexPath.row];
    if (indexPath.row > 0) {
        JDSessionModel *proModel = _modelArray[indexPath.row - 1];
        timeH = ((proModel.timestamp == model.timestamp) ? 0 : 42 * FrameLayoutTool.UnitHeight);
    }
    
    if (model.ext.type != JDSessionMsgUnknow) {
        switch (model.ext.type) {
            case JDSessionMsgOrderCard:
                return 125 * FrameLayoutTool.UnitHeight + space + timeH;
            case JDSessionMsgGoodsCard:
                return 100 * FrameLayoutTool.UnitHeight + space + timeH;
            case JDSessionMsgAuctionCard:
                return 100 * FrameLayoutTool.UnitHeight + space + timeH;
            case JDSessionMsgSVideoCard:
                return 100 * FrameLayoutTool.UnitHeight + space + timeH;
            case JDSessionMsgNoSupport:
                return 34 * FrameLayoutTool.UnitHeight + space;
            default:
                break;
        }
    }
    
    switch (model.message.messageType) {
        case NIMMessageTypeCustom:
        case NIMMessageTypeTip:{
            rowHeight = 34 * FrameLayoutTool.UnitHeight + space;
            break;
        }
        case NIMMessageTypeText:{
            rowHeight = model.textSize.height + popSpace + timeH;
            break;
        }
        case NIMMessageTypeAudio:{
            rowHeight = 40 * FrameLayoutTool.UnitHeight + space + timeH;
            break;
        }
        case NIMMessageTypeImage:
        case NIMMessageTypeVideo:{
            BOOL isVertical = [model.messageObjectModel.h floatValue] >= [model.messageObjectModel.w floatValue];  // 是否是竖屏媒体
            rowHeight = timeH + space + (isVertical ? 141 * FrameLayoutTool.UnitHeight : 82 * FrameLayoutTool.UnitHeight);
            break;
        }
        default:
            break;
    }
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self keyBoardHide];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

@end

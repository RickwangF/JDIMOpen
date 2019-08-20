//
//  JDSessionCell.h
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSessionKitUtil.h"
#import "JDSessionModel.h"
#import "GIFImageView.h"

@protocol JDSessionCellDelegate <NSObject>

- (void)onRevokedMessage:(JDSessionModel *)model;
- (void)onRetryMessage:(JDSessionModel *)model;
- (void)didSelectCellAtMessage:(JDSessionModel *)model;
- (void)onOpenLink:(NSURL *)url;

@end

@interface JDSessionCell : UITableViewCell
@property (nonatomic, assign) NSTimeInterval timestamp;  // 消息时间戳
@property (nonatomic, strong) UIButton *retryButton;  // 发送失败重试按钮
@property (nonatomic, strong) UIActivityIndicatorView *activityView;  // 发送时的加载视图
@property (nonatomic, strong) GIFImageView *avatarImageView;  // 头像
@property (nonatomic, strong) GIFImageView *contentImageView;  // 气泡
@property (nonatomic, strong) JDSessionModel *model;  // 消息模型
@property (nonatomic, weak) id<JDSessionCellDelegate> delegate;  // 代理方法
@end



// Mark - 文本消息
@interface JDSessionTextCell : JDSessionCell

@end


// Mark - 语音消息
@interface JDSessionAudioCell : JDSessionCell

@end


// Mark - 图片消息
@interface JDSessionImageCell : JDSessionCell

@end


// Mark - 视频消息
@interface JDSessionVideoCell : JDSessionImageCell

@end

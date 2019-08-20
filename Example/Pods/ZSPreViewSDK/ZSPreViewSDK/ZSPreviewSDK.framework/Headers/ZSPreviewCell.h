//
//  ZSPreviewCell.h
//  JadeKing
//
//  Created by 张森 on 2018/10/31.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSPlayControlView;

typedef NS_ENUM(NSUInteger, ZSPreviewType) {
    /// 图片 defult
    ZSPreviewIMG,
    /// 视频
    ZSPreviewVDO,
    /// 音频
    ZSPreviewADO,
};

/// 放大的最大倍数
static const NSInteger maximumZoomScale = 2;
/// 缩小的最小倍数
static const NSInteger minimumZoomScale = 1;

@protocol ZSPreviewCellDelegate <NSObject>

/**
 关闭预览回调
 */
- (void)didSelectClosePreview;

/**
 长按触发事件

 @param type 文件类型
 @param mediaFile 文件
 */
- (void)longPressAction:(ZSPreviewType)type mediaFile:(id)mediaFile;

/**
 imageView加载http的图片
 
 @param imageView imageView
 @param url url
 */
- (void)imageView:(UIImageView *)imageView loadImageUrl:(NSURL *)url;

/**
 查看原图
 */
//- (void)refreshOriginImage;

@optional

/**
 媒体开始播放会回调，只用于处理特殊要求，一般用不上，返回值确定是否要播放

 @return 返回值确定是否要播放
 */
- (BOOL)beginPlay;

/**
 媒体加载中
 */
- (void)mediaLoading;

/**
 媒体加载失败
 */
- (void)mediaLoadFail:(NSError *)error;

/**
 媒体加载中完成
 */
- (void)mediaLoadComplete;

@end

@interface ZSPreviewCell : UICollectionViewCell
/// 代理
@property (nonatomic, weak) id<ZSPreviewCellDelegate> delegate;

/// 最大的放大倍数，default 2
@property (nonatomic, assign) CGFloat maximumZoomScale;

/// 最小的缩小倍速，default 1
@property (nonatomic, assign) CGFloat minimumZoomScale;

/**
 还原缩放比例
 */
- (void)zoomToOrigin;
@end


// Mark - 图片
@interface ZSPreviewImageCell : ZSPreviewCell
/// 缩略图文件（先设置）
@property (nonatomic, strong) id imageFile;

/// 媒体原文件
@property (nonatomic, strong) id mediaFile;

/// 媒体文件大小
@property (nonatomic, assign) CGFloat mediaFileBtye;

/// 图片无法加载时的默认图
@property (nonatomic, strong) UIImage *placeholderImage;

/// 图片展示
@property (nonatomic, strong, readonly) UIImageView *imageView;

/// 查看原图按钮
@property (nonatomic, strong, readonly) UIButton *downloadOriginaln;
@end


// Mark - 音视频
@interface ZSPreviewMediaCell : ZSPreviewImageCell
/// 播放按钮的图片
@property (nonatomic, assign) UIImage *playBtnImage;

/// 滑动进度滑块的图片
@property (nonatomic, assign) UIImage *sliderThumbImage;

/// 播放控制的图片
@property (nonatomic, assign) UIImage *playControlImage;

/// 暂停控制的图片
@property (nonatomic, assign) UIImage *pasueControlImage;

/// 播放控制面板
@property (nonatomic, strong, readonly) ZSPlayControlView *controlView;

/**
 停止播放
 */
- (void)stop;
@end

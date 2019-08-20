//
//  ZSPreviewTool.h
//  JadeKing
//
//  Created by 张森 on 2018/10/30.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSPreviewCell.h"

/**
 需要图片、视频、音频混合查看时使用
 */
@interface ZSPreviewModel : NSObject
/// 媒体文件
@property (nonatomic, strong) id mediaFile;

/// 缩略图（视频则传视频封面图）不传则默认直接加载原图
@property (nonatomic, strong) id thumbImage;

/// 媒体类型
@property (nonatomic, assign) ZSPreviewType type;

/// 媒体文件大小
@property (nonatomic, assign) CGFloat mediaFileBtye;
@end


@protocol ZSPreviewToolDelegate <NSObject>

@optional
/**
 长按的回调，用于处理长按事件，开启长按事件时必须实现
 
 @param type 文件类型
 @param mediaFile 文件
 */
- (void)zs_previewLongPressAction:(ZSPreviewType)type mediaFile:(id)mediaFile;

/**
 视图滚动的回调
 
 @param index 滚动的视图索引
 */
- (void)zs_previewScrollToIndex:(NSInteger)index;

/**
 媒体开始播放会回调，只用于处理特殊要求，一般用不上，返回值确定是否要播放
 
 @return 返回值确定是否要播放
 */
- (BOOL)zs_previewIsBeginPlay;

/**
 保存文件时，文件需要先下载的回调
 
 @param type 文件类型
 @param mediaFilePath 文件地址
 */
- (void)zs_previewSaveFileNeedDown:(ZSPreviewType)type
           mediaFilePath:(NSString *)mediaFilePath;

/**
 保存文件失败
 
 @param error 错误
 */
- (void)zs_previewSaveFileFail:(NSError *)error;

/**
 媒体加载中
 */
- (void)zs_previewMediaLoading;

/**
 媒体加载失败

 @param error 错误
 */
- (void)zs_previewMediaLoadFail:(NSError *)error;

/**
 媒体加载完成
 */
- (void)zs_previewMediaLoadComplete;

/**
 imageView加载http的图片

 @param imageView imageView
 @param url url
 */
- (void)zs_imageView:(UIImageView *)imageView loadImageUrl:(NSURL *)url;

@end



/*
 * 图片可传递UIImage和URL
 * 视频传递URL
 * 若为单一类型媒体时，数组可直接接收其媒体文件，若为混合媒体时，数组需要传递ZSPreviewModel类
 */
@interface ZSPreviewTool : UIView

/// 缩略图（视频则传视频封面图）不传则默认直接加载原图
@property (nonatomic, copy) NSArray *thumbImages;

/// 原始媒体
@property (nonatomic, copy) NSArray *originalMedias;

/// 是否开启长按事件
@property (nonatomic, assign) BOOL isLongPress;

/// 是否开启查看原图（点击查看原图会下载当前图片）
@property (nonatomic, assign) BOOL isOriginalImagePress;

/// 隐藏页码
@property (nonatomic, assign) BOOL isPageHidden;

/// 默认为图片（只展示一种类型的媒体文件时）
@property (nonatomic, assign) ZSPreviewType type;

/// 首先展示的媒体的索引
@property (nonatomic, assign) NSInteger firstMediaIndx;

/// 代理
@property (nonatomic, weak) id<ZSPreviewToolDelegate> delegate;

/**
 初始化视图

 @param previewSpace 预览视图之间的间距，default 20
 @return ZSPreviewTool对象
 */
- (ZSPreviewTool *)initWithPreviewSpace:(CGFloat)previewSpace;

/**
 预览方法
 */
- (void)preview;

/**
 关闭预览
 */
- (void)closePreview;

/**
 保存文件到相册
 
 @param type 文件类型
 @param mediaFile 文件
 */
- (void)saveAlbum:(ZSPreviewType)type
        mediaFile:(id)mediaFile;

/**
 提供外部重写对于UI的设置

 @param cell 预览的Cell
 */
- (void)refreshUI:(ZSPreviewCell *)cell;

/**
 提供外部重写视频音频开始加载的方法
 */
- (void)mediaLoading;

/**
 提供外部重写视频音频加载失败的方法

 @param error 错误
 */
- (void)mediaLoadFail:(NSError *)error;

/**
 提供外部重写视频音频加载完成的方法
 */
-(void)mediaLoadComplete;
@end


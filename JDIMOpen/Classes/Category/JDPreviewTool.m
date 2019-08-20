//
//  JDPreviewTool.m
//  JadeKing
//
//  Created by 张森 on 2019/6/21.
//  Copyright © 2019 张森. All rights reserved.
//

#import "JDPreviewTool.h"
//#import "JDNetService-Swift.h"
#import <JDNetService/JDNetService-Swift.h>
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "FrameLayoutTool.h"
#import "UIImage+ProjectTool.h"
#import "UIColor+ProjectTool.h"
#import <ZSToastUtil/ZSToastUtil-Swift.h>
//#import "ZSToastUtil-Swift.h"
//#import "JDLiveWindow.h"

@interface JDPreviewTool ()
@property (nonatomic, weak) ZSPreviewMediaCell *currentCell;
@end

@implementation JDPreviewTool

+ (void)saveResult:(NSError *)error{
    if (error) {
        [ZSTipView showTip:@"保存到相册失败，请检查设备存储空间"];
    }else{
        [ZSTipView showTip:@"已保存到相册"];
    }
}

+ (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    [self saveResult:error];
    if (!error) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL result = [fileManager removeItemAtPath:videoPath error:nil];
        if (!result) {
            [fileManager removeItemAtPath:videoPath error:nil];
        }
    }
}

+ (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    [self saveResult:error];
}

+ (void)saveAlbum:(ZSPreviewType)type mediaFile:(id)mediaFile{
    __weak typeof (self) weak_self = self;
    if (type == ZSPreviewIMG) {
        if ([mediaFile isKindOfClass:[UIImage class]]) {
            UIImageWriteToSavedPhotosAlbum(mediaFile, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }else{
//            [NetWorkingTool downloaderImage:mediaFile progress:^(CGFloat progress, NSURL *targetURL) {
////                [weak_self showProgress:progress];
//            } completed:^(UIImage *image) {
//                [weak_self saveAlbum:ZSPreviewIMG mediaFile:image];
//            }];
            
            [JDNetWorkTool Down:mediaFile progress:^(double progress) {
                
            } complete:^(NSString * _Nullable filePath, NSError * _Nullable error) {
                
                if ([NSObject zs_isEmpty:filePath]) {
                    return;
                }
                UIImage *image = [UIImage imageWithContentsOfFile: filePath];
                [weak_self saveAlbum:ZSPreviewIMG mediaFile:image];
            }];
        }
    }else{
        
        [JDNetWorkTool Down:mediaFile progress:^(double progress) {
            
        } complete:^(NSString * _Nullable filePath, NSError * _Nullable error) {
            if (![NSObject zs_isEmpty:error]) {
                [ZSTipView showTip:@"资源下载失败"];
                return;
            }
            NSLog(@"~~~%@", filePath);
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }];
    }
}

// Mark - overwrite
- (void)closePreview{
    [super closePreview];
    // 关闭静音
    //[JDLiveWindow closeMute];
}

- (void)refreshUI:(ZSPreviewCell *)cell{
    [ZSLoadingView stopAnimation];
    if ([cell isKindOfClass:[ZSPreviewMediaCell class]]) {
        ZSPreviewMediaCell *mediaCell = (ZSPreviewMediaCell *)cell;
        mediaCell.playBtnImage = [UIImage img_setImageOriginalName:@"news_play_big"];
        mediaCell.playControlImage  = [UIImage img_setImageOriginalName:@"news_play1"];
        mediaCell.pasueControlImage = [UIImage img_setImageOriginalName:@"news_play_pause"];
        mediaCell.sliderThumbImage  = [UIImage img_setImageOriginalName:@"news_play_circle"];
        _currentCell = (ZSPreviewMediaCell *)cell;
        return ;
    }
    
    if ([cell isKindOfClass:[ZSPreviewImageCell class]]) {
        ZSPreviewImageCell *imgCell = (ZSPreviewImageCell *)cell;
        imgCell.downloadOriginaln.layer.borderColor = [UIColor whiteLeadColor].CGColor;
        return ;
    }
}

- (void)mediaLoading{
    //[ZSLoadingView startAnimationClearToView:_currentCell.imageView msg:nil];
    [ZSLoadingView startAnimationTo:_currentCell.imageView isBackColorClear:NO];
}

- (void)mediaLoadFail:(NSError *)error{
    [ZSLoadingView stopAnimation];
    
    if (error.code == 404) {
        [ZSTipView showTip:@"资源损坏，无法加载"];
        return ;
    }
    
    [ZSTipView showTip:@"视频加载失败"];
}

- (void)mediaLoadComplete{
    [ZSLoadingView stopAnimation];
}

@end

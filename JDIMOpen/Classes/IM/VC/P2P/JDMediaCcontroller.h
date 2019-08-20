//
//  JDMediaCcontroller.h
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TZImagePickerController.h"
#import <TZImagePickerController/TZImagePickerController.h>

@protocol JDCamareCcontrollerDelegate <NSObject>

- (void)camareImageFinish:(UIImage *)image;
- (void)camareVideoFinish:(PHAsset *)asset;

@end

/// 聊天详情中使用的视频录制和图片拍摄的控制器
@interface JDCamareCcontroller : UIViewController
@property (nonatomic, weak) id<JDCamareCcontrollerDelegate> delegate;  // 代理
@property (nonatomic, strong) id requestParams;
@property (nonatomic, strong) id responseParams;
@end



@interface JDAlbumController : TZImagePickerController

@end

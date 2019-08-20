//
//  JDMediaCcontroller.m
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDMediaCcontroller.h"
#import "ZSLongPressCamareView.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import "TZImageManager.h"
#import <TZImagePickerController/TZImageManager.h>
#import "FrameLayoutTool.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIColor+ProjectTool.h"
#import "UIImage+ProjectTool.h"
//#import "ZSToastUtil-Swift.h"
#import <ZSToastUtil/ZSToastUtil-Swift.h>
//#import "JDLiveWindow.h"

@interface JDCamareCcontroller ()<ZSLongPressCamareViewDelegate>
@property (nonatomic, strong) ZSLongPressCamareView *camareView;  // 相机视图
@end

@implementation JDCamareCcontroller

- (ZSLongPressCamareView *)camareView{
    if (!_camareView) {
        _camareView = [ZSLongPressCamareView new];
        _camareView.delegate = self;
        [self.view addSubview:_camareView];
    }
    return _camareView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camareView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)alertError{
    __weak typeof (self) weak_self = self;
    ZSAlertView *alertView = [[ZSAlertView alloc] init];
    ZSPopAction *done = [ZSPopAction zs_initWithType:ZSPopActionTypeDone action:^{
        [weak_self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView addWithAction:done];
    [alertView alertWithTitle:@"温馨提示" message:@"保存相册失败\n请查看手机内存是否已经满了"];
}

// Mark - ZSLongPressCamareViewDelegate
- (void)closeCamareControll{
    [self dismissViewControllerAnimated:YES completion:nil];
    // 关闭静音
    //[JDLiveWindow closeMute];
}

- (void)camareFinish:(ZSCamareMediaType)type mediaFile:(id)mediaFile{
    
    __weak typeof(self) weak_self = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == ZSCamareMediaImage) {
            UIImageWriteToSavedPhotosAlbum(mediaFile, weak_self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }else{
            __block NSString *localIdentifier = nil;
            NSError *error;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mediaFile];
                localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                request.creationDate = [NSDate date];
            } error:&error];
            
            if (error) {
                [weak_self alertError];
            } else {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                [weak_self.delegate camareVideoFinish:asset];
                [weak_self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    });
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    
    __weak typeof(self) weak_self = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weak_self.delegate camareImageFinish:image];
        if (error) {
            [weak_self alertError];
        }else{
            [weak_self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

@end




@implementation JDAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = NO;
    
    // Default appearance, you can reset these after this method
    self.naviBgColor = [UIColor navigationColor];
    self.naviTitleColor =  [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];//KCOLOR(239, 239, 239, 1);
    self.naviTitleFont = [FrameLayoutTool UnitFont:18];//KFONT(18);
    self.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
        [leftButton setImage:[UIImage img_setImageOriginalName:@"ic_return1"] forState:UIControlStateNormal];
        leftButton.contentMode = UIViewContentModeLeft;
    };
    self.allowPickingMultipleVideo = YES;
    self.showPhotoCannotSelectLayer = YES;
    self.cannotSelectLayerColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    //KCOLOR(0, 0, 0, 0.7);
    self.allowTakeVideo = NO;
    self.allowTakePicture = NO;
    //    self.allowPickingGif = YES;
}

- (UIColor *)oKButtonTitleColorNormal{
    return [UIColor colorWithRed:0 green:118.0/255 blue:53.0/255 alpha:1.0];
    //return KCOLOR(0, 118, 53, 1);
}

- (UIColor *)oKButtonTitleColorDisabled{
    return [UIColor clearColor];
}

- (NSString *)previewBtnTitleStr{
    return @"预览";
}

- (NSString *)fullImageBtnTitleStr{
    return @"原图";
}

- (BOOL)allowTakePicture{
    return NO;
}

- (BOOL)allowTakeVideo{
    return NO;
}

@end

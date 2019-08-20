//
//  TZImageManager+Tool.h
//  JadeKing
//
//  Created by 张森 on 2019/7/4.
//  Copyright © 2019 张森. All rights reserved.
//

#import <TZImagePickerController/TZImageManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface TZImageManager (Tool)
+ (BOOL)isVideoCanSelect:(PHAsset *)asset
    videoMaximumDuration:(NSTimeInterval)videoMaximumDuration;
@end

NS_ASSUME_NONNULL_END

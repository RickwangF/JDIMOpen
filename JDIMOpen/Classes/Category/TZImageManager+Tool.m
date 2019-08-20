//
//  TZImageManager+Tool.m
//  JadeKing
//
//  Created by 张森 on 2019/7/4.
//  Copyright © 2019 张森. All rights reserved.
//

#import "TZImageManager+Tool.h"

@implementation TZImageManager (Tool)

+ (BOOL)isVideoCanSelect:(PHAsset *)asset
    videoMaximumDuration:(NSTimeInterval)videoMaximumDuration{
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        if (asset.duration > videoMaximumDuration) {
            return NO;
        }
    }
    return YES;
}

@end

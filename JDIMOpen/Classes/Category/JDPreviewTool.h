//
//  JDPreviewTool.h
//  JadeKing
//
//  Created by 张森 on 2019/6/21.
//  Copyright © 2019 张森. All rights reserved.
//

#import <ZSPreviewSDK/ZSPreviewSDK.h>

@interface JDPreviewTool : ZSPreviewTool

+ (void)saveAlbum:(ZSPreviewType)type mediaFile:(id)mediaFile;

@end


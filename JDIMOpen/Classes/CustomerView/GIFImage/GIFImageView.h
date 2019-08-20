//
//  ZSGIFImageView.h
//  JadeKing
//
//  Created by 张森 on 2018/11/9.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFImageView : UIImageView
//@property (nonatomic, copy) NSString *gifPath;  // 本地的Gif路径，链接使用sd即可
//@property (nonatomic, copy) NSString *gifName;  // 本地的Gif名称，带.gif后缀
@property (nonatomic, strong) NSData *gifData;  // gifData，用于列表加载大型GIF时需要使用队列，包含网络资源
@property (nonatomic, assign) BOOL isSupportGif;  // 是否支持Gif，仅对网络资源，不可大量加载gif
@end


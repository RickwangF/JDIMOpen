//
//  ZSLongPreeCamareView.h
//  JadeKing
//
//  Created by 张森 on 2018/10/12.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZSCamareMediaType) {
    ZSCamareMediaImage,
    ZSCamareMediaVideo
};

@protocol ZSLongPressCamareViewDelegate <NSObject>

- (void)closeCamareControll;
- (void)camareFinish:(ZSCamareMediaType)type mediaFile:(id)mediaFile;

@end


@interface ZSLongPressCamareView : UIView
@property (nonatomic, weak) id<ZSLongPressCamareViewDelegate> delegate;  // 代理
@end

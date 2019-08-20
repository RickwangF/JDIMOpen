//
//  ZSButton.h
//  JadeKing
//
//  Created by 张森 on 2018/10/11.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ButtonContentComposing) {
    ButtonImageLeftWithTitleRight,
    ButtonImageTopWithTitleBottom,
    ButtonImageRightWithTitleLeft,
};

@interface CustomButton : UIButton
@property (nonatomic, assign) ButtonContentComposing contentComposing;  // 按钮的排版，默认左图右字
@end

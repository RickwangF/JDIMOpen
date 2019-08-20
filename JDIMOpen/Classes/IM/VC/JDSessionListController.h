//
//  JDSessionListController.h
//  JadeKing
//
//  Created by 张森 on 2018/9/7.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 消息中心-会话列表控制器
@interface JDSessionListController : UIViewController

@property (nonatomic, strong) id requestParams;
@property (nonatomic, strong) id responseParams;

- (void)requestUnreadMsg;

@end

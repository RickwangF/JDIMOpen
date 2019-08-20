//
//  JDSysMsgController.h
//  JadeKing
//
//  Created by 张森 on 2018/9/14.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSysMsgModel.h"

/// 系统消息控制器-基类
@interface JDSysMsgController : UIViewController
@property (nonatomic, assign) NSInteger unreadCount;  // 未读消息数量
@property (nonatomic, strong) id requestParams;
@property (nonatomic, strong) id responseParams;

/**
 展示系统消息被点击后展示模型中url对应的页面，子类需要重写
 
 @param model 系统消息模型
 */
- (void)didSelectRowAtModel:(JDSysMsgModel *)model;

@end



@interface JDNoticeListController : JDSysMsgController

@end



@interface JDActionListController : JDSysMsgController

@end

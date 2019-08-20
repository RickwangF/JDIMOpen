//
//  JDSeverListView.h
//  JadeKing
//
//  Created by 张森 on 2018/11/20.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSeverListModel.h"

@interface JDSeverListView : UIView
@property (nonatomic, copy) NSArray <JDSeverListModel *>*severGroups;  // 客服分组数组
@property (nonatomic, copy) void(^onSever)(JDSeverModel *model);  // 点击客服对话
@end


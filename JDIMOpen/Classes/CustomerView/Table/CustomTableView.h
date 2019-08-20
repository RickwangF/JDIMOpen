//
//  ZSTableView.h
//  JadeKing
//
//  Created by 张森 on 2018/8/21.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableView : UITableView
@property (nonatomic, assign) CGFloat defultViewRowHeight;  // 默认视图的高度
- (void)displayClassForDefultView:(nullable Class)defultViewClass;  // 展示默认视图
- (void)reloadDefultView:(nullable Class)defultViewClass;  // 刷新默认视图
- (void)removeDefultView;  // 移除默认视图
@end

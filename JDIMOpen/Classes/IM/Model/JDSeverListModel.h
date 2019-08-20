//
//  JDSeverListModel.h
//  JadeKing
//
//  Created by 张森 on 2018/11/20.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDSeverModel : NSObject
/// 客服头像
@property (nonatomic, copy) NSString *avatar;

/// 客服昵称
@property (nonatomic, copy) NSString *username;

/// 客服云信账号
@property (nonatomic, copy) NSString *easeAcountUser;

/// 是否在线
@property (nonatomic, strong) NSNumber *online;
@end


@interface JDSeverListModel : NSObject
/// 平台名称
@property (nonatomic, copy) NSString *platName;

/// 客服模型集
@property (nonatomic, copy) NSArray <JDSeverModel *>*customerServices;

/// 平台ID
@property (nonatomic, strong) NSNumber *platID;

/// 平台的编码
@property (nonatomic, copy) NSString *platCode;

/// 是否折叠
@property (nonatomic, assign) BOOL isFold;
@end

//
//  JDSessionCellFactory.h
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDSessionCell.h"
#import "JDSessionTipCell.h"
#import "JDSessionCardCell.h"
#import <NIMSDK/NIMSDK.h>

@interface JDSessionCellFactory : NSObject
+ (NSString *)sessionCellFactory:(NIMMessage *)message;
+ (NSString *)sessionCellFactoryType:(JDSessionMsgType)type;
@end

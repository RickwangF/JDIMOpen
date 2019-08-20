//
//  JDOrderKitUtil.h
//  JadeKing
//
//  Created by 张森 on 2019/4/16.
//  Copyright © 2019 张森. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 老订单系统前端状态，暂时保留
typedef NS_ENUM(NSUInteger, JDOldOrderStatus) {
    /// 待付款
    JDOldOrderWaitPay    = 1,
    
    /// 待发货
    JDOldOrderWaitSend   = 3,
    
    /// 已发货
    JDOldOrderWaitDone   = 5,
    
    /// 已签收
    JDOldOrderFinishDone = 6,
    
    /// 退款中
    JDOldOrderReturnMoney= 7,
    
    /// 已完成
    JDOldOrderFinishTrade= 9,
    
    /// 默认
    JDOldOrderDefault    = 12,
    
    /// 客服确认
    JDOldOrderServerDone = 4,
    
    /// 待客服确认
    JDOldOrderWaitServer = 10,
};

/// 老订单系统后端状态，已弃用
typedef NS_ENUM(NSUInteger, JDOldOrderForBackStatus) {
    /// 待查货确认
    JDOldOrderForBackWaitSearchrGoods = 1,
    
    /// 待付款
    JDOldOrderForBackWaitPay          = 2,
    
    /// 待付款确认
    JDOldOrderForBackWaitPayDone      = 3,
    
    /// 待发货
    JDOldOrderForBackWaitSend         = 4,
    
    /// 已发货
    JDOldOrderForBackWaitDone         = 5,
    
    /// 已签收
    JDOldOrderForBackFinishDone       = 6,
    
    /// 申请退货
    JDOldOrderForBackAppleReturn      = 7,
    
    /// 待退款
    JDOldOrderForBackWaitReturnMoney  = 8,
    
    /// 已退款
    JDOldOrderForBackFinishReturnMoney= 9,
    
    /// 已取消
    JDOldOrderForBackAlreadyCancel    = 10,
    
    /// 已安全成交
    JDOldOrderForBackFinishPay        = 11,
};

/// 新订单系统状态
typedef NS_ENUM(NSUInteger, JDOrderStatus) {
    /// 默认
    JDOrderDefault    = 0,
    
    /// 待付款
    JDOrderWaitPay    = 1,
    
    /// 待发货
    JDOrderWaitSend   = 2,
    
    /// 已发货
    JDOrderWaitDone   = 3,
    
    /// 已完成
    JDOrderFinishDone = 4,
    
    /// 已逾期
    JDOrderOverdue    = 5
};

/// 售后订单系统状态
typedef NS_ENUM(NSUInteger, JDSaleOrderStatus) {
    /// 默认
    JDSaleOrderDefault    = 0,
    
    /// 待退货
    JDSaleOrderWaitSend   = 1,
    
    /// 待退款
    JDSaleOrderWaitRefund = 2,
    
    /// 已完成
    JDSaleOrderFinishDone = 3,
};


@interface JDOrderKitUtil : NSObject

/**
 获取老订单系统状态的字符串

 @param order_state 订单状态的标识
 @return 老订单系统状态的字符串
 */
+ (NSString *)getOldOrderStatus:(NSNumber *)order_state;

/**
 获取新订单系统状态的字符串

 @param order_state 订单状态的标识
 @return 新订单系统状态的字符串
 */
+ (NSString *)getOrderStatus:(NSNumber *)order_state;

/**
 获取售后订单状态的字符串

 @param order_state 订单状态的标识
 @return 售后订单状态的字符串
 */
+ (NSString *)getSaleOrderStatus:(NSNumber *)order_state;

/**
 验证商品锁并创建订单

 @param params 验证商品锁的参数
 */
+ (void)checkGoodsAndCreateOrder:(NSDictionary *)params;

@end

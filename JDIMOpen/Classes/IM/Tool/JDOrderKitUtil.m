//
//  JDOrderKitUtil.m
//  JadeKing
//
//  Created by 张森 on 2019/4/16.
//  Copyright © 2019 张森. All rights reserved.
//

#import "JDOrderKitUtil.h"

@implementation JDOrderKitUtil

+ (NSString *)getOldOrderStatus:(NSNumber *)order_state{
    JDOldOrderStatus orderStatus = [order_state integerValue];
    if ([order_state integerValue] == JDOldOrderForBackWaitPay) {
        orderStatus = JDOldOrderWaitPay;
    }
    
    if ([order_state integerValue] == JDOldOrderForBackWaitSend) {
        orderStatus = JDOldOrderWaitSend;
    }
    
    if ([order_state integerValue] == JDOldOrderForBackWaitReturnMoney) {
        orderStatus = JDOldOrderReturnMoney;
    }
    
    if ([order_state integerValue] == JDOldOrderForBackFinishPay) {
        orderStatus = JDOldOrderFinishTrade;
    }
    
    switch (orderStatus) {
        case JDOldOrderWaitPay:{
            return @"待付款";
        }
        case JDOldOrderWaitSend:{
            return @"待发货";
        }
        case JDOldOrderWaitDone:{
            return @"已发货";
        }
        case JDOldOrderFinishDone:{
            return @"已签收";
        }
        case JDOldOrderReturnMoney:{
            return @"退款中";
        }
        case JDOldOrderFinishTrade:{
            return @"已完成";
        }
        default:{
            return @"未知";
        }
    }
}


+ (NSString *)getOrderStatus:(NSNumber *)order_state{
    JDOrderStatus orderStatus = [order_state integerValue];
    switch (orderStatus) {
        case JDOrderWaitPay:{
            return @"待付款";
        }
        case JDOrderWaitSend:{
            return @"待发货";
        }
        case JDOrderWaitDone:{
            return @"已发货";
        }
        case JDOrderFinishDone:{
            return @"已完成";
        }
        case JDOrderOverdue:{
            return @"已逾期";
        }
        default:{
            return @"未知";
        }
    }
}

+ (NSString *)getSaleOrderStatus:(NSNumber *)order_state{
    JDSaleOrderStatus orderStatus = [order_state integerValue];
    switch (orderStatus) {
        case JDSaleOrderWaitSend:{
            return @"待退货";
        }
        case JDSaleOrderWaitRefund:{
            return @"待退款";
        }
        case JDSaleOrderFinishDone:{
            return @"已完成";
        }
        default:{
            return @"未知";
        }
    }
}

// Mark - 创建订单
+ (void)checkGoodsAndCreateOrder:(NSDictionary *)params{
    
//    [ZSLoadingView startAnimationToKeyWindow:nil];
//    
//    [JDNetWorkTool GET:NATIVE_BASE_HOST url:JD_Goods_Lock parameters:params contentId:nil timeOut:10 encoding:RequestEncodingURLDefult response:ResponseEncodingJSON headers:JDNetWorkTool.HTTPHeaders complete:^(id _Nullable info, NSData * _Nullable data, NSError * _Nullable error, NSString * _Nullable cacheCode) {
//        
//        [ZSLoadingView stopAnimation];
//        if (![ZSObjectTool isEmpty:error]) {
//            if (error.code != -2) {
//                [ZSTipView showTip:@"生成订单失败，请联系客服"];
//            }
//            return;
//        }
//        
//        if ([info isKindOfClass:[NSDictionary class]]) {
//            NSString *url = nil;
//            switch ([info[@"page"] integerValue]) {
//                case 1:{
//                    
//                    NSDictionary *param =
//                    @{
//                      @"goods_sn" : [ZSObjectTool getParamsValue:params[@"goodsSn"]],
//                      @"type"     : [ZSObjectTool getParamsValue:params[@"type"]]
//                      };
//                    
//                    url = [NSString stringWithFormat:@"jade://JD.Order.Create?%@", [ZSStringTool getUrlQueryString:param]];
//                    
//                    break;
//                }
//                case 2:{
//                    
//                    url = [NSString stringWithFormat:@"jade://JD.Order.Detail?%@", [ZSStringTool getUrlQueryString:@{@"order_sn" : [ZSObjectTool getParamsValue:info[@"ordersSn"]]}]];
//                    
//                    break;
//                }
//                case 3:{
//                    url = @"jade://JD.index.html/orders/createFail";
//                    break;
//                }
//                default:
//                    break;
//            }
//            
//            [JDRouteTool jd_pushRoute:url];
//            
//        }else{
//            [ZSTipView showTip:@"生成订单失败，请联系客服"];
//        }
//    }];
    

}

@end

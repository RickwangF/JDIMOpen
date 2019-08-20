//
//  JDSessionModel.m
//  JadeKing
//
//  Created by 张森 on 2018/11/8.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionModel.h"
#import "NSString+ProjectTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIColor+ProjectTool.h"
#import "FrameLayoutTool.h"
#import <MJExtension/MJExtension.h>

@implementation JDMessageObjectModel

- (void)setDur:(NSNumber *)dur{
    _dur = dur;
    
    NSInteger time = [dur floatValue] / 1000 + 0.5;
    NSInteger min = time / 60;
    NSInteger sec = time % 60;
    
    if (_isAudio) {
        if (min) {
            _timeString = [NSString stringWithFormat:@"%ld'%02ld''", (long)min, (long)sec];
        }else{
            _timeString = [NSString stringWithFormat:@"%ld''", (long)sec];
        }
    }else{
        _timeString = [NSString stringWithFormat:@"%ld:%02ld", (long)min, (long)sec];
    }
}

- (void)setIsAudio:(BOOL)isAudio{
    _isAudio = isAudio;
    self.dur = _dur;
}

@end




// Mark - 订单卡片
@implementation JDMessageOldOrderModel  // 老订单

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"orderId" : @"id"
             };
}

- (void)setOrder_goodprice:(id)order_goodprice{
    _order_goodprice = order_goodprice;
    
    NSString *price = @"";
    if ([order_goodprice isKindOfClass:[NSString class]]) {
        price = order_goodprice;
    } else {
        price = [NSString stringWithFormat:@"¥%@", order_goodprice];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"结缘价：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:1.0]}]]; // [UIColor themeRedColor]
    _price = [attriString copy];
    
}

- (void)setOrder_goodlogo:(NSString *)order_goodlogo{
    _order_goodlogo = [order_goodlogo getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:order_goodlogo];
}

- (void)setOrder_state:(NSNumber *)order_state{
    _order_state = order_state;
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"订单状态：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    //[attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getOldOrderStatus:order_state] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getOldOrderStatus:order_state] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _orderStatusString = [attriStr copy];
}

@end




@implementation JDMessageOrderModel  // 新订单

- (void)setActualPrice:(id)actualPrice{
    _actualPrice = actualPrice;
    
    NSString *price = @"";
    if ([actualPrice isKindOfClass:[NSString class]]) {
        price = actualPrice;
    } else {
        price = [NSString stringWithFormat:@"¥%@", actualPrice];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"总计：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:1.0]}]]; //[UIColor themeRedColor]
    _price = [attriString copy];
}

- (void)setRemainMoney:(id)remainMoney{
    _remainMoney = remainMoney;
    
    NSString *price = @"";
    if ([remainMoney isKindOfClass:[NSString class]]) {
        price = remainMoney;
    }else{
        price = [NSString stringWithFormat:@"¥%@", remainMoney];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"需付款：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:1.0]}]]; //  [UIColor themeRedColor]
    _needPrice = [attriString copy];
}


- (void)setGoodsCount:(NSNumber *)goodsCount{
    _goodsCount = goodsCount;
    
    NSString *goodsCountString = [NSObject zs_isEmpty:goodsCount] ? @"0" : [NSString stringWithFormat:@"%@", goodsCount];
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"共计 " attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; // [UIColor rgb82Color]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:goodsCountString attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:1.0]}]]; //[UIColor themeRedColor]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:@" 件宝贝" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]]; //[UIColor rgb82Color]
    
    _goodsCountString = [attriString copy];
}

- (void)setGoodsLogo:(NSString *)goodsLogo{
    _goodsLogo = [goodsLogo getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:goodsLogo];
}

- (void)setOrdersStatus:(NSNumber *)ordersStatus{
    _ordersStatus = ordersStatus;
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"订单状态：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    //[attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getOrderStatus:ordersStatus] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getOrderStatus:ordersStatus] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _orderStatusString = [attriStr copy];
}

@end




@implementation JDMessageSaleOrderModel  // 售后订单

- (void)setMoney:(id)money{
    _money = money;
    
    NSString *price = @"";
    if ([money isKindOfClass:[NSString class]]) {
        price = money;
    } else {
        price = [NSString stringWithFormat:@"¥%@", money];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"退款金额：" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1.0]}]; //[UIColor rgb82Color]
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:236.0/255 green:43.0/255 blue:36.0/255 alpha:1.0]}]]; //[UIColor themeRedColor]
    _price = [attriString copy];
}

- (void)setCoinDeductionApportion:(id)coinDeductionApportion{
    _coinDeductionApportion = coinDeductionApportion;
    
    NSString *coin = @"";
    if ([coinDeductionApportion isKindOfClass:[NSString class]]) {
        coin = coinDeductionApportion;
    } else {
        coin = [NSString stringWithFormat:@"%@", coinDeductionApportion];
    }
    
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"通宝返回：" attributes:@{NSForegroundColorAttributeName : [UIColor rgb82Color]}];
    [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:coin attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _coin = [attriStr copy];
}

- (void)setGoodsLogo:(NSString *)goodsLogo{
    _goodsLogo = [goodsLogo getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:goodsLogo];
}

- (void)setRefundStatus:(NSNumber *)refundStatus{
    _refundStatus = refundStatus;
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"订单状态：" attributes:@{NSForegroundColorAttributeName : [UIColor rgb82Color]}];
    //[attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getSaleOrderStatus:refundStatus] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:[JDOrderKitUtil getSaleOrderStatus:refundStatus] attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _orderStatusString = [attriStr copy];
}

@end



// Mark - 商品卡片
@implementation JDMessageGoodsModel

- (void)setShopPrice:(id)shopPrice{
    _shopPrice = shopPrice;
    
    NSString *price = @"";
    if ([shopPrice isKindOfClass:[NSString class]]) {
        price = shopPrice;
    }else{
        price = [NSString stringWithFormat:@"¥%@", shopPrice];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"结缘价：" attributes:@{NSForegroundColorAttributeName : [UIColor rgb82Color]}];
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _price = [attriString copy];
}

- (void)setGoodsThumb:(NSString *)goodsThumb{
    _goodsThumb = [goodsThumb getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:goodsThumb];
}

@end




// Mark - 拍卖卡片
@implementation JDMessageAuctionModel

- (void)setPrice:(id)price{
    _price = price;
    NSString *priceString = @"";
    if ([price isKindOfClass:[NSString class]]) {
        priceString = price;
    }else{
        priceString = [NSString stringWithFormat:@"¥%@", price];
    }
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"当前价：" attributes:@{NSForegroundColorAttributeName : [UIColor rgb82Color]}];
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:priceString attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _attributePrice = [attriString copy];
}

- (void)setAuction_id:(NSString *)auction_id{
    _auction_id = auction_id;
    [self urlReplaceJadeScheme];
}

- (void)urlReplaceJadeScheme{
    
    if ([_url isKindOfClass:[NSString class]]) {
        if ([_url zs_isValidUrl] || [NSOrderedSet zs_isEmpty:_url]) {
            _url = [NSString stringWithFormat:@"jade://JD.Auction.Detail?auctionId=%@", _auction_id];
        }
    }
}

@end




// Mark - 小视频卡片
@implementation JDMessageSVideoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"svideoId" : @"id"
             };
}

- (void)setPrice:(id)price{
    _price = price;
    NSString *priceString = @"";
    if ([price isKindOfClass:[NSString class]]) {
        priceString = price;
    }else{
        priceString = [NSString stringWithFormat:@"¥%@", price];
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"结缘价：" attributes:@{NSForegroundColorAttributeName : [UIColor rgb82Color]}];
    [attriString appendAttributedString:[[NSAttributedString alloc] initWithString:priceString attributes:@{NSForegroundColorAttributeName : [UIColor themeRedColor]}]];
    _attributePrice = [attriString copy];
}

- (void)setGoodsId:(NSString *)goodsId{
    self.svideoId = goodsId;
}

- (void)setGoodsThumb:(NSString *)goodsThumb{
    self.goodsLogo = goodsThumb;
}

- (void)setGoodsName:(NSString *)goodsName{
    self.title = goodsName;
}

- (void)setShopPrice:(NSString *)shopPrice{
    self.price = shopPrice;
}

@end




// Mark - 兼容RN扩展
@implementation JDMessageExtModel

- (JDMessageGoodsModel *)goodsModel{
    if (_type == JDSessionMsgGoodsCard) {
        return [JDMessageGoodsModel mj_objectWithKeyValues:_content];
    }
    return nil;
}

- (id)orderModel{
    if (_type == JDSessionMsgOrderCard) {
        if ([_chatType isEqualToString:@"afterSale"]) {
            return [JDMessageSaleOrderModel mj_objectWithKeyValues:_content];
        }else if ([_chatType isEqualToString:@"newOrderData"]){
            return [JDMessageOrderModel mj_objectWithKeyValues:_content];
        }else{
            return [JDMessageOldOrderModel mj_objectWithKeyValues:_content];
        }
    }
    return nil;
}

- (JDMessageAuctionModel *)auctionModel{
    if (_type == JDSessionMsgAuctionCard) {
        return [JDMessageAuctionModel mj_objectWithKeyValues:_content];
    }
    return nil;
}

- (JDMessageSVideoModel *)svideoModel{
    if (_type == JDSessionMsgSVideoCard) {
        return [JDMessageSVideoModel mj_objectWithKeyValues:_content];
    }
    return nil;
}

- (void)setMessageType:(NSString *)messageType{
    _messageType = messageType;
    if ([messageType isEqualToString:@"JDSessionMsgOrderCard"]) {
        _type = JDSessionMsgOrderCard;
    }else if ([messageType isEqualToString:@"JDSessionMsgGoodsCard"]){
        _type = JDSessionMsgGoodsCard;
    }else if ([messageType isEqualToString:@"JDSessionMsgAuctionCard"]){
        _type = JDSessionMsgAuctionCard;
    }else if ([messageType isEqualToString:@"JDSessionMsgSVideoCard"]){
        _type = JDSessionMsgSVideoCard;
    }
}

- (void)setContent:(id)content{
    _content = content;
    NSDictionary *dic = [content mj_JSONObject];
    if (_type == JDSessionMsgUnknow && [dic isKindOfClass:[NSDictionary class]]) {
        NSString *chatType = dic[@"chatType"];
        if ([chatType isEqualToString:@"orderData"]) {
            _type = JDSessionMsgGoodsCard;
        }else if([chatType isEqualToString:@"smallVideo"]){
            _type = JDSessionMsgSVideoCard;
        }else if([chatType isEqualToString:@"auction"]){
            _type = JDSessionMsgAuctionCard;
        }else{
            _type = JDSessionMsgOrderCard;
        }
    }
}

@end


@implementation JDSessionModel

- (void)setMessage:(NIMMessage *)message{
    _message = message;
    
    self.timestamp = message.timestamp;
    _isSending = (message.deliveryState == NIMMessageDeliveryStateDelivering);
    _isMySelf = message.isOutgoingMsg;
    _isSendError = (message.deliveryState == NIMMessageDeliveryStateFailed);
    _canMessageBeRevoked = [JDSessionKitUtil canMessageBeRevoked:message];
    _messageObjectModel = [JDMessageObjectModel mj_objectWithKeyValues:[message.messageObject description]];
    
    if ([NSObject zs_isEmpty:message.remoteExt[@"ext"]]) {
        _ext = [JDMessageExtModel mj_objectWithKeyValues:message.remoteExt];
    }else{
        _ext = [JDMessageExtModel mj_objectWithKeyValues:message.remoteExt[@"ext"]];
    }

    switch (message.messageType) {
        case NIMMessageTypeVideo:{
            NIMVideoObject *videoObject = (NIMVideoObject *)message.messageObject;
            _path      = [videoObject path];
            _coverUrl  = [videoObject coverUrl];
            _coverPath = [videoObject coverPath];
            break;
        }
        case NIMMessageTypeImage:{
            NIMImageObject *imageObject = (NIMImageObject *)message.messageObject;
            _path      = [imageObject path];
            _thumbUrl  = [imageObject thumbUrl];
            _thumbPath = [imageObject thumbPath];
            break;
        }
        case NIMMessageTypeAudio:{
            _isAudioPlayed = message.isPlayed;
            CGFloat time = [_messageObjectModel.dur floatValue] / 1000;
            _audioWidth = MAX(200*FrameLayoutTool.UnitWidth*time/60, 60*FrameLayoutTool.UnitWidth);
            //_audioWidth = MAX(200 * KUNIT_WIDTH * time / 60, 60 * KUNIT_WIDTH);
            _messageObjectModel.isAudio = YES;
            break;
        }
        case NIMMessageTypeText:{
            //_attributeText = [[JDSessionKitUtil replaceEmoji:message.text] addAttributedFont:KFONT(15) maxSize:CGSizeMake(245 * KUNIT_WIDTH, MAXFLOAT) attribute:@{NSForegroundColorAttributeName : [UIColor rgb82Color]} lineHeight:5 * KUNIT_HEIGHT alignment:NSTextAlignmentLeft autoLineBreak:YES];
            _attributeText = [[JDSessionKitUtil replaceEmoji:message.text] zs_addWithFont:[FrameLayoutTool UnitFont:15] textMaxSize:CGSizeMake(245*FrameLayoutTool.UnitWidth, MAXFLOAT) attributes:@{NSForegroundColorAttributeName: [UIColor rgb82Color]} alignment:NSTextAlignmentLeft lineHeight:5*FrameLayoutTool.UnitHeight headIndent:0 tailIndent:0 isAutoLineBreak:YES];
            //_textSize = [_attributeText sizeWithMaxSize:CGSizeMake(245 * KUNIT_WIDTH, MAXFLOAT)];
            _textSize = [_attributeText zs_sizeWithTextMaxSize:CGSizeMake(245*FrameLayoutTool.UnitWidth, MAXFLOAT)];
            break;
        }
        default:
            break;
    }
    
}

- (void)setTimestamp:(NSTimeInterval)timestamp{
    NSInteger digit = pow(10, timeSpace.length - 1);
    NSInteger msgTimestamp = timestamp / digit;
    msgTimestamp = msgTimestamp - roundf([timeSpace floatValue] / digit);
    msgTimestamp = msgTimestamp * digit;
    _timestamp = msgTimestamp;
}

- (void)setIsAudioPlayed:(BOOL)isAudioPlayed{
    _isAudioPlayed = isAudioPlayed;
    _message.isPlayed = isAudioPlayed;
}

@end

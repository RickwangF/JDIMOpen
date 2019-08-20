//
//  JDSessionCardCell.h
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionCell.h"

// Mark - 卡片消息
@interface JDSessionCardCell : JDSessionCell

@end


// Mark - 商品卡片
@interface JDSessionGoodsCardCell : JDSessionCardCell

@end


// Mark - 订单卡片
@interface JDSessionOrderCardCell : JDSessionGoodsCardCell

@end


// Mark - 拍卖卡片
@interface JDSessionAuctionCardCell : JDSessionGoodsCardCell

@end


// Mark - 小视频卡片
@interface JDSessionSVideoCardCell : JDSessionGoodsCardCell

@end

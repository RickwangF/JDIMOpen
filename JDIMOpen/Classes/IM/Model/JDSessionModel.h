//
//  JDSessionModel.h
//  JadeKing
//
//  Created by 张森 on 2018/11/8.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>
#import "JDSessionKitUtil.h"
#import "JDOrderKitUtil.h"

/// 消息发送时间以6分钟为分割
static const NSString *timeSpace = @"360";

@interface JDMessageObjectModel : NSObject
/// 链接
@property (nonatomic, copy) NSString *url;

/// 扩展
@property (nonatomic, copy) NSString *ext;

/// md5
@property (nonatomic, copy) NSString *md5;

/// 时长 (毫秒)
@property (nonatomic, strong) NSNumber *dur;

/// 文件大小
@property (nonatomic, strong) NSNumber *size;

/// 视频、图片高度
@property (nonatomic, strong) NSNumber *h;

/// 视频、图片宽度
@property (nonatomic, strong) NSNumber *w;

/// 时长
@property (nonatomic, copy) NSString *timeString;

/// 是否是语音
@property (nonatomic, assign) BOOL isAudio;

/// 视频、图片UI高度
@property (nonatomic, assign) CGFloat heigtUI;

/// 视频、图片UI宽度
@property (nonatomic, assign) CGFloat widthUI;
@end


// Mark - 订单卡片
/// 老订单模型
@interface JDMessageOldOrderModel : NSObject
/// 订单id
@property (nonatomic, strong) NSNumber *orderId;

/// 订单状态
@property (nonatomic, strong) NSNumber *order_state;

/// 订单商品名称
@property (nonatomic, copy) NSString *order_goodname;

/// 订单编号
@property (nonatomic, copy) NSString *order_sn;

/// 订单商品编号
@property (nonatomic, copy) NSString *order_goodsn;

/// 订单商品图片
@property (nonatomic, copy) NSString *order_goodlogo;

/// 订单商品价格
@property (nonatomic, strong) id order_goodprice;

// 扩展字段
/// 商品价格，带¥
@property (nonatomic, copy) NSAttributedString *price;

/// 订单状态文字
@property (nonatomic, copy) NSAttributedString *orderStatusString;
@end


/// 新订单模型
@interface JDMessageOrderModel : NSObject
/// 订单商品图片
@property (nonatomic, copy) NSString *goodsLogo;

/// 订单编号
@property (nonatomic, copy) NSString *ordersSn;

/// 订单还需支付金额
@property (nonatomic, strong) id remainMoney;

/// 订单总金额
@property (nonatomic, strong) id actualPrice;

/// 订单状态
@property (nonatomic, strong) NSNumber *ordersStatus;

/// 商品总数
@property (nonatomic, strong) NSNumber *goodsCount;

// 扩展字段
/// 订单金额，带¥
@property (nonatomic, copy) NSAttributedString *price;

/// 商品总数
@property (nonatomic, copy) NSAttributedString *goodsCountString;

/// 订单还需支付金额，带¥
@property (nonatomic, copy) NSAttributedString *needPrice;

/// 订单状态文字
@property (nonatomic, copy) NSAttributedString *orderStatusString;
@end


/// 售后订单模型
@interface JDMessageSaleOrderModel : NSObject
/// 订单商品图片
@property (nonatomic, copy) NSString *goodsLogo;

/// 订单编号
@property (nonatomic, copy) NSString *ordersSn;

/// 商品编号
@property (nonatomic, copy) NSString *goodsSn;

/// 订单退款金额
@property (nonatomic, strong) id  money;

/// 通宝返回
@property (nonatomic, strong) id coinDeductionApportion;

/// 订单状态
@property (nonatomic, strong) NSNumber *refundStatus;

// 扩展字段
/// 订单退款金额，带¥
@property (nonatomic, copy) NSAttributedString *price;

/// 订单退回通宝
@property (nonatomic, copy) NSAttributedString *coin;

/// 订单状态文字
@property (nonatomic, copy) NSAttributedString *orderStatusString;
@end




// Mark - 商品卡片
@interface JDMessageGoodsModel : NSObject
/// 商品价格
@property (nonatomic, strong) id shopPrice;

/// 商品id
@property (nonatomic, strong) NSNumber *goodsId;

/// 平台id
@property (nonatomic, strong) NSNumber *fromp;

/// 商品名称
@property (nonatomic, copy) NSString *goodsName;

/// 商品编号
@property (nonatomic, copy) NSString *goodsSn;

/// 商品图片
@property (nonatomic, copy) NSString *goodsThumb;

/// 类型（RN的消息垃圾处理）
@property (nonatomic, copy) NSString *chatType;

// 扩展字段
/// 商品价格，带¥
@property (nonatomic, copy) NSAttributedString *price;
@end




// Mark - 拍卖卡片
@interface JDMessageAuctionModel : NSObject
/// 拍卖图片
@property (nonatomic, copy) NSString *cover;

/// 标题
@property (nonatomic, copy) NSString *title;

/// 货号
@property (nonatomic, copy) NSString *auction_no;

/// 价格
@property (nonatomic, strong) id price;

/// 路由
@property (nonatomic, copy) NSString *url;

/// 拍卖id
@property (nonatomic, copy) NSString *auction_id;

// 扩展字段
/// 商品价格，带¥
@property (nonatomic, copy) NSAttributedString *attributePrice;

@end





// Mark - 小视频卡片
@interface JDMessageSVideoModel : NSObject
/// 小视频图片
@property (nonatomic, copy) NSString *goodsLogo;

/// 标题
@property (nonatomic, copy) NSString *title;

/// 类型
@property (nonatomic, copy) NSString *type;

/// 价格
@property (nonatomic, copy) NSString *price;

/// 路由
@property (nonatomic, copy) NSString *url;

/// 小视频id
@property (nonatomic, copy) NSString *svideoId;


// 兼容RN
@property (nonatomic, copy) NSString *goodsId; 
@property (nonatomic, copy) NSString *goodsThumb;
@property (nonatomic, copy) NSString *shopPrice;
@property (nonatomic, copy) NSString *goodsName;

// 扩展字段
@property (nonatomic, copy) NSAttributedString *attributePrice;  // 商品价格，带¥

@end




// Mark - 兼容RN扩展
@interface JDMessageExtModel : NSObject
/// 消息类型（兼容RN）
@property (nonatomic, copy) NSString *chatType;

/// 消息类型
@property (nonatomic, copy) NSString *messageType;

/// 消息内容
@property (nonatomic, copy) id content;

/// 类型
@property (nonatomic, assign) JDSessionMsgType type;

/// 订单模型
@property (nonatomic, strong) id orderModel;

/// 商品模型
@property (nonatomic, strong) JDMessageGoodsModel *goodsModel;

/// 拍卖模型
@property (nonatomic, strong) JDMessageAuctionModel *auctionModel;

/// 小视频模型
@property (nonatomic, strong) JDMessageSVideoModel *svideoModel;
@end


@interface JDSessionModel : NSObject
/// 消息
@property (nonatomic, strong) NIMMessage *message;

/// 正在发送
@property (nonatomic, assign) BOOL isSending;

/// 发送出错
@property (nonatomic, assign) BOOL isSendError;

/// 是否是自己发送的消息
@property (nonatomic, assign) BOOL isMySelf;

/// 正在导出，只有媒体有
@property (nonatomic, assign) BOOL isExport;

/// 是否可以撤回
@property (nonatomic, assign) BOOL canMessageBeRevoked;

/// 发送进度
@property (nonatomic, assign) CGFloat progress;

/// messageObject
@property (nonatomic, strong) JDMessageObjectModel *messageObjectModel;

/// 富文本内容
@property (nonatomic, copy) NSAttributedString *attributeText;

/// 文本消息的宽高
@property (nonatomic, assign) CGSize textSize;

/// 语音是否播放过
@property (nonatomic, assign) BOOL isAudioPlayed;

/// 是否播放动画
@property (nonatomic, assign) BOOL isAnimation;

/// 语音宽度
@property (nonatomic, assign) CGFloat audioWidth;

/// 消息发送时间
@property (nonatomic, assign) NSTimeInterval timestamp;

/// 视频封面
@property (nonatomic, copy) NSString *coverUrl;

/// 图片缩略图
@property (nonatomic, copy) NSString *thumbUrl;

/// 视频本地封面
@property (nonatomic, copy) NSString *coverPath;

/// 本地图片、视频
@property (nonatomic, copy) NSString *path;

/// 图片本地缩略图
@property (nonatomic, copy) NSString *thumbPath;

// Mark - 消息扩展
/// 消息扩展，主要是订单、商品卡片
@property (nonatomic, strong) JDMessageExtModel *ext;
@end


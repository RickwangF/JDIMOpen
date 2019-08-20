//
//  JDSessionCardCell.m
//  JadeKing
//
//  Created by 张森 on 2018/10/16.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionCardCell.h"
#import "JDPreviewTool.h"
#import "GIFImageView.h"
#import "UIColor+ProjectTool.h"
#import "FrameLayoutTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIImage+ProjectTool.h"
#import "NSString+ProjectTool.h"
#import <ZSToastUtil/ZSToastUtil-Swift.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface JDSessionCardCell ()<ZSPreviewToolDelegate>
@property (nonatomic, strong) GIFImageView *logoImageView;  // 图片
@property (nonatomic, strong) UILabel *titLabel;  // 标题、内容
@end

@implementation JDSessionCardCell

- (GIFImageView *)logoImageView{
    if (!_logoImageView) {
        _logoImageView = [GIFImageView new];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.clipsToBounds = YES;
        _logoImageView.backgroundColor = [UIColor rgb109Color];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [_logoImageView addGestureRecognizer:tap];
        _logoImageView.userInteractionEnabled = YES;
        [self.contentImageView addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UILabel *)titLabel{
    if (!_titLabel) {
        _titLabel = [UILabel new];
        _titLabel.numberOfLines = 2;
        _titLabel.font = [FrameLayoutTool UnitFont:14];//KFONT(14);
        _titLabel.textColor = [UIColor rgb51Color];
        _titLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentImageView addSubview:_titLabel];
    }
    return _titLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //CGFloat logoX = self.model.isMySelf ? 9 * KUNIT_WIDTH : 13 * KUNIT_WIDTH;
    CGFloat logoX = self.model.isMySelf ? 9 * FrameLayoutTool.UnitWidth : 13 * FrameLayoutTool.UnitWidth;
    //self.logoImageView.frame = CGRectMake(logoX, (self.contentImageView.height - 82 * KUNIT_HEIGHT) * 0.5, 82 * KUNIT_HEIGHT, 82 * KUNIT_HEIGHT);
    self.logoImageView.frame = CGRectMake(logoX, (self.contentImageView.zs_h - 82 * FrameLayoutTool.UnitHeight) * 0.5, 82 * FrameLayoutTool.UnitHeight, 82 * FrameLayoutTool.UnitHeight);
    //self.titLabel.frame = CGRectMake(_logoImageView.maxX + 8 * KUNIT_WIDTH, _logoImageView.y, self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, self.titLabel.height);
    self.titLabel.frame = CGRectMake(_logoImageView.zs_maxX + 8 * FrameLayoutTool.UnitWidth, _logoImageView.zs_y, self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, self.titLabel.zs_h);
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    //self.contentImageView.width = 266 * KUNIT_WIDTH;
    self.contentImageView.zs_w = 266 * FrameLayoutTool.UnitWidth;
    //self.contentImageView.height = 100 * KUNIT_HEIGHT;
    self.contentImageView.zs_h = 100 * FrameLayoutTool.UnitHeight;
}

- (void)copy:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSObject zs_paramsValue:_titLabel.text];
}

// Mark - Action
- (void)clickImage{
    
}

// Mark - ZSPreviewToolDelegate
- (void)zs_previewLongPressAction:(ZSPreviewType)type mediaFile:(id)mediaFile{
    // 保存媒体的代码
    ZSSheetView *sheetView = [[ZSSheetView alloc] init];
    sheetView.sheetActionHeight = FrameLayoutTool.IsIpad ? 80*FrameLayoutTool.UnitHeight : 60*FrameLayoutTool.UnitHeight;
    ZSPopAction *save = [ZSPopAction zs_initWithType:ZSPopActionTypeDone action:^{
        [JDPreviewTool saveAlbum:type mediaFile:mediaFile];
    }];
    [save setTitle:@"保存" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor colorWithRed:87.0/255 green:87.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateNormal];
    ZSPopAction *cancel = [ZSPopAction zs_initWithType:ZSPopActionTypeCancel action:^{}];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithRed:18.0/255 green:125.0/255 blue:198.0/255 alpha:1.0] forState:UIControlStateNormal];
    [sheetView addWithAction:save];
    [sheetView addWithAction:cancel];
    [sheetView sheetWithTitle:nil];
}

- (void)zs_imageView:(UIImageView *)imageView loadImageUrl:(NSURL *)url{
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imgLogoGrayscaleSquare]];
}

@end



// Mark - 商品卡片
@interface JDSessionGoodsCardCell ()
@property (nonatomic, strong) UILabel *goodsIdLabel;  // 货号
@property (nonatomic, strong) UILabel *priceLabel;  // 价格
@end

@implementation JDSessionGoodsCardCell

- (UILabel *)goodsIdLabel{
    if (!_goodsIdLabel) {
        _goodsIdLabel = [UILabel new];
        _goodsIdLabel.font = [FrameLayoutTool UnitFont:13];
        //KFONT(13);
        _goodsIdLabel.textColor = [UIColor rgb82Color];
        [self.contentImageView addSubview:_goodsIdLabel];
    }
    return _goodsIdLabel;
}

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.font = [FrameLayoutTool UnitFont:13];
        //KFONT(13);
        [self.contentImageView addSubview:_priceLabel];
    }
    return _priceLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.priceLabel.frame = CGRectMake(self.titLabel.x, self.logoImageView.maxY - 20 * KUNIT_HEIGHT, self.titLabel.width, 15 * KUNIT_HEIGHT);
    self.priceLabel.frame = CGRectMake(self.titLabel.zs_x, self.logoImageView.zs_maxY - 20 * FrameLayoutTool.UnitHeight, self.titLabel.zs_w, 15 * FrameLayoutTool.UnitHeight);
    //self.goodsIdLabel.frame = CGRectMake(self.titLabel.x, _priceLabel.y - 20 * KUNIT_HEIGHT, self.titLabel.width, 15 * KUNIT_HEIGHT);
    self.goodsIdLabel.frame = CGRectMake(self.titLabel.zs_x, _priceLabel.zs_y - 20 * FrameLayoutTool.UnitHeight, self.titLabel.zs_w, 15 * FrameLayoutTool.UnitHeight);
}

- (void)copy:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSObject zs_paramsValue:_goodsIdLabel.text];
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    [self refreshModel:model];
}

- (void)refreshModel:(JDSessionModel *)model{
    NSAttributedString *attriStr = [model.ext.goodsModel.goodsName zs_addWithFont:[FrameLayoutTool UnitFont:14] textMaxSize:CGSizeMake(self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, MAXFLOAT) attributes:@{NSForegroundColorAttributeName : [UIColor rgb51Color]} alignment:NSTextAlignmentLeft lineHeight:2*FrameLayoutTool.UnitHeight headIndent:0 tailIndent:0 isAutoLineBreak:YES];
    //[model.ext.goodsModel.goodsName addAttributedFont:KFONT(14) maxSize:CGSizeMake(self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, MAXFLOAT) attribute:@{NSForegroundColorAttributeName : [UIColor rgb51Color]} lineHeight:2 * KUNIT_HEIGHT alignment:NSTextAlignmentLeft autoLineBreak:YES];
    self.titLabel.attributedTextTail = attriStr;
    //self.titLabel.height = [attriStr sizeWithMaxSize:CGSizeMake(self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT)].height;
    self.titLabel.zs_h = [attriStr zs_sizeWithTextMaxSize:CGSizeMake(self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight)].height;
    
    self.goodsIdLabel.text = [NSString stringWithFormat:@"货号：%@", model.ext.goodsModel.goodsSn];
    self.priceLabel.attributedTextTail = model.ext.goodsModel.price;
    
    //[self.logoImageView sd_setImageWithURL:model.ext.goodsModel.goodsThumb.URLWithString placeholderImage:[UIImage imgLogoGrayscaleSquare]];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.ext.goodsModel.goodsThumb] placeholderImage:[UIImage imgLogoGrayscaleSquare]];
}

@end



// Mark - 订单卡片
@interface JDSessionOrderCardCell ()
@property (nonatomic, strong) UILabel *statusLabel;  // 订单状态
@end

@implementation JDSessionOrderCardCell

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.font = [FrameLayoutTool UnitFont:13];
        //KFONT(13);
        [self.contentImageView addSubview:_statusLabel];
    }
    return _statusLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //CGFloat titleX = self.model.isMySelf ? 9 * KUNIT_WIDTH : 13 * KUNIT_WIDTH;
    CGFloat titleX = self.model.isMySelf ? 9 * FrameLayoutTool.UnitWidth : 13 * FrameLayoutTool.UnitWidth;
    //self.titLabel.frame = CGRectMake(titleX, 12 * KUNIT_HEIGHT, self.contentImageView.width - 2 * titleX, 15 * KUNIT_HEIGHT);
    self.titLabel.frame = CGRectMake(titleX, 12 * FrameLayoutTool.UnitHeight, self.contentImageView.zs_w - 2 * titleX, 15 * FrameLayoutTool.UnitHeight);
    //self.logoImageView.y = self.titLabel.maxY + 5 * KUNIT_HEIGHT;
    self.logoImageView.zs_y = self.titLabel.zs_maxY + 5 * FrameLayoutTool.UnitHeight;
    //self.goodsIdLabel.frame = CGRectMake(self.logoImageView.maxX + 8 * KUNIT_WIDTH, self.logoImageView.y + 8 * KUNIT_HEIGHT, self.contentImageView.width - 35 * KUNIT_WIDTH - self.logoImageView.width, 15 * KUNIT_HEIGHT);
    self.goodsIdLabel.frame = CGRectMake(self.logoImageView.zs_maxX + 8 * FrameLayoutTool.UnitWidth, self.logoImageView.zs_y + 8 * FrameLayoutTool.UnitHeight, self.contentImageView.zs_w - 35 * FrameLayoutTool.UnitWidth - self.logoImageView.zs_w, 15 * FrameLayoutTool.UnitHeight);
    //self.priceLabel.frame = CGRectMake(self.goodsIdLabel.x, self.goodsIdLabel.maxY + 8 * KUNIT_HEIGHT, self.goodsIdLabel.width, 15 * KUNIT_HEIGHT);
    self.priceLabel.frame = CGRectMake(self.goodsIdLabel.zs_x, self.goodsIdLabel.zs_maxY + 8 * FrameLayoutTool.UnitHeight, self.goodsIdLabel.zs_w, 15 * FrameLayoutTool.UnitHeight);
    //self.statusLabel.frame = CGRectMake(self.goodsIdLabel.x, self.logoImageView.maxY - 23 * KUNIT_HEIGHT, self.goodsIdLabel.width, 15 * KUNIT_HEIGHT);
    self.statusLabel.frame = CGRectMake(self.goodsIdLabel.zs_x, self.logoImageView.zs_maxY - 23 * FrameLayoutTool.UnitHeight, self.goodsIdLabel.zs_w, 15 * FrameLayoutTool.UnitHeight);
}

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    //self.contentImageView.width = 284 * KUNIT_WIDTH;
    self.contentImageView.zs_w = 284 * FrameLayoutTool.UnitWidth;
    //self.contentImageView.height = 125 * KUNIT_HEIGHT;
    self.contentImageView.zs_h = 125 * FrameLayoutTool.UnitHeight;
}

- (void)refreshModel:(JDSessionModel *)model{
    
    if ([model.ext.orderModel isKindOfClass:[JDMessageOldOrderModel class]]) {  // 老订单展示
        
        JDMessageOldOrderModel *orderModel = model.ext.orderModel;
        self.titLabel.text = [NSString stringWithFormat:@"订单号：%@", orderModel.order_sn];
        self.goodsIdLabel.text = [NSString stringWithFormat:@"货号：%@", orderModel.order_goodsn];
        self.priceLabel.attributedTextTail = orderModel.price;
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:orderModel.order_goodlogo] placeholderImage:[UIImage imgLogoGrayscaleSquare]];
        
    }else if ([model.ext.orderModel isKindOfClass:[JDMessageOrderModel class]]){  // 新订单展示
        
        JDMessageOrderModel *orderModel = model.ext.orderModel;
        self.titLabel.text = [NSString stringWithFormat:@"订单号：%@", orderModel.ordersSn];
        self.goodsIdLabel.attributedTextTail = orderModel.price;
        self.priceLabel.attributedTextTail = orderModel.goodsCountString;
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:orderModel.goodsLogo] placeholderImage:[UIImage imgLogoGrayscaleSquare]];
        
    }else if ([model.ext.orderModel isKindOfClass:[JDMessageSaleOrderModel class]]){  // 售后订单展示
        
        JDMessageSaleOrderModel *orderModel = model.ext.orderModel;
        self.titLabel.text = [NSString stringWithFormat:@"订单号：%@", orderModel.ordersSn];
        self.goodsIdLabel.attributedTextTail = orderModel.price;
        self.priceLabel.attributedTextTail = orderModel.coin;
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:orderModel.goodsLogo] placeholderImage:[UIImage imgLogoGrayscaleSquare]];

    }
    self.statusLabel.attributedTextTail = [model.ext.orderModel orderStatusString];
}

- (void)copy:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@\n%@", self.goodsIdLabel.text, self.titLabel.text];
}

- (void)clickImage{
    if (self.model.ext.type == JDSessionMsgOrderCard) {
        JDPreviewTool *previewTool = [[JDPreviewTool alloc] init];
        if ([self.model.ext.orderModel isKindOfClass:[JDMessageOldOrderModel class]]) {
            JDMessageOldOrderModel *orderModel = self.model.ext.orderModel;
            previewTool.originalMedias = @[orderModel.order_goodlogo];
        }else if ([self.model.ext.orderModel isKindOfClass:[JDMessageOrderModel class]]){
            JDMessageOrderModel *orderModel = self.model.ext.orderModel;
            previewTool.originalMedias = @[orderModel.goodsLogo];
        }else if ([self.model.ext.orderModel isKindOfClass:[JDMessageSaleOrderModel class]]){
            JDMessageOrderModel *orderModel = self.model.ext.orderModel;
            previewTool.originalMedias = @[orderModel.goodsLogo];
        }
        previewTool.isPageHidden = YES;
        previewTool.isLongPress  = YES;
        previewTool.delegate = self;
        [previewTool preview];
    }
}

@end



// Mark - 拍卖卡片
@implementation JDSessionAuctionCardCell

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    [self refreshModel:model];
}

- (void)refreshModel:(JDSessionModel *)model{
    NSString *title = model.ext.auctionModel.title;
    self.titLabel.zs_h = [title zs_sizeWithFont:self.titLabel.font textMaxSize:CGSizeMake(self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight)].height;
    //[title sizeWithFont:self.titLabel.font maxSize:CGSizeMake(self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT)].height;
    self.titLabel.text = [NSString stringWithFormat:@"%@", title];
    self.goodsIdLabel.text = [NSString stringWithFormat:@"货号：%@", model.ext.auctionModel.auction_no];
    
    self.priceLabel.attributedTextTail = model.ext.auctionModel.attributePrice;
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.ext.auctionModel.cover] placeholderImage:[UIImage imgLogoGrayscaleSquare]];
}

- (void)copy:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@\n%@", self.goodsIdLabel.text, self.titLabel.text];
}

@end




// Mark - 小视频卡片
@implementation JDSessionSVideoCardCell

- (void)setModel:(JDSessionModel *)model{
    [super setModel:model];
    [self refreshModel:model];
}

- (void)refreshModel:(JDSessionModel *)model{
    
    
    [self.logoImageView sd_setImageWithURL:model.ext.svideoModel.goodsLogo.URLWithString placeholderImage:[UIImage imgLogoGrayscaleSquare]];
    NSString *title = model.ext.svideoModel.title;
    self.titLabel.text = [NSString stringWithFormat:@"%@", title];
    
    if ([model.ext.svideoModel.type isEqualToString:@"business"]) {
        
        self.titLabel.zs_h = [title zs_sizeWithFont:self.titLabel.font textMaxSize:CGSizeMake(self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, self.zs_h - self.logoImageView.zs_y * 2)].height;
        //self.titLabel.height = [title sizeWithFont:self.titLabel.font maxSize:CGSizeMake(self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, self.height - self.logoImageView.y * 2)].height;
        self.priceLabel.hidden = YES;

    } else {
        
        //self.titLabel.height = [title sizeWithFont:self.titLabel.font maxSize:CGSizeMake(self.contentImageView.width - 30 * KUNIT_WIDTH - 82 * KUNIT_HEIGHT, 40 * KUNIT_HEIGHT)].height;
        self.titLabel.zs_h = [title zs_sizeWithFont:self.titLabel.font textMaxSize:CGSizeMake(self.contentImageView.zs_w - 30 * FrameLayoutTool.UnitWidth - 82 * FrameLayoutTool.UnitHeight, 40 * FrameLayoutTool.UnitHeight)].height;
        self.priceLabel.hidden = NO;
        self.priceLabel.attributedTextTail = model.ext.svideoModel.attributePrice;
    }
}


@end

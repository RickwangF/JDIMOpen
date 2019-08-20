//
//  RefreshTool+emptyData.m
//  RNLive
//
//  Created by Rick on 2019/8/19.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "RefreshTool+EmptyData.h"
#import "UIColor+ProjectTool.h"
#import "FrameLayoutTool.h"
//#import "ZSBaseUtil-Swift.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>

@implementation RefreshTool (EmptyData)

+ (NSDictionary *)tableView:(CustomTableView *)tableView refreshEmptyDataForShowTitle:(NSString *)title logo:(UIImage *)image{
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor whiteLeadColor];
    backView.frame = tableView.bounds;
    
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font      = [FrameLayoutTool UnitFont:13];
    //KFONT(13);
    titleLabel.textColor = [UIColor rgb194Color];
    titleLabel.text      = title;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    
    //CGFloat titleH = [title sizeWithFont:KFONT(13) maxSize:CGSizeMake(tableView.width, MAXFLOAT)].height;
    CGFloat titleH = [title zs_sizeWithFont:[FrameLayoutTool UnitFont:13] textMaxSize:CGSizeMake(tableView.zs_w, MAXFLOAT)].height;
    
    //titleLabel.frame = CGRectMake(0, tableView.height * 0.5 + 20 * KUNIT_HEIGHT, tableView.width, titleH);
    titleLabel.frame = CGRectMake(0, tableView.zs_h * 0.5 + 20 * FrameLayoutTool.UnitHeight, tableView.zs_w, titleH);
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:image];
    //logoView.frame = CGRectMake((tableView.width - 130 * KUNIT_WIDTH) * 0.5, titleLabel.y - 120 * KUNIT_HEIGHT - 10 * KUNIT_HEIGHT, 130 * KUNIT_WIDTH, 120 * KUNIT_HEIGHT);
    logoView.frame = CGRectMake((tableView.zs_w - 130 * FrameLayoutTool.UnitWidth) * 0.5, titleLabel.zs_y - 120 * FrameLayoutTool.UnitHeight - 10 * FrameLayoutTool.UnitHeight, 130 * FrameLayoutTool.UnitWidth, 120 * FrameLayoutTool.UnitHeight);
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    [backView addSubview:logoView];
    return @{
             @"backView"   : backView,
             @"titleLabel" : titleLabel,
             @"logoView"   : logoView
             };
}


+ (void)tableView:(CustomTableView *)tableView refreshEmptyDataForShowTitle:(NSString *)title logo:(UIImage *)image displayButton:(BOOL)displayButton displayTitle:(NSString * _Nullable)displayTitle buttonTarget:(_Nullable id)target action:(_Nullable SEL)action{
    NSDictionary *dict = [self tableView:tableView refreshEmptyDataForShowTitle:title logo:image];
    UIView *backView = dict[@"backView"];
    if (displayButton) {
        UIButton *displayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        displayButton.tintColor = [UIColor clearColor];
        displayButton.layer.borderWidth = 1;
        displayButton.layer.borderColor = [UIColor blankBtnColor].CGColor;
        displayButton.layer.cornerRadius= 30 * FrameLayoutTool.UnitHeight * 0.5; //30 * KUNIT_HEIGHT * 0.5;
        displayButton.titleLabel.font   = [FrameLayoutTool UnitFont:15]; //KFONT(15);
        [displayButton setTitleColor:[UIColor blankBtnColor] forState:UIControlStateNormal];
        [displayButton setTitle:displayTitle forState:UIControlStateNormal];
        UILabel *titleLabel = dict[@"titleLabel"];
        //displayButton.frame = CGRectMake((tableView.width - 100 * KUNIT_WIDTH) * 0.5, titleLabel.maxY + 10 * KUNIT_HEIGHT, 100 * KUNIT_WIDTH, 30 * KUNIT_HEIGHT);
        displayButton.frame = CGRectMake((tableView.zs_w - 100 * FrameLayoutTool.UnitWidth) * 0.5, titleLabel.zs_maxY + 10 * FrameLayoutTool.UnitHeight, 100 * FrameLayoutTool.UnitWidth, 30 * FrameLayoutTool.UnitHeight);
        displayButton.clipsToBounds = YES;
        [displayButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:displayButton];
    }
    
    tableView.tableFooterView = backView;
}


+ (void)tableView:(CustomTableView *)tableView refreshEmptyDataForShowTitle:(NSString *)title logo:(UIImage *)image desc:(NSString *)desc{
    NSDictionary *dict = [self tableView:tableView refreshEmptyDataForShowTitle:title logo:image];
    UIView *backView    = dict[@"backView"];
    UILabel *titleLabel = dict[@"titleLabel"];
    titleLabel.font = [FrameLayoutTool UnitFont:17]; // KFONT(17);
    titleLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1.0];//KCOLOR(159, 159, 159, 1);
    //CGFloat titleH = [title sizeWithFont:KFONT(17) maxSize:CGSizeMake(tableView.width, MAXFLOAT)].height;
    CGFloat titleH = [title zs_sizeWithFont:[FrameLayoutTool UnitFont:17] textMaxSize:CGSizeMake(tableView.zs_w, MAXFLOAT)].height;
    titleLabel.zs_h = titleH;
    
    UIImageView *logoView = dict[@"logoView"];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.layer.cornerRadius = 0;
    
    UILabel *descLabel = [UILabel new];
    descLabel.font      = [FrameLayoutTool UnitFont:13]; // KFONT(13);
    descLabel.textColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]; //KCOLOR(204, 204, 204, 1);
    descLabel.text      = desc;
    descLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:descLabel];
    
    //descLabel.frame = CGRectMake(0, titleLabel.maxY + 8 * KUNIT_HEIGHT, tableView.width, titleH);
    descLabel.frame = CGRectMake(0, titleLabel.zs_maxY + 8 * FrameLayoutTool.UnitHeight, tableView.zs_w, titleH);
    tableView.tableFooterView = backView;
}


+ (void)clearEmptyViewForTableView:(CustomTableView *)tableView {
    tableView.tableFooterView = [UIView new];
}

@end

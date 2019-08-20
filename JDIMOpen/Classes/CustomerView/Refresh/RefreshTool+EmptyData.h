//
//  RefreshTool+emptyData.h
//  RNLive
//
//  Created by Rick on 2019/8/19.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "RefreshTool.h"
#import "CustomTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RefreshTool (EmptyData)

+ (void)tableView:(CustomTableView *)tableView refreshEmptyDataForShowTitle:(NSString *)title logo:(UIImage *)image displayButton:(BOOL)displayButton displayTitle:(NSString * _Nullable)displayTitle buttonTarget:(_Nullable id)target action:(_Nullable SEL)action;

+ (void)tableView:(CustomTableView *)tableView refreshEmptyDataForShowTitle:(NSString *)title logo:(UIImage *)image desc:(NSString *)desc;

+ (void)clearEmptyViewForTableView:(CustomTableView *)tableView;

@end

NS_ASSUME_NONNULL_END

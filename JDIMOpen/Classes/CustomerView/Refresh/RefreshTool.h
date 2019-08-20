//
//  RefreshTool.h
//  RNLive
//
//  Created by Rick on 2019/8/19.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^footerLoadMoreBlock) (void); 

typedef void (^headerRefreshBlock) (void);

@interface RefreshTool : NSObject

+ (void)initRefreshHeaderForScrollView:(UIScrollView *)scrollView WithHeader:( MJRefreshHeader * _Nullable )header;

+ (void)initRefreshHeaderForScrollView:(UIScrollView *)scrollView WithRefreshBlock:(headerRefreshBlock)block;

+ (void)initLoadMoreFooterFor:(UIScrollView *)scrollView WithFooter:(MJRefreshFooter * _Nullable)footer;

+ (void)initLoadMoreFooterFor:(UIScrollView *)scrollView WithLoadMoreBlock:(footerLoadMoreBlock)block;

+ (void)setLoadMoreFooterRefreshHidden:(BOOL)hidden ForScrollView:(UIScrollView *)scrollView;

+ (void)endRefreshingForScrollView:(UIScrollView *)scrollView;

+ (void)endRefreshingWithNoSourceDataFor:(UIScrollView *)scrollView;

+ (void)endRefreshingWithNoMoreDataFor:(UIScrollView *)scrollView;

+ (void)resetNoSourceDataForScrollView:(UIScrollView *)scrollView;

+ (void)resetNoMoreDataForScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END

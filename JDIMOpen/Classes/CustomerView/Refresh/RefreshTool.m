//
//  RefreshTool.m
//  RNLive
//
//  Created by Rick on 2019/8/19.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "RefreshTool.h"
#import "FrameLayoutTool.h"

@implementation RefreshTool

+ (void)initRefreshHeaderForScrollView:(UIScrollView *)scrollView WithHeader:(MJRefreshHeader *)header{
    scrollView.mj_header = header;
}

+ (void)initRefreshHeaderForScrollView:(UIScrollView *)scrollView WithRefreshBlock:(headerRefreshBlock)block{
    __weak typeof (self)weak_self = self;
    __weak typeof (scrollView)weak_scrollView = scrollView;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (block) {
            [weak_self resetNoMoreDataForScrollView:weak_scrollView];
            [weak_self resetNoSourceDataForScrollView:weak_scrollView];
            block();
        }
    }];
    
    scrollView.mj_header = header;
}

+ (void)initLoadMoreFooterFor:(UIScrollView *)scrollView WithFooter:(MJRefreshFooter *)footer{
    scrollView.mj_footer = footer;
}

+ (void)initLoadMoreFooterFor:(UIScrollView *)scrollView WithLoadMoreBlock:(footerLoadMoreBlock)block{

    MJRefreshAutoNormalFooter *autoFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    autoFooter.stateLabel.font = [FrameLayoutTool UnitFont:15];
    [autoFooter setTitle:@"没有更多了" forState:MJRefreshStateNoMoreData];
    autoFooter.stateLabel.hidden = YES;
    autoFooter.refreshingTitleHidden = YES;
    scrollView.mj_footer = autoFooter;
}

+ (void)setLoadMoreFooterRefreshHidden:(BOOL)hidden ForScrollView:(UIScrollView *)scrollView {
    scrollView.mj_footer.hidden = hidden;
}

+ (void)endRefreshingForScrollView:(UIScrollView *)scrollView{
    if ([scrollView.mj_header isRefreshing]) {
        [scrollView.mj_header endRefreshing];
    }
    if ([scrollView.mj_footer isRefreshing]) {
        [scrollView.mj_footer endRefreshing];
    }
}


+ (void)endRefreshingWithNoSourceDataFor:(UIScrollView *)scrollView{
    [self endRefreshingWithNoSourceDataFor:scrollView];
    scrollView.mj_footer.hidden = YES;
}

+ (void)endRefreshingWithNoMoreDataFor:(UIScrollView *)scrollView{
    [self endRefreshingForScrollView:scrollView];
    [scrollView.mj_footer endRefreshingWithNoMoreData];
    if ([scrollView.mj_footer isKindOfClass:MJRefreshAutoStateFooter.class]) {
        MJRefreshAutoStateFooter *autoFooter = (MJRefreshAutoStateFooter *)scrollView.mj_footer;
        autoFooter.stateLabel.hidden = NO;
    }
}


+ (void)resetNoSourceDataForScrollView:(UIScrollView *)scrollView{
    scrollView.mj_footer.hidden = NO;
}

+ (void)resetNoMoreDataForScrollView:(UIScrollView *)scrollView{
    [scrollView.mj_footer resetNoMoreData];
    if ([scrollView.mj_footer isKindOfClass:MJRefreshAutoStateFooter.class]) {
        MJRefreshAutoStateFooter *autoFooter = (MJRefreshAutoStateFooter *)scrollView.mj_footer;
        autoFooter.stateLabel.hidden = YES;
    }
}

@end

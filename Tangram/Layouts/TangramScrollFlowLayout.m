//
//  TangramScrollFlowLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramScrollFlowLayout.h"
#import "TangramEvent.h"
#import <VirtualView/UIColor+VirtualView.h>
#import <VirtualView/UIView+VirtualView.h>
#import "TMUtils.h"

//截图逻辑：滚动时截取当前页面的图，屏幕大小来算
@interface TangramScrollFlowLayout() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView      *innerScrollView;

@property (nonatomic, assign) CGFloat           preContentOffsetX;

@property (nonatomic, assign) BOOL              animFinished;

@property (nonatomic, strong) NSMutableArray    *pagingViews;

@property (nonatomic, strong) UIView            *currentPaginView;

@property (nonatomic, strong) NSMutableArray    *pagingCaptureImageViews;

//@property (nonatomic, strong) UIImageView       *captureImageView;
/**
 *  标识是否正在翻页
 */
@property (nonatomic, assign) BOOL isPaging;

@property (nonatomic, assign) BOOL needIgnoreScroll;

@property (nonatomic, strong) NSString  *subLayoutIndex;

@property (nonatomic, assign) NSInteger lastCapturePageIndex;

@end

@implementation TangramScrollFlowLayout

@synthesize tangramBus = _tangramBus;
- (TangramLayoutType *)layoutType
{
    if (self.subLayoutIndex && [self.subLayoutIndex isKindOfClass:[NSString class]] && self.subLayoutIndex.length > 0) {
        return [NSString stringWithFormat:@"%@-%@", @"tangram_layout_scroll_flow",self.subLayoutIndex];
    }
    return @"tangram_layout_scroll_flow";
}
-(UIScrollView *)innerScrollView
{
    if (nil == _innerScrollView) {
        _innerScrollView = [[UIScrollView alloc]init];
        _innerScrollView.showsHorizontalScrollIndicator = NO;
        _innerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _innerScrollView.contentSize = CGSizeMake(0, 0);
        _innerScrollView.scrollsToTop = NO;
        _innerScrollView.pagingEnabled = YES;
        self.lastCapturePageIndex = -1;
        [super addSubview:_innerScrollView];
    }
    return _innerScrollView;
}
-(void)calculateLayout
{
    [super calculateLayout];
    if(!self.disableScroll)
    {
        [self buildScrollView];
    }
}

- (void)setTangramBus:(TangramBus *)tangramBus
{
    //如果是不同的TangramBus，那么注册一下事件
    if (self.tangramBus != tangramBus) {
        _tangramBus = tangramBus;
        [_tangramBus registerAction:@"captureImageForCurrentPage" ofExecuter:self onEventTopic:ScrollLayoutCaptureImage];
    }
}

- (NSMutableArray *)pagingViews
{
    if (!_pagingViews) {
        _pagingViews = [NSMutableArray arrayWithCapacity:1];
    }
    return _pagingViews;
}

- (NSMutableArray *)pagingCaptureImageViews
{
    if (!_pagingCaptureImageViews) {
        _pagingCaptureImageViews = [NSMutableArray arrayWithCapacity:3];
    }
    return _pagingCaptureImageViews;
}

- (UIView *)currentPaginView
{
    if (self.pagingIndex < self.pagingViews.count) {
        return [self.pagingViews tm_safeObjectAtIndex:self.pagingIndex];
    }
    return nil;
}

//- (UIImageView *)captureImageView
//{
//    if (!_captureImageView) {
//        _captureImageView = [[UIImageView alloc] init];
//    }
//    return _captureImageView;
//}

- (UIView *)pagingViewWithPagingIndex:(NSInteger)pagingIndex
{
    if (pagingIndex < 0 || pagingIndex >= self.pagingViews.count)
        return nil;
    return [self.pagingViews tm_safeObjectAtIndex:pagingIndex];
}

- (void)setPagingLength:(NSInteger)pagingLength
{
    if (pagingLength == _pagingLength) {
        return;
    }
    _pagingLength = pagingLength;
    
    for (NSInteger i = 0; i < _pagingLength; i++) {
        UIView *subView = [[UIView alloc] initWithFrame:self.bounds];
        subView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.pagingViews insertObject:subView atIndex:i];
    }
    
    CGSize imgSize = [UIScreen mainScreen].bounds.size;
    // self.captureImageView.size = imgSize;
        for (NSInteger i = 0; i < _pagingLength; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgSize.width, imgSize.height)];
            [self.pagingCaptureImageViews addObject:imageView];
        }
}

- (UIImage *)captureImage
{
    static float screenScale = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        screenScale = [UIScreen mainScreen].scale;
    });
    
    CGSize imgSize = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, screenScale);
    
    UIView *currnetPagingView = self.currentPaginView;
    [currnetPagingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *newImage = nil;
    if (viewImage) {
        CGFloat absY = [self absY];
        CGFloat swidth  = imgSize.width * screenScale;
        CGFloat sheight = [UIScreen mainScreen].bounds.size.height * screenScale;
        
        CGImageRef newImageRef =  CGImageCreateWithImageInRect([viewImage CGImage], CGRectMake(0,
                                                                                               absY * screenScale,
                                                                                               swidth,
                                                                                               sheight
                                                                                               )
                                                               );
        
        newImage           = [UIImage imageWithCGImage:newImageRef];
        CGImageRelease(newImageRef);
    }
    return newImage;
}

- (CGFloat)absY
{
    if ([self.pagingDelegate respondsToSelector:@selector(pagingListLayoutAbsY)]) {
        CGFloat absY = [self.pagingDelegate pagingListLayoutAbsY];
        if (absY > 0) {
            absY = 0;
        } else {
            absY = -1 * absY;
        }
        return absY;
    }
    return 0;
}

- (void)setPagingIndex:(NSInteger)pagingIndex
{
    if (_pagingIndex == pagingIndex)
        return;
    
    self.needIgnoreScroll = YES;
    // 截取影子
    [self captureImage];
    
    [self showAnimationPaging:pagingIndex];
    
    _pagingIndex = pagingIndex;
}


- (void)showAnimationPaging:(NSInteger)pagingIndex
{
    UIView *currentView = self.currentPaginView;
    // 即将展示的view
    UIView *nextView    = [self pagingViewWithPagingIndex:pagingIndex];
    
    CGFloat left        = 0;
    if (self.pagingIndex > pagingIndex) {
        left        = currentView.vv_left - self.vv_width;
    } else if (self.pagingIndex < pagingIndex) {
        left        = currentView.vv_right;
    } else if (self.pagingIndex == pagingIndex) {
        left        = currentView.vv_left;
    }
    
    nextView.vv_left       = left;
    [self.innerScrollView addSubview:nextView];
    
    // 添加影子
    [self showCaptureImage];
    
    [nextView.layer removeAllAnimations];
    [UIView animateWithDuration:0.4 animations:^{
        [self.innerScrollView setContentOffset:CGPointMake(nextView.vv_left, 0)];
    } completion:^(BOOL finished) {
        // 归位
        if (pagingIndex == self.pagingIndex) {
            nextView.vv_left = pagingIndex * nextView.vv_width;
            [self.innerScrollView setContentOffset:CGPointMake(nextView.vv_left, 0)];
        }
        self.preContentOffsetX = self.innerScrollView.contentOffset.x;
        self.needIgnoreScroll = NO;
    }];
}

-(void)setLoadingView:(UIView *)loadingView
{
    self.animFinished = NO;
    if (_loadingView) {
        _loadingView.alpha = 1.f;
        CGRect tempRect = _loadingView.frame;
        tempRect.origin = CGPointMake(0, 0);
        _loadingView.frame = tempRect;
        [self.innerScrollView addSubview:_loadingView];
        return;
    }
    [self.innerScrollView addSubview:loadingView];
    _loadingView = loadingView;
    
}
#pragma mark - Override
-(void)addSubview:(UIView *)view
{
    if (self.disableScroll) {
        [super addSubview:view];
    }
    else{
        UIView *pagingView = self.currentPaginView;
        [pagingView addSubview:view];
    }
}

-(void)setItemModels:(NSArray *)itemModels
{
    [super setItemModels:itemModels];
    for (UIView *view in self.currentPaginView.subviews) {
        if (![self.pagingCaptureImageViews containsObject:view]) {
            [view removeFromSuperview];
        }
    }
}

-(void)buildScrollView
{
    if (self.innerScrollView.vv_width <= 0 || self.innerScrollView.contentSize.width <= 0) {
        self.innerScrollView.frame = self.bounds;
        self.innerScrollView.contentSize = CGSizeMake(self.vv_width * self.pagingLength, 0);
        self.innerScrollView.pagingEnabled = YES;
        
        [self seutpPagingItemView];
        
        self.pagingIndex = 0;
        self.innerScrollView.delegate = self;
    }
    self.innerScrollView.vv_height = self.vv_height;
}

- (void)seutpPagingItemView
{
    NSArray *subviews = [self.innerScrollView.subviews copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < self.pagingViews.count; i++) {
        
        UIView *subView             = [self.pagingViews tm_safeObjectAtIndex:i];
        subView.frame = CGRectMake(i * self.innerScrollView.vv_width, subView.vv_top, self.innerScrollView.vv_width, self.innerScrollView.vv_height);
        subView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        subView.backgroundColor = [UIColor vv_colorWithString:[self.bgColors tm_stringAtIndex:i]];
        [subView addSubview:[self.pagingCaptureImageViews tm_safeObjectAtIndex:i]];
        [self.innerScrollView addSubview:subView];
    }
}

-(void)removeLoadingView
{
    for (UIView *view in self.innerScrollView.subviews) {
        if (view != self.loadingView) {
            CGRect tempRect = view.frame;
            tempRect.origin.y += self.offsetToLoadingView;
            view.frame = tempRect;
            view.alpha = 0.f;
        }
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.6f delay:.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (UIView *view in strongSelf.innerScrollView.subviews) {
            if (strongSelf.loadingView && strongSelf.loadingView != view) {
                CGRect tempRect = view.frame;
                tempRect.origin.y -= self.offsetToLoadingView;
                view.frame = tempRect;
                view.alpha = 1.f;
            }
        }
        strongSelf.loadingView.alpha = 0.f;
        strongSelf.loadingView.vv_top -= self.offsetToLoadingView;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.loadingView removeFromSuperview];
        strongSelf.animFinished = YES;
        //[strongSelf heightChangedWithElement:nil model:nil];
    }];
}

// 展示影子
- (void)showCaptureImage
{
    // 添加影子
   // UIImageView *imageView = self.captureImageView;//[self.pagingCaptureImageViews tm_safeObjectAtIndex:self.pagingIndex];
   // [self.currentPaginView addSubview:imageView];
}

- (void)setLastCapturePageIndex:(NSInteger)lastCapturePageIndex
{
    _lastCapturePageIndex = lastCapturePageIndex;
}
#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.needIgnoreScroll)
        return;
    
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    //滚动到第几页
    CGFloat tempPagingIndex = contentOffsetX / self.vv_width;
        //如果准确滚动到了某一页
    if (tempPagingIndex == (int)tempPagingIndex) {
        self.isPaging = NO;
        //截图
        //改变当前index
        self.pagingIndex = (int)tempPagingIndex;
        //发消息
        TangramEvent *didMoveEvent = [[TangramEvent alloc]initWithTopic:@"ScrollFlowLayoutDidMoveToPage" withTangramView:self.tangramView posterIdentifier:self.identifier andPoster:self];
        [didMoveEvent setParam:[NSNumber numberWithUnsignedInteger:tempPagingIndex] forKey:@"pageIndex"];
        [self.tangramBus postEvent:didMoveEvent];
        if ([self.pagingDelegate respondsToSelector:@selector(pagingListLayoutDidPaging:)]) {
            [self.pagingDelegate pagingListLayoutDidPaging:tempPagingIndex];
        }
    }
    else if (!self.isPaging) {
        //截取当前这一页的截图
//        [self captureImage];
//        [self showCaptureImage];
//        
//        self.isPaging = YES;
        
        if (contentOffsetX > self.preContentOffsetX && self.pagingIndex < self.pagingLength - 1) { // 向右滚
            _pagingIndex += 1;
            //对应pageIndex的 截图 放在当前的位置

            if ([self.pagingDelegate respondsToSelector:@selector(pagingListLayoutMovingToNext)]) {
                [self.pagingDelegate pagingListLayoutMovingToNext];
            }
        } else if (contentOffsetX < self.preContentOffsetX && self.pagingIndex > 0) {
            
            _pagingIndex -= 1;
            //对应pageIndex的 截图 放在当前的位置
            
            if ([self.pagingDelegate respondsToSelector:@selector(pagingListLayoutMovingToPre)]) {
                [self.pagingDelegate pagingListLayoutMovingToPre];
            }
        }
    }
    
    self.preContentOffsetX = contentOffsetX;
}

- (void)captureImageForCurrentPage
{
    UIImageView *currentIndexImageView = nil;
    currentIndexImageView = [self.pagingCaptureImageViews tm_safeObjectAtIndex:self.pagingIndex];
    //currentIndexImageView.hidden = YES;
    for (UIView *view in self.pagingCaptureImageViews) {
        if (view != currentIndexImageView) {
            view.hidden = NO;
        }
    }
    UIImage *captureImage = [self captureImage];
    currentIndexImageView.image = captureImage;
}

@end

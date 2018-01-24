//
//  TangramPageScrollLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramPageScrollLayout.h"
#import "TangramItemModelProtocol.h"
#import "TMMuiLazyScrollView.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import "TangramEvent.h"
#import <VirtualView/UIView+VirtualView.h>
#import "UIView+Tangram.h"
#import "TMUtils.h"
#import <VirtualView/UIColor+VirtualView.h>
#import "TMMuiProgressBar.h"
#import "TMPageControl.h"
#import <Foundation/Foundation.h>

@interface TangramPageScrollLayoutTimerAction : NSObject

@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id target;

- (void)action;


@end


@implementation TangramPageScrollLayoutTimerAction

- (void)action
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.target && [self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector withObject:nil];
    }
#pragma clang diagnostic pop
}

@end


@interface TangramPageScrollLayout()<UIScrollViewDelegate>

@property   (nonatomic, strong) UIScrollView        *scrollView;
@property   (nonatomic, strong) TMPageControl       *pageControl;
@property   (nonatomic, weak) id<TangramPageScrollLayoutDelegate> delegate;

@property   (nonatomic, strong) NSString            *layoutIdentifier;
@property   (nonatomic, strong) UIView              *firstCopyView;
@property   (nonatomic, strong) UIView              *lastCopyView;
@property   (nonatomic, strong) NSTimer             *timer;
@property   (nonatomic, assign) NSUInteger          currentPage;

//每一页的比例
//@property   (nonatomic, assign) CGFloat             pageRatio;

//更多的imageView
@property   (nonatomic, strong) UIImageView         *loadMoreImageView;
@property   (nonatomic, assign) BOOL                willPush;
//进度条
@property   (nonatomic, strong) TMMuiProgressBar    *progressBar;
//进度条自动隐藏
@property   (nonatomic, assign) NSUInteger          realCount;
@property   (nonatomic, strong) NSObject<TangramItemModelProtocol> *firstItemModel;
@property   (nonatomic, strong) NSObject<TangramItemModelProtocol> *lastItemModel;
// 收到reload请求的次数
@property (atomic, assign   ) int                   numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign   ) NSTimeInterval        firstReloadRequestTS;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *headerItemModel;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *footerItemModel;

@property (nonatomic, assign) BOOL                  hasSetIndicatorPosition;

@property (nonatomic, strong) UIImageView         *bgImageView;


@end
@implementation TangramPageScrollLayout
@synthesize itemModels  = _itemModels;

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //加载更多的逻辑
    CGFloat loadX = scrollView.contentSize.width - scrollView.vv_width + scrollView.contentInset.right + 2 * self.loadMoreImageView.vv_width;
    if (self.hasMoreAction.length > 0 && self.willPush == NO && [scrollView.subviews containsObject:self.loadMoreImageView] && scrollView.contentOffset.x > loadX && !scrollView.dragging)
    {
        self.willPush = YES;
        scrollView.contentInset = UIEdgeInsetsMake(0, [self.pageMargin tm_floatAtIndex:3] - self.scrollView.vv_left, 0, self.scrollView.vv_right - self.vv_width + self.loadMoreImageView.vv_width);
        scrollView.pagingEnabled = NO;
        [scrollView setContentOffset:CGPointMake(loadX - self.loadMoreImageView.vv_width, scrollView.contentOffset.y)];
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TangramEvent *event = [[TangramEvent alloc]initWithTopic:@"pageLayoutJumpMorePage" withTangramView:self.inTangramView posterIdentifier:@"pageScrollLayout" andPoster:strongSelf];
            [strongSelf.tangramBus postEvent:event];
             //使用TangramBus发出事件
            scrollView.contentInset = UIEdgeInsetsMake(0, [strongSelf.pageMargin tm_floatAtIndex:3] - strongSelf.scrollView.vv_left, 0, strongSelf.scrollView.vv_right - strongSelf.vv_width);
            if (strongSelf.pageWidth > 0) {
                scrollView.pagingEnabled = YES;
            }
            strongSelf.willPush = NO;
        });
    }
    if (self.progressBar)
    {
        if (scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right - scrollView.vv_width == 0)
        {
            return;
        }
        self.progressBar.progress = (scrollView.contentOffset.x + scrollView.contentInset.left) / (scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right - scrollView.vv_width);
    }

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger currentIndex = floor((scrollView.contentOffset.x + 10.f) / scrollView.vv_width);
    if (self.infiniteLoop) {
        //如果第0页 跳转到最后
        if (currentIndex == 0)
        {
            currentIndex = self.realCount - 1;
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.vv_width * self.realCount, 0, self.scrollView.vv_width, self.scrollView.vv_height) animated:NO];
        }
        else if (currentIndex == self.realCount + 1)
            //如果是最后一页，跳转到第一页
        {
            currentIndex = 0;
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.vv_width, 0, self.scrollView.vv_width, self.scrollView.vv_height) animated:NO];
        }
        else {
            currentIndex -= 1;
        }
    }
    if (self.pageControl.currentPage != currentIndex)
    {
        self.pageControl.currentPage = currentIndex;
        self.currentPage = currentIndex;
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(TangramPageScrollLayoutDelegate)] && [self.delegate respondsToSelector:@selector(layout:atIndex:)])
        {
            [self.delegate layout:self atIndex:currentIndex];
        }
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 一旦开始拖动就停止计时器
    [self stopTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (! decelerate) {
        NSUInteger currentIndex = floor((scrollView.contentOffset.x + 10.f) / scrollView.vv_width);
        if (self.pageControl.currentPage != currentIndex)
        {
            self.pageControl.currentPage = currentIndex;
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(TangramPageScrollLayoutDelegate)] && [self.delegate respondsToSelector:@selector(layout:atIndex:)])
            {
                [self.delegate layout:self atIndex:currentIndex];
            }
        }
    }
    // 没有拖动图片就开始定时器
    [self startTimer];
   
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
      //如果设计了无限循环,那么在跳最后一页的时候，直接跳到第1页
    if (self.infiniteLoop) {
        if (self.currentPage == self.realCount + 1) {
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.vv_width, 0, self.scrollView.vv_width, self.scrollView.vv_height) animated:NO];
            self.currentPage = 1;
            self.pageControl.currentPage = 0;
        }
    }

}

#pragma mark - Getter & Setter
- (TMPageControl *)pageControl
{
    if (nil == _pageControl) {
        _pageControl = [[TMPageControl alloc] init];
        _pageControl.backgroundColor = [UIColor clearColor];
    }
    return _pageControl;
}

- (UIScrollView *)scrollView
{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled   = YES;
        _scrollView.scrollsToTop    = NO;
        _scrollView.pagingEnabled   = YES;
        _scrollView.delegate        = self;
        _scrollView.showsHorizontalScrollIndicator  = NO;
        _scrollView.showsVerticalScrollIndicator    = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)bgImageView
{
    if (nil == _bgImageView) {
        _bgImageView = [[UIImageView alloc]init];
    }
    return _bgImageView;
}

-(UIImageView *)loadMoreImageView
{
    if (!_loadMoreImageView)
    {
        _loadMoreImageView = [[UIImageView alloc] init];
    }
    return _loadMoreImageView;
}
- (TMMuiProgressBar *)progressBar
{
    if (!_progressBar)
    {
        _progressBar = [[TMMuiProgressBar alloc] init];
        _progressBar.barColor = [UIColor vv_colorWithRGB:0xB4B4B4];
        _progressBar.bgImageView.backgroundColor = [UIColor vv_colorWithRGB:0xDFDFDF];
        _progressBar.bgImageView.vv_height = 1;
        _progressBar.vv_width = 154;
        _progressBar.vv_height = 4;
        _progressBar.progressBarType = BlockMUIProgressBar;
    }
    return _progressBar;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //self.scrollView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.scrollView.backgroundColor = backgroundColor;
}
- (void)setIndicatorImg1:(NSString *)indicatorImg1
{
    _indicatorImg1 = indicatorImg1;
}
- (void)setIndicatorWidth:(CGFloat)indicatorWidth
{
    _indicatorWidth = indicatorWidth;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight
{
    _indicatorHeight = indicatorHeight;
}
-(void)reCalculatePageControlSizeWithImage:(UIImage *)image
{
     //保证是正方形
    if (image.size.height > self.pageControl.pageHeight/2.f) {
        self.pageControl.pageHeight = image.size.height/2.f;
        self.pageControl.pageWidth = image.size.height/2.f;
        //[self calculateLayout];
        
    }
    else if (image.size.width > self.pageControl.pageWidth) {
        self.pageControl.pageWidth = image.size.width/2.f;
        self.pageControl.pageHeight = image.size.width/2.f;
        //[self calculateLayout];
    }
    
    
}
-(void)calculatePageControlPosition
{
    if (self.itemModels.count <= 0) {
        return;
    }
    
    [self.pageControl sizeToFit];
    switch (self.indicatorGravity) {
        case IndicatorGravityLeft:
            self.pageControl.vv_left = 6.f;
            break;
        case IndicatorGravityRight:
            self.pageControl.vv_right = self.vv_width - 6.f;
            break;
        case IndicatorGravityCenter:
        default:
            self.pageControl.vv_centerX = self.vv_width / 2;
            break;
    }
}
-(void)setIndicatorImg2:(NSString *)indicatorImg2
{
    _indicatorImg2 = indicatorImg2;
}

-(void)setIndicatorGap:(CGFloat)indicatorGap
{
    _indicatorGap = indicatorGap;
    self.pageControl.pageSpacing = indicatorGap;
}
-(NSString *)identifier
{
    return self.layoutIdentifier;
}
-(void)setIdentifier:(NSString *)identifier
{
    self.layoutIdentifier = identifier;
}
-(NSString *)loadAPI
{
    return self.layoutLoadAPI;
}

#pragma mark - Overwrite
- (void)addSubview:(UIView *)view
{
    if (view && view.reuseIdentifier) {
        view.reuseIdentifier = @"";
        [self.scrollView addSubview:view];
        if (self.infiniteLoop) {
            if (self.scrollView.subviews.count == self.itemModels.count) {
                [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.vv_width, 0, self.scrollView.vv_width, self.scrollView.vv_height) animated:NO];
            }
        }
    }
    else {
        [super addSubview:view];
    }
}

- (void)addFooterView:(UIView *)footerView
{
    [super addSubview:footerView];
}

- (void)addHeaderView:(UIView *)headerView
{
    [super addSubview:headerView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}


- (void)calculateLayout
{
    NSInteger modelCount = self.itemModels.count;
    if ([self.itemModels containsObject:self.headerItemModel]) {
        modelCount --;
    }
    if ([self.itemModels containsObject:self.footerItemModel]) {
        modelCount --;
    }
    if (nil == self.itemModels || 0 >= modelCount) {
        self.vv_height = 0.f;
        return;
    }
    //设定坐标
    CGFloat elementHeight = 0.f;
    //elementHeight += [self.padding tm_floatAtIndex:0];
    NSObject<TangramItemModelProtocol> *lastElementModel = nil;
    if (self.aspectRatio.length > 0 && [self.aspectRatio floatValue] > 0.f ) {
        self.vv_height = self.vv_width / [self.aspectRatio floatValue];
    }
    //对header进行布局
    //获取头部的大小
    CGFloat headerHeight = 0.f;
    if (self.headerItemModel) {
        CGFloat contentWidth = self.vv_width - self.headerItemModel.marginLeft - self.headerItemModel.marginRight - [self.padding tm_floatAtIndex:1] - [self.padding tm_floatAtIndex:3];
        CGRect tempRect = self.headerItemModel.itemFrame;
        tempRect.size.width = contentWidth;
        tempRect.origin.x   = self.headerItemModel.marginLeft + [self.padding tm_floatAtIndex:3];
        tempRect.origin.y   = self.headerItemModel.marginTop + [self.padding tm_floatAtIndex:0];
        self.headerItemModel.itemFrame = tempRect;
        headerHeight = CGRectGetMaxY(self.headerItemModel.itemFrame);
    }
    //如果headerHeight有了，意味着padding的第一项已经被加上了
    //如果没有，则需要被加在每一个组件的marginTop上
    NSUInteger scrollFirstItemIndex = 0;
    if (self.headerItemModel) {
        scrollFirstItemIndex = 1;
    }
    for (NSUInteger i = 0 ; i < self.itemModels.count ; i++) {
        NSObject<TangramItemModelProtocol> *model = [self.itemModels tm_safeObjectAtIndex:i];
        if (model == self.headerItemModel || model == self.footerItemModel) {
            continue;
        }
        CGFloat contentWidth = self.vv_width - model.marginLeft - model.marginRight - [self.padding tm_floatAtIndex:1] - [self.padding tm_floatAtIndex:3] ;
        //有pagewidth，强制页面宽度
        if (self.pageWidth > 0.f) {
            contentWidth = self.pageWidth;
        }
        CGRect tempRect = model.itemFrame;
        tempRect.size.width = contentWidth;
        tempRect.origin.x   = (lastElementModel)
        ? (CGRectGetMaxX(lastElementModel.itemFrame) + model.marginLeft + lastElementModel.marginRight)
        : model.marginLeft;
        if (lastElementModel && self.hGap > 0) {
            tempRect.origin.x += self.hGap;
        }
        if (i == scrollFirstItemIndex && self.scrollMarginLeft > 0) {
            tempRect.origin.x += self.scrollMarginLeft;
        }
        tempRect.origin.y   = model.marginTop + headerHeight;
        if (!self.headerItemModel) {
            tempRect.origin.y += [self.padding tm_floatAtIndex:0];
        }
        //有页面高度，强制页面高度
        if (self.pageHeight > 0.f) {
            tempRect.size.height = self.pageHeight;
        }
        [model setItemFrame:tempRect];
        elementHeight = MAX(elementHeight, CGRectGetMaxY(model.itemFrame) + model.marginBottom);
        lastElementModel = model;
    }
    if (self.pageWidth > 0) {
        self.scrollView.pagingEnabled = NO;
    }
    self.vv_height = elementHeight;
    self.scrollView.frame = CGRectMake([self.padding tm_floatAtIndex:3], 0, self.vv_width - [self.padding tm_floatAtIndex:3] - [self.padding tm_floatAtIndex:1], elementHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastElementModel.itemFrame) + lastElementModel.marginRight + self.scrollMarginLeft + self.scrollMarginRight, elementHeight) ;
    //设定加载更多的图片，只是在后面贴了一张图而已
    if(self.hasMoreAction.length > 0 && self.loadMoreImgUrl > 0 && self.scrollView.contentSize.width > self.vv_width)
    {
        self.loadMoreImageView.vv_left = self.scrollView.contentSize.width;
        [self.scrollView addSubview:self.loadMoreImageView];
        self.loadMoreImageView.vv_height = self.scrollView.vv_height;
        __weak typeof(self) weakself = self;
        [self.loadMoreImageView sd_setImageWithURL:[NSURL URLWithString:self.loadMoreImgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *imageURL) {
            __strong typeof(weakself) strongSelf = weakself;
            if (!error && image)
            {
                strongSelf.loadMoreImageView.vv_width = strongSelf.scrollView.contentSize.height * image.size.width / image.size.height;
            }
        }];
    }
    
    //如果是点的PageControl
    if (self.hasIndicator) {
        if (self.indicatorStyleType == IndicatorStyleDot)
        {
            if (self.indicatorImg1.length <= 0 && self.indicatorImg2.length <= 0) {
                self.pageControl.style = TMPageControlStyleDefault;
                self.pageControl.pageHeight = self.indicatorRadius * 2;
                self.pageControl.pageWidth = self.indicatorRadius * 2;
                self.pageControl.pageSpacing = 4.f;
                self.pageControl.normalFillColor = [UIColor vv_colorWithString:self.defaultIndicatorColor];
                self.pageControl.selectedFillColor = [UIColor vv_colorWithString:self.indicatorColor];
            }
            else{
                self.pageControl.style = TMPageControlStyleImage;
                //如果配置了indicatorHeight，那么pageControl的宽度会改变
                
            }
            if (self.infiniteLoop) {
                self.pageControl.numberOfPages = self.realCount;
            }
            else{
                self.pageControl.numberOfPages = modelCount;
            }
            [self.pageControl sizeToFit];
            if (self.indicatorHeight > 0) {
                self.pageControl.vv_height = self.indicatorHeight;
            }
            switch (self.indicatorPosition) {
                case IndicatorPositionInside:
                    //如果是inside，是不用变更整体layout的高度的
                    self.pageControl.vv_bottom = self.vv_height - self.indicatorMargin ;
                    break;
                case IndicatorPositionOutside:
                default:
                    //如果是outside，需要变更高度
                    //Outside的PageControl 整个View的高度加两倍的indicatorMargin
                    //增加的高度 = PageControl的高度 + indicator
                    self.vv_height += self.pageControl.vv_height;
                    self.vv_height += self.indicatorMargin*2 ;
                    self.pageControl.vv_bottom = self.vv_height - self.indicatorMargin;
                    break;
            }
            [self calculatePageControlPosition];
        }
        //如果是条的
        else
        {
            self.progressBar.autoHide = self.indicatorAutoHide;
            self.progressBar.barWidth = self.indicatorRadius * 2;
            self.progressBar.barHeight = 3;
            self.progressBar.bgImageView.vv_bottom = self.progressBar.vv_height;
            self.progressBar.bgImageView.vv_width = self.progressBar.vv_width;
            self.progressBar.barColor = [UIColor vv_colorWithString:self.indicatorColor];
            self.progressBar.bgImageView.backgroundColor = [UIColor vv_colorWithString:self.defaultIndicatorColor];
            [self addSubview:self.progressBar];
            if (self.indicatorPosition == IndicatorPositionOutside) {
                self.vv_height += self.progressBar.vv_height;
                self.vv_height += self.indicatorMargin*2 ;
            }
            self.progressBar.vv_centerX = self.vv_width / 2;
            self.progressBar.vv_bottom = self.vv_height - 4;
        }
        
    }
    [self bringSubviewToFront:self.pageControl];
    
    //对footer进行布局
    if (self.footerItemModel) {
        CGFloat contentWidth = self.vv_width - self.footerItemModel.marginLeft - self.footerItemModel.marginRight - [self.padding tm_floatAtIndex:1] - [self.padding tm_floatAtIndex:3];
        CGRect tempRect = self.footerItemModel.itemFrame;
        tempRect.size.width = contentWidth;
        tempRect.origin.x   = self.footerItemModel.marginLeft + [self.padding tm_floatAtIndex:3];
        tempRect.origin.y   = self.vv_height + self.footerItemModel.marginTop;
        self.footerItemModel.itemFrame = tempRect;
        self.vv_height = CGRectGetMaxY(self.footerItemModel.itemFrame) + self.footerItemModel.marginBottom + [self.padding tm_floatAtIndex:2];
    }
    else{
        self.vv_height += [self.padding tm_floatAtIndex:2];
    }
    [self startTimer];
    [self buildIndicator];
    if (self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.vv_width, self.vv_height);
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
        [self insertSubview:self.bgImageView belowSubview:self.scrollView];
    }
    else{
        [self.bgImageView removeFromSuperview];
    }
}

- (void)buildIndicator
{
    __weak typeof(self) weakSelf = self;
    //以1 为准
    if (self.indicatorImg1.length > 0) {
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:self.indicatorImg1] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!error) {
                strongSelf.pageControl.selectedImage = image;
                
                if (strongSelf.indicatorHeight > 0) {
                    strongSelf.pageControl.pageHeight = strongSelf.indicatorHeight;
                    strongSelf.pageControl.pageWidth = strongSelf.pageControl.pageHeight * image.size.width / image.size.height;
                    [strongSelf.pageControl sizeToFit];
                }
                else{
                    [strongSelf reCalculatePageControlSizeWithImage:image];
                    if (!strongSelf.hasSetIndicatorPosition) {
                        [strongSelf heightChangedWithElement:nil model:nil];
                    }
                }
                strongSelf.hasSetIndicatorPosition = YES;
                [strongSelf calculatePageControlPosition];
            }
        }];
    }
    if (self.indicatorImg2.length > 0) {
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:self.indicatorImg2] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!error) {
                strongSelf.pageControl.normalImage = image;
            }
        }];
    }
}

- (TangramLayoutType *)layoutType
{
    return @"tangram_layout_scroll";
}
- (void)jumpToNextPage
{
    if (self.pageControl.numberOfPages <= 0 || self.scrollView.subviews.count <= 0 ) {
        return;
    }
    // 下一个页面，对总数取余的页码，循环滚动
    NSInteger page = (self.currentPage + 1) % self.scrollView.subviews.count;
    
    // 计算偏移量，索引值和scrollView宽度的积
    CGPoint offset = CGPointMake(page * self.scrollView.frame.size.width, 0);
    // 设置新的偏移量
    self.currentPage = page;
    NSUInteger currentIndex = 0;
    if (self.infiniteLoop) {
        if (page == self.realCount + 1 )
        {
            //如果是最后一页，跳转到第一页
            currentIndex = 0;
        }
        else if(page == 0)
        {
            currentIndex = 1;
        }
        else if(page > 0){
            currentIndex = page - 1;
        }
    }
    else{
        currentIndex = page;
    }
    self.pageControl.currentPage = currentIndex;
    [self.scrollView setContentOffset:offset animated:YES];
    
}
- (void)setItemModels:(NSArray *)itemModels
{
    
   _itemModels = itemModels;
    if ([self.pageControl isKindOfClass:[TMPageControl class]])
    {
        self.pageControl.numberOfPages = itemModels.count;
    }
    //保证只加了一次，做一次数据校验
    if (self.infiniteLoop && itemModels.count > 2 && nil == self.firstItemModel && nil == self.lastItemModel) {
        self.firstItemModel = (NSObject<TangramItemModelProtocol> *)[self duplicateObject:[self.itemModels firstObject]];
        self.lastItemModel = (NSObject<TangramItemModelProtocol> *)[self duplicateObject:[self.itemModels lastObject]];
        NSMutableArray *mutableItemModels = [itemModels mutableCopy];
        [mutableItemModels insertObject:self.lastItemModel atIndex:0];
        [mutableItemModels tm_safeAddObject:self.firstItemModel];
        _itemModels = [mutableItemModels copy];
        //realCount仅在无限循环时使用
        self.realCount = itemModels.count;
    }
    NSMutableArray *mutableItemModels = [_itemModels mutableCopy];
    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
        [mutableItemModels insertObject:self.headerItemModel atIndex:0];
    }
    if (self.footerItemModel && ![self.itemModels containsObject:self.footerItemModel]) {
        [mutableItemModels tm_safeAddObject:self.footerItemModel];
    }
    _itemModels = [mutableItemModels copy];
    
}
- (NSArray *)itemModels
{
   
    return _itemModels;
}
- (NSArray *)margin
{
    if (_margin && 4 == _margin.count) {
        return _margin;
    }
    return @[@0, @0, @0, @0];
}
- (CGFloat)marginTop
{
    return [[self.margin tm_safeObjectAtIndex:0] floatValue];
}

- (CGFloat)marginRight
{
    return [[self.margin tm_safeObjectAtIndex:1] floatValue];
}

- (CGFloat)marginBottom
{
    return [[self.margin tm_safeObjectAtIndex:2] floatValue];
}

- (CGFloat)marginLeft
{
    return [[self.margin tm_safeObjectAtIndex:3] floatValue];
}

-(NSString *)position
{
    return @"";
}


- (NSObject *)duplicateObject:(NSObject *)object
{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:object];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

#pragma mark - 定时器相关
- (void)startTimer
{
    if (self.autoScrollTime > 0.0 && self.itemModels.count > 2) {
        if (self.timer) {
            [self.timer fire];
        }
        TangramPageScrollLayoutTimerAction *timerAction = [[TangramPageScrollLayoutTimerAction alloc]init];
        timerAction.selector = @selector(jumpToNextPage);
        timerAction.target = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTime target:timerAction selector:@selector(action) userInfo:nil repeats:YES];
    }
}



- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate]; // 停止计时器
        self.timer = nil; //清空指针
    }
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
    [_timer invalidate];
    _timer = nil;
    [self.firstCopyView removeObserver:self forKeyPath:@"hidden"];
}

- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
    // TangramView和layout有同样的逻辑
    // 通过记录第一次刷新请求的时间，延迟执行，执行时加以判断，
    // 合并多次刷新，避免频繁刷新，效率降低
    /** 每次收到relaod请求都延迟100毫秒，在延迟窗口内若没有新请求则执行reload，若有则继续延迟100毫秒，直至延迟上限（500毫秒）**/
    self.numberOfReloadRequests += 1;
    int currentNumber = self.numberOfReloadRequests;
    // 初始化首次请求时间
    if (0 >= self.firstReloadRequestTS) {
        self.firstReloadRequestTS = [[NSDate date] timeIntervalSince1970];
    }
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = wself;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        // 没有新请求，或超过500毫秒了
        // block里用到的currentNumber是copy的
        if (currentNumber == sself.numberOfReloadRequests
            || 500 < now - sself.firstReloadRequestTS) {
            sself.firstReloadRequestTS = 0;
            [sself calculateLayout];
            if ([sself.superview isKindOfClass:[TangramView class]]) {
                //NSLog(@"relayout invoke time in flowlayout ： %lf ",[[NSDate date] timeIntervalSince1970]);
                [(TangramView *)sself.superview reLayoutContent];
            }
        }
    });
}

@end

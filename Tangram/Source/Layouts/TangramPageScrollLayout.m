//
//  TangramPageScrollLayout.m
//  Pods
//
//  Created by xiaoxia on 16/1/13.
//
//

#import "TangramPageScrollLayout.h"
#import "TangramItemModelProtocol.h"
#import <LazyScroll/TMMuiLazyScrollView.h>
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import "TangramEvent.h"
#import "UIView+Tangram.h"
#import "TangramSafeMethod.h"
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
@property   (nonatomic, strong) UIPageControl       *pageControl;

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




@end
@implementation TangramPageScrollLayout
@synthesize itemModels  = _itemModels;

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //加载更多的逻辑
    CGFloat loadX = scrollView.contentSize.width - scrollView.frame.size.width + scrollView.contentInset.right + 2 * self.loadMoreImageView.frame.size.width;
    if (self.hasMoreAction.length > 0 && self.willPush == NO && [scrollView.subviews containsObject:self.loadMoreImageView] && scrollView.contentOffset.x > loadX && !scrollView.dragging)
    {
        self.willPush = YES;
        scrollView.contentInset = UIEdgeInsetsMake(0, [self.pageMargin tgrm_floatAtIndex:3] - self.scrollView.frame.origin.x, 0, self.scrollView.frame.size.width - self.scrollView.frame.origin.x - self.frame.size.width + self.loadMoreImageView.frame.size.width);
        scrollView.pagingEnabled = NO;
        [scrollView setContentOffset:CGPointMake(loadX - self.loadMoreImageView.frame.size.width, scrollView.contentOffset.y)];
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TangramEvent *event = [[TangramEvent alloc]initWithTopic:@"pageLayoutJumpMorePage" withTangramView:self.inTangramView posterIdentifier:@"pageScrollLayout" andPoster:strongSelf];
            [strongSelf.tangramBus postEvent:event];
             //使用TangramBus发出事件
            scrollView.contentInset = UIEdgeInsetsMake(0, [strongSelf.pageMargin tgrm_floatAtIndex:3] - strongSelf.scrollView.frame.origin.x, 0, strongSelf.scrollView.frame.origin.x + strongSelf.scrollView.frame.size.width - strongSelf.frame.size.width);
            if (strongSelf.pageWidth > 0) {
                scrollView.pagingEnabled = YES;
            }
            strongSelf.willPush = NO;
        });
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger currentIndex = floor((scrollView.contentOffset.x + 10.f) / scrollView.frame.size.width);
    if (self.infiniteLoop) {
        //如果第0页 跳转到最后
        if (currentIndex == 0)
        {
            currentIndex = self.realCount - 1;
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * self.realCount, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
        }
        else if (currentIndex == self.realCount + 1)
            //如果是最后一页，跳转到第一页
        {
            currentIndex = 0;
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
        }
        else {
            currentIndex -= 1;
        }
    }
    if (self.pageControl.currentPage != currentIndex)
    {
        self.pageControl.currentPage = currentIndex;
        self.currentPage = currentIndex;
       
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
        NSUInteger currentIndex = floor((scrollView.contentOffset.x + 10.f) / scrollView.frame.size.width);
        if (self.pageControl.currentPage != currentIndex)
        {
            self.pageControl.currentPage = currentIndex;
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
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
            self.currentPage = 1;
            self.pageControl.currentPage = 0;
        }
    }

}

#pragma mark - Getter & Setter
- (UIPageControl *)pageControl
{
    if (nil == _pageControl) {
        _pageControl = [[UIPageControl alloc] init];
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

-(UIImageView *)loadMoreImageView
{
    if (!_loadMoreImageView)
    {
        _loadMoreImageView = [[UIImageView alloc] init];
    }
    return _loadMoreImageView;
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
- (void)setHeaderItemModel:(NSObject<TangramItemModelProtocol> *)headerItemModel
{
    _headerItemModel = headerItemModel;
    NSMutableArray *mutableItemModels = [self.itemModels mutableCopy];
    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
        [mutableItemModels insertObject:self.headerItemModel atIndex:0];
    }
    _itemModels = [mutableItemModels copy];
}

- (void)setFooterItemModel:(NSObject<TangramItemModelProtocol> *)footerItemModel
{
    _footerItemModel = footerItemModel;
    NSMutableArray *mutableItemModels = [self.itemModels mutableCopy];
    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
        [mutableItemModels tgrm_addObjectCheck:self.footerItemModel];
    }
    _itemModels = [mutableItemModels copy];
}
-(void)calculatePageControlPosition
{
    if (self.itemModels.count <= 0) {
        return;
    }
    
    [self.pageControl sizeToFit];
    switch (self.indicatorGravity) {
        case IndicatorGravityLeft:
            self.pageControl.frame = CGRectMake(6, self.pageControl.frame.origin.y, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
            break;
        case IndicatorGravityRight:
            self.pageControl.frame = CGRectMake(self.frame.size.width - 6 - self.pageControl.frame.size.width, self.pageControl.frame.origin.y, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
            break;
        case IndicatorGravityCenter:
        default:
            self.pageControl.center = CGPointMake(self.frame.size.width/2.f, self.pageControl.center.y);
            break;
    }
}

-(void)setIndicatorGap:(CGFloat)indicatorGap
{
    _indicatorGap = indicatorGap;
    //self.pageControl.pageSpacing = indicatorGap;
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
                [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
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
        return;
    }
    //设定坐标
    CGFloat elementHeight = 0.f;
    //elementHeight += [self.padding tgrm_floatAtIndex:0];
    NSObject<TangramItemModelProtocol> *lastElementModel = nil;
    if (self.aspectRatio.length > 0 && [self.aspectRatio floatValue] > 0.f ) {
        self.height = self.width / [self.aspectRatio floatValue];
    }
    //对header进行布局
    //获取头部的大小
    CGFloat headerHeight = 0.f;
    if (self.headerItemModel) {
        CGFloat contentWidth = self.width - self.headerItemModel.marginLeft - self.headerItemModel.marginRight - [self.padding tgrm_floatAtIndex:1] - [self.padding tgrm_floatAtIndex:3];
        CGRect tempRect = self.headerItemModel.itemFrame;
        tempRect.size.width = contentWidth;
        tempRect.origin.x   = self.headerItemModel.marginLeft + [self.padding tgrm_floatAtIndex:3];
        tempRect.origin.y   = self.headerItemModel.marginTop + [self.padding tgrm_floatAtIndex:0];
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
        NSObject<TangramItemModelProtocol> *model = [self.itemModels tgrm_objectAtIndexCheck:i];
        if (model == self.headerItemModel || model == self.footerItemModel) {
            continue;
        }
        CGFloat contentWidth = self.width - model.marginLeft - model.marginRight - [self.padding tgrm_floatAtIndex:1] - [self.padding tgrm_floatAtIndex:3] ;
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
            tempRect.origin.y += [self.padding tgrm_floatAtIndex:0];
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
    self.height = elementHeight;
    self.scrollView.frame = CGRectMake([self.padding tgrm_floatAtIndex:3], 0, self.width - self.marginRight - self.marginLeft - [self.padding tgrm_floatAtIndex:3] - [self.padding tgrm_floatAtIndex:1], elementHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastElementModel.itemFrame) + lastElementModel.marginRight + self.scrollMarginLeft + self.scrollMarginRight, elementHeight) ;
    //设定加载更多的图片，只是在后面贴了一张图而已
    if(self.hasMoreAction.length > 0 && self.loadMoreImgUrl > 0 && self.scrollView.contentSize.width > self.width)
    {
        [self.scrollView addSubview:self.loadMoreImageView];
        self.loadMoreImageView.frame = CGRectMake(self.scrollView.contentSize.width, self.loadMoreImageView.frame.origin.y, self.loadMoreImageView.frame.size.width, self.scrollView.frame.size.height);
        __weak typeof(self) weakself = self;
        [self.loadMoreImageView sd_setImageWithURL:[NSURL URLWithString:self.loadMoreImgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *imageURL) {
            __strong typeof(weakself) strongSelf = weakself;
            if (!error && image)
            {
                strongSelf.loadMoreImageView.frame = CGRectMake(strongSelf.loadMoreImageView.frame.origin.x, strongSelf.loadMoreImageView.frame.origin.y, strongSelf.scrollView.contentSize.height * image.size.width / image.size.height, strongSelf.loadMoreImageView.frame.size.height);
            }
        }];
    }
    
    //如果是点的PageControl
    if (self.hasIndicator) {
        if (self.indicatorStyleType == IndicatorStyleDot)
        {
            if (self.indicatorImg1.length <= 0 && self.indicatorImg2.length <= 0) {
//                self.pageControl.style = TMPageControlStyleDefault;
//                self.pageControl.pageHeight = self.indicatorRadius * 2;
//                self.pageControl.pageWidth = self.indicatorRadius * 2;
//                self.pageControl.pageSpacing = 4.f;
                self.pageControl.pageIndicatorTintColor = [[self class] colorFromHexString:self.defaultIndicatorColor];
                self.pageControl.currentPageIndicatorTintColor = [[self class] colorFromHexString:self.indicatorColor];
            }
            if (self.infiniteLoop) {
                self.pageControl.numberOfPages = self.realCount;
            }
            else{
                self.pageControl.numberOfPages = modelCount;
            }
            [self.pageControl sizeToFit];
            if (self.indicatorHeight > 0) {
                self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, self.pageControl.frame.origin.y, self.pageControl.frame.size.width, self.indicatorHeight);
            }
            switch (self.indicatorPosition) {
                case IndicatorPositionInside:
                    //如果是inside，是不用变更整体layout的高度的
                     self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x,  self.height - self.indicatorMargin - self.pageControl.frame.size.height, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
                    break;
                case IndicatorPositionOutside:
                default:
                    //如果是outside，需要变更高度
                    //Outside的PageControl 整个View的高度加两倍的indicatorMargin
                    //增加的高度 = PageControl的高度 + indicator
                    self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x,  self.height - self.indicatorMargin - self.pageControl.frame.size.height, self.pageControl.frame.size.width, self.pageControl.frame.size.height +  self.pageControl.frame.size.height + self.indicatorMargin*2 );
                    break;
            }
            [self calculatePageControlPosition];
        }
    }
    [self bringSubviewToFront:self.pageControl];
    //对footer进行布局
    if (self.footerItemModel) {
        CGFloat contentWidth = self.width - self.footerItemModel.marginLeft - self.footerItemModel.marginRight - [self.padding tgrm_floatAtIndex:1] - [self.padding tgrm_floatAtIndex:3];
        CGRect tempRect = self.footerItemModel.itemFrame;
        tempRect.size.width = contentWidth;
        tempRect.origin.x   = self.footerItemModel.marginLeft + [self.padding tgrm_floatAtIndex:3];
        tempRect.origin.y   = self.height + self.footerItemModel.marginTop;
        self.footerItemModel.itemFrame = tempRect;
        self.height = CGRectGetMaxY(self.footerItemModel.itemFrame) + self.footerItemModel.marginBottom + [self.padding tgrm_floatAtIndex:2];
    }
    else{
        self.height += [self.padding tgrm_floatAtIndex:2];
    }
    [self startTimer];
   // [self buildIndicator];
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
    if ([self.pageControl isKindOfClass:[UIPageControl class]])
    {
        self.pageControl.numberOfPages = itemModels.count;
    }
    //保证只加了一次，做一次数据校验
    if (self.infiniteLoop && itemModels.count > 2 && nil == self.firstItemModel && nil == self.lastItemModel) {
        self.firstItemModel = (NSObject<TangramItemModelProtocol> *)[self duplicateObject:[self.itemModels firstObject]];
        self.lastItemModel = (NSObject<TangramItemModelProtocol> *)[self duplicateObject:[self.itemModels lastObject]];
        NSMutableArray *mutableItemModels = [itemModels mutableCopy];
        [mutableItemModels insertObject:self.lastItemModel atIndex:0];
        [mutableItemModels tgrm_addObjectCheck:self.firstItemModel];
        _itemModels = [mutableItemModels copy];
        //realCount仅在无限循环时使用
        self.realCount = itemModels.count;
    }
    NSMutableArray *mutableItemModels = [_itemModels mutableCopy];
//    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
//        [mutableItemModels insertObject:self.headerItemModel atIndex:0];
//    }
//    if (self.footerItemModel && ![self.itemModels containsObject:self.footerItemModel]) {
//        [mutableItemModels addObjectCheck:self.footerItemModel];
//    }
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
    return [[self.margin tgrm_objectAtIndexCheck:0] floatValue];
}

- (CGFloat)marginRight
{
    return [[self.margin tgrm_objectAtIndexCheck:1] floatValue];
}

- (CGFloat)marginBottom
{
    return [[self.margin tgrm_objectAtIndexCheck:2] floatValue];
}

- (CGFloat)marginLeft
{
    return [[self.margin tgrm_objectAtIndexCheck:3] floatValue];
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
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if (![hexString isKindOfClass:[NSString class]]) {
        return nil;
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end

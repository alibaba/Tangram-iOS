//
//  TangramView.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramView.h"
#import "TangramItemModelProtocol.h"
#import "TangramLayoutProtocol.h"
#import "TangramStickyLayout.h"
#import "TangramDragableLayout.h"
#import "TangramFixLayout.h"
#import "TangramEvent.h"
#import "TangramContext.h"
#import <VirtualView/UIView+VirtualView.h>
#import <TMUtils/TMUtils.h>


@interface TangramViewDelegateHandler : NSObject<TangramViewDelegate>

@property   (nonatomic, weak)   TangramView<TMMuiLazyScrollViewDelegate>    *hostTangramView;

@property   (nonatomic, assign) CGFloat  scrollHeight;

@end

//****************************************************************

@interface TangramView () <TMMuiLazyScrollViewDelegate, TMMuiLazyScrollViewDataSource>

@property   (nonatomic, weak, setter=setDataSource:)    id<TangramViewDatasource>       clDataSource;

@property   (nonatomic, weak, setter=setDelegate:)      id<TangramViewDelegate>         clDelegate;

// Contains layouts in TangramView. Key ：layout index；value：layout
@property   (nonatomic, strong) NSMutableDictionary     *layoutDict;
// Layout Key List
@property   (nonatomic, strong) NSMutableArray          *layoutKeyArray;
// item and Layout index dictionary。key ：item unique scrollIndex；value：layout
@property   (nonatomic, strong) NSMutableDictionary     *itemLayoutIndex;
// Store start number(flat index) of First element in every Layout
// key：layoutKey；value：start number(flat index) for first element in the layout
@property   (nonatomic, strong) NSMutableDictionary     *layoutStartNumberIndex;
// Element Count in every layout. key ：layoutKey；value ：element count in a layout(NSNumber)
@property   (nonatomic, strong) NSMutableDictionary     *numberOfItemsInlayout;
// The Dictionary of MUI ID（unique ID，String）and flat index。Key：MUI ID；value：flat index
@property   (nonatomic, strong) NSMutableDictionary     *muiIDIndexIndex;
// The Dictionary of MUI ID（unique ID，String) and Model。Key：MUI ID；value：Model
@property   (nonatomic, strong) NSMutableDictionary     *muiIDModelIndex;

@property   (nonatomic, strong) TangramViewDelegateHandler  *delegateHandler;
// FixLayout Array
@property   (nonatomic, strong) NSMutableArray          *fixLayoutArray;
// StickyLayout Array
@property   (nonatomic, strong) NSMutableArray          *stickyLayoutArray;
// DragableLayout Array
@property   (nonatomic, strong) NSMutableArray          *dragableLayoutArray;
// Record views need to be removed in FixLayout LayoutArray
@property   (nonatomic, strong) NSMutableArray          *toBeRemovedViewArray;

@property   (atomic, assign)    BOOL                    shouldReload;
// Times received of reload
@property   (atomic, assign)    int                     numberOfReloadRequests;
// First time received reload
@property   (atomic, assign)    NSTimeInterval          firstReloadRequestTS;
// Record times of layout enter screen.  key:the identifier of layout value:count of enter times
@property   (nonatomic, strong) NSMutableDictionary     *layoutEnterTimesDict;
// Last time visible layouts
@property   (nonatomic, strong) NSMutableSet            *lastVisibleLayoutIdentifierSet;
// In screen visible layouts
@property   (nonatomic, strong) NSMutableSet            *visibleLayoutIdentifierSet;
// total top offset . For FixLayout and StickyLayout
@property   (nonatomic, assign) CGFloat                 totalTopOffset;

@end

//****************************************************************

@implementation TangramView

#pragma mark - Setter & Getter
- (TangramViewDelegateHandler *)delegateHandler
{
    if (nil == _delegateHandler) {
        _delegateHandler = [[TangramViewDelegateHandler alloc] init];
        _delegateHandler.hostTangramView = self;
        _delegateHandler.scrollHeight = 0.f;
    }
    return _delegateHandler;
}

- (void)setDelegate:(id<TangramViewDelegate>)clDelegate
{
    _clDelegate = clDelegate;
    if (_clDelegate) {
        [super setDelegate:self.delegateHandler];
    } else {
        // will reach here during dealloc
        [super setDelegate:clDelegate];
    }
    
}

- (NSMutableArray *)layoutKeyArray
{
    if (nil == _layoutKeyArray) {
        _layoutKeyArray = [[NSMutableArray alloc] init];
    }
    return _layoutKeyArray;
}

- (NSMutableDictionary *)layoutDict
{
    if (nil == _layoutDict) {
        _layoutDict = [[NSMutableDictionary alloc] init];
    }
    return _layoutDict;
}

- (NSMutableDictionary *)itemLayoutIndex
{
    if (nil == _itemLayoutIndex) {
        _itemLayoutIndex = [[NSMutableDictionary alloc] init];
    }
    return _itemLayoutIndex;
}

- (NSMutableDictionary *)layoutStartNumberIndex
{
    if (nil == _layoutStartNumberIndex) {
        _layoutStartNumberIndex = [[NSMutableDictionary alloc] init];
    }
    return _layoutStartNumberIndex;
}

- (NSMutableDictionary *)numberOfItemsInlayout
{
    if (nil == _numberOfItemsInlayout) {
        _numberOfItemsInlayout = [[NSMutableDictionary alloc] init];
    }
    return _numberOfItemsInlayout;
}

- (NSMutableDictionary *)muiIDIndexIndex
{
    if (nil == _muiIDIndexIndex) {
        _muiIDIndexIndex = [[NSMutableDictionary alloc] init];
    }
    return _muiIDIndexIndex;
}

- (NSMutableDictionary *)muiIDModelIndex
{
    if (nil == _muiIDModelIndex) {
        _muiIDModelIndex = [[NSMutableDictionary alloc] init];
    }
    return _muiIDModelIndex;
}

- (NSMutableArray *)fixLayoutArray
{
    if (nil == _fixLayoutArray) {
        _fixLayoutArray = [[NSMutableArray alloc]init];
    }
    return _fixLayoutArray;
}
- (NSMutableArray *)stickyLayoutArray
{
    if (nil == _stickyLayoutArray) {
        _stickyLayoutArray = [[NSMutableArray alloc]init];
    }
    return _stickyLayoutArray;
}
- (NSMutableArray *)dragableLayoutArray
{
    if (nil == _dragableLayoutArray) {
        _dragableLayoutArray = [[NSMutableArray alloc]init];
    }
    return _dragableLayoutArray;
}

- (NSMutableArray *)toBeRemovedViewArray
{
    if (nil == _toBeRemovedViewArray) {
        _toBeRemovedViewArray = [[NSMutableArray alloc]init];
    }
    return _toBeRemovedViewArray;
}

- (NSMutableDictionary *)layoutEnterTimesDict
{
    if (nil == _layoutEnterTimesDict) {
        _layoutEnterTimesDict = [[NSMutableDictionary alloc]init];
    }
    return _layoutEnterTimesDict;
}

- (NSMutableSet *)lastVisibleLayoutIdentifierSet
{
    if (nil == _lastVisibleLayoutIdentifierSet) {
        _lastVisibleLayoutIdentifierSet = [[NSMutableSet alloc]init];
    }
    return _lastVisibleLayoutIdentifierSet;
}

- (NSMutableSet *)visibleLayoutIdentifierSet
{
    if (nil == _visibleLayoutIdentifierSet) {
        _visibleLayoutIdentifierSet = [[NSMutableSet alloc]init];
    }
    return _visibleLayoutIdentifierSet;
}

#pragma TMMuiLazyScrollViewDataSource
- (NSUInteger)numberOfItemInScrollView:(TMMuiLazyScrollView *)scrollView
{
    NSUInteger number = 0;
    if (self.layoutKeyArray && 0 < self.layoutKeyArray.count) {
        NSUInteger numberOfLayouts = self.layoutKeyArray.count;
        for (int i=0; i< numberOfLayouts; i++) {
            NSString *layoutKey = [self.layoutKeyArray tm_stringAtIndex:i];
            NSUInteger numberOfItemsInLayout = [self.numberOfItemsInlayout tm_integerForKey:layoutKey];
            // Save flat Index for first element in layout
            [self.layoutStartNumberIndex tm_safeSetObject:@(number) forKey:layoutKey];
            // Save the layout reference to flat index
            for (int i=0; i<numberOfItemsInLayout; i++) {
                [self.itemLayoutIndex tm_safeSetObject:layoutKey forKey:[NSString stringWithFormat:@"%ld", (long)(number + i)]];
            }
            number += numberOfItemsInLayout;
        }
    }
    return number;
}

- (TMMuiRectModel *)scrollView:(TMMuiLazyScrollView *)scrollView rectModelAtIndex:(NSUInteger)index
{
    TMMuiRectModel *rectModel = nil;
    NSString *scrollIndex = [NSString stringWithFormat:@"%ld", (long)index];
    NSString *layoutKey = [self.itemLayoutIndex tm_safeValueForKey:scrollIndex];
    UIView<TangramLayoutProtocol> *layout = [self.layoutDict tm_safeValueForKey:layoutKey];
    if (layout) {
        NSUInteger layoutStartNumber = [[self.layoutStartNumberIndex tm_safeValueForKey:layoutKey] unsignedIntegerValue];
        NSUInteger itemModelNumber = index - layoutStartNumber;
        NSObject<TangramItemModelProtocol> *model = [layout.itemModels tm_safeObjectAtIndex:itemModelNumber];
        if (model) {
            NSString *layoutIdentifier = layout.identifier;
            if ([model respondsToSelector:@selector(innerItemModel)] && model.innerItemModel && model.inLayoutIdentifier && model.inLayoutIdentifier.length > 0
                && [layout respondsToSelector:@selector(subLayoutIdentifiers)] &&
                [layout.subLayoutIdentifiers containsObject:model.inLayoutIdentifier]) {
                UIView<TangramLayoutProtocol> *subLayout = [layout.subLayoutDict tm_safeObjectForKey:model.inLayoutIdentifier];
                layoutIdentifier = subLayout.identifier;
            }
            NSString *muiID = [NSString stringWithFormat:@"%@_%@_%@_%@_%ld",
                               layout.layoutType, model.itemType, model.reuseIdentifier,layoutIdentifier,(long)index];
            [self.muiIDIndexIndex tm_safeSetObject:scrollIndex forKey:muiID];
            [self.muiIDModelIndex tm_safeSetObject:model forKey:muiID];
            if ([model isKindOfClass:[TMMuiRectModel class]]) {
                rectModel = (TMMuiRectModel *)model;
            }
            else{
                rectModel = [[TMMuiRectModel alloc] init];
            }
            rectModel.muiID = muiID;
            CGFloat absTop  = CGRectGetMinY(model.itemFrame) + CGRectGetMinY(layout.frame);
            CGFloat absLeft = CGRectGetMinX(model.itemFrame) + CGRectGetMinX(layout.frame);
            //如果是layout内部的subLayout，需要特殊处理
            if ([model respondsToSelector:@selector(innerItemModel)] && model.innerItemModel && model.inLayoutIdentifier && model.inLayoutIdentifier.length > 0
                && [layout respondsToSelector:@selector(subLayoutIdentifiers)] &&
                [layout.subLayoutIdentifiers containsObject:model.inLayoutIdentifier]) {
                UIView<TangramLayoutProtocol> *subLayout = [layout.subLayoutDict tm_safeObjectForKey:model.inLayoutIdentifier];
                absTop += subLayout.vv_top;
                absLeft += subLayout.vv_left;
            }
            rectModel.absRect = CGRectMake(absLeft, absTop, CGRectGetWidth(model.itemFrame), CGRectGetHeight(model.itemFrame));
            if ([model respondsToSelector:@selector(setAbsRect:)]) {
                model.absRect = rectModel.absRect;
            }
            if ([model respondsToSelector:@selector(setMuiID:)]) {
                model.muiID = muiID;
            }
        }
    }
    return rectModel;
}

- (UIView *)scrollView:(TMMuiLazyScrollView *)scrollView itemByMuiID:(NSString *)muiID
{
    UIView *item = nil;
    if (self.clDataSource
        && [self.clDataSource conformsToProtocol:@protocol(TangramViewDatasource)]
        && [self.clDataSource respondsToSelector:@selector(itemInTangramView:withModel:forLayout:atIndex:)]) {
        NSObject<TangramItemModelProtocol> *model = [self.muiIDModelIndex tm_safeValueForKey:muiID];
        NSString *scrollIndex = [self.muiIDIndexIndex tm_safeValueForKey:muiID];
        NSString *layoutKey = [self.itemLayoutIndex tm_safeValueForKey:scrollIndex];
        UIView<TangramLayoutProtocol> *layout = [self.layoutDict tm_safeValueForKey:layoutKey];
        NSString *layoutStartIndex = [self.layoutStartNumberIndex tm_stringForKey:layoutKey];
        NSUInteger indexInLayout = [scrollIndex integerValue] - [layoutStartIndex integerValue];
        if (layout && model) {
            item = [self.clDataSource itemInTangramView:self withModel:model forLayout:layout atIndex:indexInLayout];
        }
        //判断一下是不是subLayout中的item，如果是，则添加到subLayout中
        if ([model respondsToSelector:@selector(innerItemModel)] && model.innerItemModel
            && [model respondsToSelector:@selector(inLayoutIdentifier)]
            && model.inLayoutIdentifier && model.inLayoutIdentifier.length > 0
            && [layout respondsToSelector:@selector(subLayoutIdentifiers)] &&
            [layout.subLayoutIdentifiers containsObject:model.inLayoutIdentifier]) {
            UIView<TangramLayoutProtocol> *subLayout = [layout.subLayoutDict tm_safeObjectForKey:model.inLayoutIdentifier];
            if([subLayout respondsToSelector:@selector(headerItemModel)] && subLayout.headerItemModel == model
               && [layout respondsToSelector:@selector(addHeaderView:)])
            {
                [subLayout addHeaderView:item];
            }
            else if([subLayout respondsToSelector:@selector(footerItemModel)] && subLayout.footerItemModel == model
                    && [subLayout respondsToSelector:@selector(addFooterView:)])
            {
                [subLayout addFooterView:item];
            }
            else{
                [subLayout addSubview:item];
            }
        }
        else if([layout respondsToSelector:@selector(headerItemModel)] && layout.headerItemModel == model
                && [layout respondsToSelector:@selector(addHeaderView:)])
        {
            [layout addHeaderView:item];
        }
        else if([layout respondsToSelector:@selector(footerItemModel)] && layout.footerItemModel == model
                && [layout respondsToSelector:@selector(addFooterView:)])
        {
            [layout addFooterView:item];
        }
        else if (![layout.subviews containsObject:item]) {
            //[item removeFromSuperview];
            if ([layout respondsToSelector:@selector(addSubView:withModel:)]) {
                [layout addSubView:item withModel:model];
            }
            else{
                [layout addSubview:item];
            }
        }
        //强制让fix/dragable/sticky布局里面的组件 不做复用处理
        if ([layout isKindOfClass:[TangramFixLayout class]] || [layout isKindOfClass:[TangramDragableLayout class]] || [layout isKindOfClass:[TangramStickyLayout class]]) {
            item.reuseIdentifier = @"";
        }
        item.frame = model.itemFrame;
    }
    return item;
}

#pragma mark - Private

#pragma mark - Overwrite
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setDataSource:self];
        [super setDelegate:self.delegateHandler];
    }
    return self;
}
- (void)reloadDataAndCleanLayout:(BOOL)cleanLayout cleanElement:(BOOL)cleanElement
{
    if (cleanLayout) {
        for (UIView *layout in [self.layoutDict allValues]) {
            if ([layout isKindOfClass:[UIView class]]) {
                [layout removeFromSuperview];
            }
        }
    }
    if (cleanElement) {
        [super removeAllLayouts];
        self.contentSize = CGSizeMake(self.vv_width, self.vv_height);
    }
    [self reloadData];
    
}
- (void)reloadData
{
    // Get all layout
    if (self.clDataSource
        && [self.clDataSource conformsToProtocol:@protocol(TangramViewDatasource)]
        && [self.clDataSource respondsToSelector:@selector(numberOfLayoutsInTangramView:)]
        && [self.clDataSource respondsToSelector:@selector(layoutInTangramView:atIndex:)]
        && [self.clDataSource respondsToSelector:@selector(itemModelInTangramView:forLayout:atIndex:)]
        && [self.clDataSource respondsToSelector:@selector(numberOfItemsInTangramView:forLayout:)]
        ) {
        //Generate layout, remove old layout
        [self removeLayoutsAndElements:NO];
        NSUInteger numberOfLayouts = [self.clDataSource numberOfLayoutsInTangramView:self];
        [self.layoutDict removeAllObjects];
        [self.layoutKeyArray removeAllObjects];
        for (UIView * view in self.fixLayoutArray) {
            [view removeFromSuperview];
        }
        [self.fixLayoutArray removeAllObjects];
        for (UIView *view in self.stickyLayoutArray) {
            [view removeFromSuperview];
        }
        [self.stickyLayoutArray removeAllObjects];
        for (UIView *view in self.dragableLayoutArray) {
            [view removeFromSuperview];
        }
        [self.dragableLayoutArray removeAllObjects];
        for (int i=0; i< numberOfLayouts; i++) {
            NSString *layoutKey = [NSString stringWithFormat:@"%d", i];
            // BUSMARK - get layout
            UIView<TangramLayoutProtocol> *layout = [self.clDataSource layoutInTangramView:self atIndex:i];
            [self.layoutDict tm_safeSetValue:layout forKey:layoutKey];
            [self.layoutKeyArray tm_safeAddObject:layoutKey];
            NSUInteger numberOfItemsInLayout = [self.clDataSource numberOfItemsInTangramView:self forLayout:layout];
            if(numberOfItemsInLayout == 0 && [layout respondsToSelector:@selector(loadAPI)] && [layout loadAPI].length > 0)
            {
                continue;
            }
            if ([layout respondsToSelector:@selector(setEnableMarginDeduplication:)]) {
                [layout setEnableMarginDeduplication:self.enableMarginDeduplication];
            }
            [self.numberOfItemsInlayout tm_safeSetValue:@(numberOfItemsInLayout) forKey:layoutKey];
            if ([layout respondsToSelector:@selector(position)] && layout.position && layout.position.length > 0)
            {
                if ([layout.position isEqualToString:@"top-fixed"] || [layout.position isEqualToString:@"bottom-fixed"] || [layout.position isEqualToString:@"fixed"] ) {
                    [self.fixLayoutArray tm_safeAddObject:layout];
                }
                if ([layout.position isEqualToString:@"sticky"]) {
                    [self.stickyLayoutArray tm_safeAddObject:layout];
                }
                if ([layout.position isEqualToString:@"float"]){
                    [self.dragableLayoutArray tm_safeAddObject:layout];
                }
            }
            NSMutableArray *modelArray = [[NSMutableArray alloc] init];
            for (int j=0; j<numberOfItemsInLayout; j++) {
                [modelArray tm_safeAddObject:[self.clDataSource itemModelInTangramView:self forLayout:layout atIndex:j]];
            }
            [layout setItemModels:[NSArray arrayWithArray:modelArray]];
        }
        [self layoutContentWithCalculateLayout:YES];
        
    }
    [super reloadData];
}
- (void)removeLayoutsAndElements:(BOOL)cleanElement;
{
    for (UIView *layout in [self.layoutDict allValues]) {
        [layout removeFromSuperview];
    }
    [self.layoutDict removeAllObjects];
    [self.layoutKeyArray removeAllObjects];
    [self.dragableLayoutArray removeAllObjects];
    [self.fixLayoutArray removeAllObjects];
    [self.stickyLayoutArray removeAllObjects];
    if (cleanElement) {
        [super removeAllLayouts];
        self.contentSize = CGSizeMake(self.vv_width, self.vv_height);
    }
}

-(void)reLayoutContent
{
    // Record the first time of call this method,
    // This method will call `heightChanged` once every 500ms max.
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
            [sself heightChanged];
        }
    });
}

-(void)heightChanged
{
    [self layoutContentWithCalculateLayout:NO];
    [super reloadData];
    //Post a height change event.
    TangramEvent *tangramEvent = [[TangramEvent alloc]initWithTopic:@"heightChanged" withTangramView:self posterIdentifier:@"layout" andPoster:self];
    [self.tangramBus postEvent:tangramEvent];
    
}

-(void)reloadLayout:(UIView<TangramLayoutProtocol> *)layout
{
    if (self.clDataSource
        && [self.clDataSource conformsToProtocol:@protocol(TangramViewDatasource)]
        && [self.clDataSource respondsToSelector:@selector(numberOfLayoutsInTangramView:)]
        && [self.clDataSource respondsToSelector:@selector(layoutInTangramView:atIndex:)]
        && [self.clDataSource respondsToSelector:@selector(itemModelInTangramView:forLayout:atIndex:)]
        && [self.clDataSource respondsToSelector:@selector(numberOfItemsInTangramView:forLayout:)]
        ) {
        NSUInteger numberOfItemsInLayout = [self.clDataSource numberOfItemsInTangramView:self forLayout:layout];
        NSMutableArray *modelArray = [[NSMutableArray alloc] init];
        for (int j=0; j<numberOfItemsInLayout; j++) {
            [modelArray tm_safeAddObject:[self.clDataSource itemModelInTangramView:self forLayout:layout atIndex:j]];
        }
        [layout setItemModels:[NSArray arrayWithArray:modelArray]];
        [layout calculateLayout];
    }
    [self heightChanged];
}

- (void)changeLayoutPositionBelowLayout:(UIView<TangramLayoutProtocol> *)layout offset:(CGFloat)offset;
{
    if (![[self.layoutDict allValues] containsObject:layout]) {
        return;
    }
    NSString *layoutKey = nil;
    for (NSString *key in [self.layoutDict allKeys]) {
        if ([self.layoutDict tm_safeObjectForKey:key] == layout) {
            layoutKey = key;
        }
    }
    if (layoutKey) {
        NSString *layoutStartNumberString = [self.layoutStartNumberIndex tm_stringForKey:layoutKey];
        NSUInteger startNumber = [layoutStartNumberString integerValue] + 1;
        NSUInteger endNumber = self.layoutKeyArray.count;
        for (; startNumber <= endNumber; startNumber++) {
            NSString *layoutKeyNumberString = [NSString stringWithFormat:@"%ld", (long)startNumber];
            UIView<TangramLayoutProtocol> *layout = [self.layoutDict tm_safeObjectForKey:layoutKeyNumberString];
            if (layout) {
                layout.vv_top += offset;
            }
        }
    }
    
}
//if calculate is YES, here will call the `calculateLayout` method of layout.
-(void)layoutContentWithCalculateLayout:(BOOL)calculate
{
    CGFloat layoutTop = 0.f;
    CGFloat lastLayoutTop = 0.f;
    CGFloat lastLayoutMarginBottom = 0.f;
    CGFloat contentHeight = 0.f;
    CGFloat contentWidth = 0.f;
    CGFloat topOffset = 0.f;
    NSMutableDictionary *zIndexLayoutDict = [[NSMutableDictionary alloc]init];
    for (UIView<TangramLayoutProtocol> *layout in self.stickyLayoutArray) {
        ((TangramStickyLayout *)layout).enterFloatStatus = NO;
    }
    for (int i=0; i< self.layoutKeyArray.count; i++) {
        NSString *layoutKey = [self.layoutKeyArray tm_stringAtIndex:i];
        UIView<TangramLayoutProtocol> *layout = [self.layoutDict tm_safeObjectForKey:layoutKey];
        NSUInteger numberOfItemsInLayout = [self.clDataSource numberOfItemsInTangramView:self forLayout:layout];
        [self.numberOfItemsInlayout tm_safeSetValue:@(numberOfItemsInLayout) forKey:layoutKey];
        CGFloat marginTop       = 0.f;
        // Make sure there are something in itemModel of layout
        if ([layout conformsToProtocol:@protocol(TangramLayoutProtocol)]
            && [layout respondsToSelector:@selector(marginTop)] && layout.itemModels.count > 0) {
            marginTop = [layout marginTop];
        }
        CGFloat marginRight     = 0.f;
        if ([layout conformsToProtocol:@protocol(TangramLayoutProtocol)]
            && [layout respondsToSelector:@selector(marginRight)] && layout.itemModels.count > 0) {
            marginRight = [layout marginRight];
        }
        CGFloat marginBottom    = 0.f;
        if ([layout conformsToProtocol:@protocol(TangramLayoutProtocol)]
            && [layout respondsToSelector:@selector(marginBottom)] && layout.itemModels.count > 0) {
            marginBottom = [layout marginBottom];
        }
        CGFloat marginLeft      = 0.f;
        if ([layout conformsToProtocol:@protocol(TangramLayoutProtocol)]
            && [layout respondsToSelector:@selector(marginLeft)] && layout.itemModels.count > 0) {
            marginLeft = [layout marginLeft];
        }
        // BUSMARK - Add TangramView
        [self addSubview:layout];
        
        //CGFloat contentHeight = self.contentSize.height;
        //If the layout is  `FixLayout` or its subclass, its height will not be added to the height of contentSize.
        if ([layout respondsToSelector:@selector(position)]  && ([layout.position isEqualToString:@"top-fixed"] || [layout.position isEqualToString:@"bottom-fixed"] || [layout.position isEqualToString:@"float"] || [layout.position isEqualToString:@"fixed"]))
        {
            if (calculate) {
                [layout calculateLayout];
            }
            CGPoint originPoint = CGPointMake(0, 0);
            switch (((TangramFixLayout *)layout).alignType) {
                case TopLeft:
                    originPoint.x += ((TangramFixLayout *)layout).offsetX;
                    originPoint.y += ((TangramFixLayout *)layout).offsetY;
                    originPoint.y += self.fixExtraOffset;
                    if (topOffset < originPoint.y) {
                        //offset 保证和最高的固定布局保持一致
                        topOffset = originPoint.y;
                    }
                    break;
                case TopRight:
                    originPoint.x = self.vv_width - layout.vv_width - ((TangramFixLayout *)layout).offsetX;
                    originPoint.y += ((TangramFixLayout *)layout).offsetY;
                    originPoint.y += self.fixExtraOffset;
                    if (topOffset < originPoint.y) {
                        //offset 保证和最高的固定布局保持一致
                        topOffset = originPoint.y;
                    }
                    break;
                case BottomLeft:
                    originPoint.x += ((TangramFixLayout *)layout).offsetX;
                    originPoint.y = self.vv_height - layout.vv_height - ((TangramFixLayout *)layout).offsetY;
                    break;
                case BottomRight:
                    originPoint.x = self.vv_width - layout.vv_width - ((TangramFixLayout *)layout).offsetX;
                    originPoint.y = self.vv_height - layout.vv_height - ((TangramFixLayout *)layout).offsetY;
                    break;
            }
            ((TangramFixLayout *)layout).originPoint = originPoint;
            layout.frame = CGRectMake(originPoint.x , originPoint.y, layout.vv_width, layout.vv_height);
            switch (((TangramFixLayout *)layout).showType) {
                case FixLayoutShowOnLeave:
                    ((TangramFixLayout *)layout).showY = layoutTop;
                    if (calculate && layout.hidden == NO) {
                        layout.hidden = YES;
                    }
                    break;
                case FixLayoutShowOnEnter:
                    ((TangramFixLayout *)layout).showY = lastLayoutTop;
                    if (calculate && layout.hidden == YES) {
                        layout.hidden = NO;
                    }
                    break;
                case FixLayoutShowAlways:
                    if (calculate) {
                        layout.hidden = YES;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            layout.hidden = NO;
                        });
                    }
                    break;
            }
        }
        //如果不是，那么算高度
        else{
            
            if (self.enableMarginDeduplication) {
                //marginTop和上一个marginBottom取大的
                layout.frame = CGRectMake(marginLeft, MAX(marginTop,lastLayoutMarginBottom) + layoutTop,
                                          CGRectGetWidth(self.frame) - marginLeft - marginRight, layout.frame.size.height);
            }
            else{
                layout.frame = CGRectMake(marginLeft, marginTop + layoutTop,
                                          CGRectGetWidth(self.frame) - marginLeft - marginRight, layout.frame.size.height);
            }
            [self sendSubviewToBack:layout];
            if(calculate)
            {
                //BUSMARK - layout布局
                [layout calculateLayout];
            }
            if (self.enableMarginDeduplication) {
                //如果启动了Margin去重，不算bottom，另算
                layoutTop = CGRectGetMaxY(layout.frame);
                //去重的话，需要记录一下上一个的marginBottom，下次要做对比
                lastLayoutMarginBottom = layout.marginBottom;
            }
            else{
                layoutTop = CGRectGetMaxY(layout.frame) + marginBottom;
            }
            lastLayoutTop = CGRectGetMinY(layout.frame);
            contentHeight   = CGRectGetMaxY(layout.frame) + layout.marginBottom;
        }
        contentWidth    = MAX(self.contentSize.width, CGRectGetWidth(layout.frame));
        if ([layout respondsToSelector:@selector(zIndex)] && layout.zIndex > 0) {
//            layout.layer.zPosition = layout.zIndex;
            NSMutableArray *zIndexMutableArray = [zIndexLayoutDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)(layout.zIndex)] class:[NSMutableArray class]];
            if (zIndexMutableArray == nil) {
                zIndexMutableArray = [[NSMutableArray alloc]init];
            }
            [zIndexMutableArray tm_safeAddObject:layout];
            [zIndexLayoutDict tm_safeSetObject:zIndexMutableArray forKey:[NSString stringWithFormat:@"%ld",(long)(layout.zIndex)]];
        }
        else{
            NSMutableArray *zIndexMutableArray = [zIndexLayoutDict tm_safeObjectForKey:@"0" class:[NSMutableArray class]];
            if (zIndexMutableArray == nil) {
                zIndexMutableArray = [[NSMutableArray alloc]init];
            }
            [zIndexMutableArray tm_safeAddObject:layout];
            [zIndexLayoutDict tm_safeSetObject:zIndexMutableArray forKey:@"0"];
        }
        if ([layout.identifier isEqualToString:@"newer_banner_container-2"]) {
            layout.userInteractionEnabled = NO;
        }
    }
    NSArray *zIndexArray  = [[zIndexLayoutDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSInteger firstNumber = [obj1 integerValue];
        NSInteger secondNumber = [obj2 integerValue];
        if (firstNumber > secondNumber) {
            return  NSOrderedDescending;
        }
        else if(firstNumber < secondNumber){
            return NSOrderedAscending ;
        }
        else{
            return NSOrderedSame;
        }
    }];
    for (NSString *zIndex in zIndexArray) {
        NSMutableArray *zIndexMutableArray = [zIndexLayoutDict tm_safeObjectForKey:zIndex class:[NSMutableArray class]];
        for (UIView *layout in zIndexMutableArray) {
            [self bringSubviewToFront:layout];
        }
    }

    self.contentSize = CGSizeMake(contentWidth, contentHeight);
    if (self.contentSize.width > self.vv_width) {
        self.contentSize = CGSizeMake(self.vv_width, self.contentSize.height);
    }
    
    for (UIView *layout in self.dragableLayoutArray) {
        [self bringSubviewToFront:layout];
    }
    
    for (UIView<TangramLayoutProtocol> *layout in self.stickyLayoutArray) {
        //目前仅处理吸顶类型的顶部额外offset
        if (((TangramStickyLayout *)layout).stickyBottom == NO) {
            if (self.fixExtraOffset > 0.f) {
                ((TangramStickyLayout *)layout).extraOffset = self.fixExtraOffset;
            }
            //topOffset(实际偏移顶部的距离) 已经比extraOffset大了，那么已经不需要再网上加额外的offset了
            //有两个以及以上的吸顶有可能出现这种情况
            if (topOffset >= ((TangramStickyLayout *)layout).extraOffset) {
                ((TangramStickyLayout *)layout).extraOffset = 0.f;
            }
            topOffset += (((TangramStickyLayout *)layout).extraOffset + layout.vv_height);
        }
        [self bringSubviewToFront:layout];
    }
    for (UIView<TangramLayoutProtocol> *layout in self.fixLayoutArray) {
        [self bringSubviewToFront:layout];
    }
    //这个动作，是为了保证让Fixlayout的frame不因为contentOffset的突然改变而改变固定和浮动布局的位置
    //Research Mark
    [self scrollViewDidScroll:self];
}

- (NSUInteger)layoutIndexByHeight:(CGFloat)baseLine
{
    NSInteger min = 0 ;
    NSInteger max = self.layoutDict.count;
    NSInteger mid = ceilf((CGFloat)(min + max) / 2.f);
    while (mid > min && mid < max) {
        //获取layout的rect
        UIView *layout = (UIView *)[self.layoutDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)mid]];
        CGFloat itemTop = CGRectGetMinY(layout.frame);
        if (itemTop <= baseLine) {
            UIView *nextLayout = (UIView *)[self.layoutDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)(mid+1)]];
            CGFloat nextTop = CGRectGetMinY(nextLayout.frame);
            if (nextTop > baseLine) {
                break;
            }
            min = mid;
        }
        else {
            max = mid;
        }
        mid = ceilf((CGFloat)(min + max) / 2.f);
    }
    return mid;
}

- (void)resetLayoutEnterTimes
{
    [self.visibleLayoutIdentifierSet removeAllObjects];
    [self.lastVisibleLayoutIdentifierSet removeAllObjects];
    [self.layoutEnterTimesDict removeAllObjects];
}
@end
//在这里实现相关的ScrollViewDelegate，避免覆盖父类的方法
@implementation TangramViewDelegateHandler


#pragma mark - TMMuiLazyScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // BUSMARK - 查找layout 即将进入 或者 已经进入
    NSUInteger min = [self.hostTangramView layoutIndexByHeight:scrollView.contentOffset.y];
    NSUInteger max = [self.hostTangramView layoutIndexByHeight:scrollView.contentOffset.y + scrollView.vv_height];
    [self.hostTangramView.visibleLayoutIdentifierSet removeAllObjects];
    for (NSUInteger i = min; i <= max; i++) {
        UIView<TangramLayoutProtocol> *layout = [self.hostTangramView.layoutDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
        if (layout.identifier && layout.identifier.length > 0) {
            [self.hostTangramView.visibleLayoutIdentifierSet addObject:layout.identifier];
        }
    }
    NSMutableSet *appearLayoutSet = [self.hostTangramView.visibleLayoutIdentifierSet mutableCopy];
    //这样子取交集可能会有问题：如果layout的identifier重新生成？
    [appearLayoutSet minusSet:self.hostTangramView.lastVisibleLayoutIdentifierSet];
    for (NSUInteger i = min; i <= max; i++) {
        UIView<TangramLayoutProtocol> *layout = [self.hostTangramView.layoutDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
        NSUInteger times = 0;
        if ([appearLayoutSet containsObject:layout.identifier])
        {
            //执行delegate
            times = [self.hostTangramView.layoutEnterTimesDict tm_integerForKey:layout.identifier];
            //[layout.layoutEventDelegate layoutDidEnter:layout times:times];
            TangramEvent *layoutEnterEvent = [[TangramEvent alloc]initWithTopic:@"layoutEnter" withTangramView:self.hostTangramView posterIdentifier:layout.identifier andPoster:layout];
            [layoutEnterEvent setParam:[NSNumber numberWithUnsignedInteger:times] forKey:@"times"];
            [self.hostTangramView.tangramBus postEvent:layoutEnterEvent];
            [self.hostTangramView.layoutEnterTimesDict tm_safeSetObject:[NSNumber numberWithUnsignedInteger:times + 1] forKey:layout.identifier];
        }
    }
    //完毕，写入lastVisibleLayoutSet
    self.hostTangramView.lastVisibleLayoutIdentifierSet = [self.hostTangramView.visibleLayoutIdentifierSet mutableCopy];
    
    // 做fix属性的相关计算
    // 如果要固定住，需要满足：layout的layoutType返回值是fix，layout中Model的reuseIdentifier的返回的字符串length = 0
    // fix的marginTop和marginBottom在这里是指固定离顶端/底端的距离
    CGFloat topOffset = 0;
    CGFloat bottomOffset = scrollView.vv_height;
    for (UIView<TangramLayoutProtocol> *layout in self.hostTangramView.fixLayoutArray) {
        if (((TangramFixLayout *)layout).showY > 0 && ((TangramFixLayout *)layout).showType != FixLayoutShowAlways) {
            if (scrollView.contentOffset.y >= ((TangramFixLayout *)layout).showY) {
                if (((TangramFixLayout *)layout).hidden != NO) {
                    TangramEvent *fixLayoutShouldShowEvent = [[TangramEvent alloc]initWithTopic:@"TangramFixLayoutShouldShow" withTangramView:self.hostTangramView posterIdentifier:nil andPoster:self];
                    [fixLayoutShouldShowEvent setParam:layout forKey:@"layout"];
                    [self.hostTangramView.tangramBus postEvent:fixLayoutShouldShowEvent];
                }
                //((TangramFixLayout *)layout).hidden = NO;
            }
            else{
                if (((TangramFixLayout *)layout).hidden != YES) {
                    TangramEvent *fixLayoutShouldHideEvent = [[TangramEvent alloc]initWithTopic:@"TangramFixLayoutShouldHide" withTangramView:self.hostTangramView posterIdentifier:nil andPoster:self];
                    [fixLayoutShouldHideEvent setParam:layout forKey:@"layout"];
                    [self.hostTangramView.tangramBus postEvent:fixLayoutShouldHideEvent];
                }
                //((TangramFixLayout *)layout).hidden = YES;
            }
        }
        if ([layout.position isEqualToString:@"top-fixed"] ||
            (([layout.position isEqualToString:@"fixed"]) && (((TangramFixLayout *)layout).alignType == TopLeft || ((TangramFixLayout *)layout).alignType == TopRight))) {
            layout.frame = CGRectMake(layout.frame.origin.x,scrollView.contentOffset.y + ((TangramFixLayout *)layout).originPoint.y, layout.frame.size.width, layout.frame.size.height);
            if (topOffset < layout.vv_height + ((TangramFixLayout *)layout).originPoint.y) {
                topOffset = layout.vv_height + ((TangramFixLayout *)layout).originPoint.y;
            }
        }
        else {
            layout.frame = CGRectMake(layout.frame.origin.x,scrollView.vv_height- layout.vv_height + scrollView.contentOffset.y -  ((TangramFixLayout *)layout).offsetY, layout.frame.size.width, layout.frame.size.height);
            bottomOffset -= (layout.vv_height + ((TangramFixLayout *)layout).offsetY);
            if (bottomOffset > (scrollView.vv_height - layout.vv_height - ((TangramFixLayout *)layout).offsetY)) {
                bottomOffset  = (scrollView.vv_height - layout.vv_height - ((TangramFixLayout *)layout).offsetY);
            }
        }
    }
    for (UIView<TangramLayoutProtocol> *layout in self.hostTangramView.stickyLayoutArray) {
        //吸顶判断
        if (((TangramStickyLayout *)layout).stickyBottom == NO
            && scrollView.contentOffset.y >= ((TangramStickyLayout *)layout).originalY - topOffset - ((TangramStickyLayout *)layout).extraOffset) {
            ((TangramStickyLayout *)layout).enterFloatStatus = YES;
            layout.frame = CGRectMake(layout.frame.origin.x,scrollView.contentOffset.y + topOffset + layout.marginTop + ((TangramStickyLayout *)layout).extraOffset , layout.frame.size.width, layout.frame.size.height);
            topOffset += (layout.vv_height + layout.marginTop + layout.marginBottom + ((TangramStickyLayout *)layout).extraOffset) ;
        }
        //吸底判断
        else if(((TangramStickyLayout *)layout).stickyBottom == YES
                && scrollView.contentOffset.y + scrollView.vv_height >= ((TangramStickyLayout *)layout).originalY + layout.vv_height)
        {
            ((TangramStickyLayout *)layout).enterFloatStatus = YES;
            layout.frame = CGRectMake(layout.frame.origin.x,scrollView.contentOffset.y + scrollView.vv_height - layout.vv_height - layout.marginBottom, layout.frame.size.width, layout.frame.size.height);
            bottomOffset -= (layout.vv_height + layout.marginTop + layout.marginBottom);
        }
        else
        {
            ((TangramStickyLayout *)layout).enterFloatStatus = NO;
            layout.frame = CGRectMake(layout.frame.origin.x,((TangramStickyLayout *)layout).originalY, layout.frame.size.width, layout.frame.size.height);
        }
    }
    for (UIView<TangramLayoutProtocol> *layout in self.hostTangramView.dragableLayoutArray) {
        layout.frame = CGRectMake(layout.frame.origin.x, ((TangramDragableLayout *)layout).originPoint.y + scrollView.contentOffset.y , layout.frame.size.width, layout.frame.size.height);
    }
    
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidScroll:self.hostTangramView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2)
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidZoom:self.hostTangramView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.hostTangramView.clDelegate scrollViewWillBeginDragging:self.hostTangramView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.hostTangramView.clDelegate scrollViewWillEndDragging:self.hostTangramView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidEndDragging:self.hostTangramView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [self.hostTangramView.clDelegate scrollViewWillBeginDecelerating:self.hostTangramView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidEndDecelerating:self.hostTangramView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidEndScrollingAnimation:self.hostTangramView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        return [self.hostTangramView.clDelegate viewForZoomingInScrollView:self.hostTangramView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2)
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.hostTangramView.clDelegate scrollViewWillBeginZooming:self.hostTangramView withView:view];
    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidEndZooming:self.hostTangramView withView:view atScale:scale];
    }
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
    {
        return [self.hostTangramView.clDelegate scrollViewShouldScrollToTop:self.hostTangramView];
    }
    return self.hostTangramView.scrollsToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (self.hostTangramView.clDelegate && [self.hostTangramView.clDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.hostTangramView.clDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
    {
        [self.hostTangramView.clDelegate scrollViewDidScrollToTop:self.hostTangramView];
    }
}

@end

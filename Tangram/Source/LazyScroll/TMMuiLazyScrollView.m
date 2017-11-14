//
//  TMMuiLazyScrollView.m
//  LazyScrollView
//
//  Copyright (c) 2015-2017 tmall. All rights reserved.
//

#import "TMMuiLazyScrollView.h"
#import <objc/runtime.h>
#import "TMUtils.h"

#define RenderBufferWindow 20.f


@implementation UIView(TMMuiLazyScrollView)

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self initWithFrame:frame]) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (NSString *)reuseIdentifier
{
    return objc_getAssociatedObject(self, @"tm_reuseIdentifier");
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier
{
    objc_setAssociatedObject(self, @"tm_reuseIdentifier", reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)muiID
{
    return objc_getAssociatedObject(self, @"tm_muiID");
}

- (void)setMuiID:(NSString *)muiID
{
    objc_setAssociatedObject(self, @"tm_muiID", muiID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

//****************************************************************

@interface TMMuiLazyScrollView() <UIScrollViewDelegate> {
    NSMutableSet *_visibleItems;
    NSMutableSet *_inScreenVisibleItems;
}

// Store reuseable cells by reuseIdentifier. The key is reuseIdentifier
// of views , value is an array that contains reuseable cells.
@property (nonatomic, strong) NSMutableDictionary *recycledIdentifierItemsDic;
// Store reuseable cells by muiID.
@property (nonatomic, strong) NSMutableDictionary *recycledMuiIDItemsDic;

// Store view models (TMMuiRectModel).
@property (nonatomic, strong) NSMutableArray *itemsFrames;

// ScrollView delegate, store original scrollDelegate here.
// Because of lazyscrollview need calculate what views should be shown
// in scrollDidScroll.
@property (nonatomic, weak) id<TMMuiLazyScrollViewDelegate> lazyScrollViewDelegate;

// View Model sorted by Top Edge.
@property (nonatomic, strong) NSArray *modelsSortedByTop;
// View Model sorted by Bottom Edge.
@property (nonatomic, strong) NSArray *modelsSortedByBottom;

// Store view models below contentOffset of ScrollView
@property (nonatomic, strong) NSMutableSet *firstSet;
// Store view models above contentOffset + height of ScrollView
@property (nonatomic, strong)  NSMutableSet *secondSet;

// Record contentOffset of scrollview in previous time that calculate
// views to show
@property (nonatomic, assign) CGPoint lastScrollOffset;

// Record current muiID of visible view for calculate.
// Will be used for dequeueReusableItem methods.
@property (nonatomic, strong) NSString *currentVisibleItemMuiID;

// It is used to store views need to assign new value after reload.
@property (nonatomic, strong) NSMutableSet *shouldReloadItems;

// Record muiIDs of visible items. Used for calc enter times.
@property (nonatomic, strong) NSSet *muiIDOfVisibleViews;
// Store the times of view entered the screen, the key is muiID.
@property (nonatomic, strong) NSMutableDictionary *enterDict;
// Store last time visible muiID. Used for calc enter times.
@property (nonatomic, strong) NSMutableSet *lastVisibleMuiID;

@end

//****************************************************************

@implementation TMMuiLazyScrollView

@dynamic visibleItems, inScreenVisibleItems;

#pragma mark - Getter & Setter

- (NSMutableSet *)shouldReloadItems
{
    if (nil == _shouldReloadItems) {
        _shouldReloadItems = [[NSMutableSet alloc] init];
    }
    return _shouldReloadItems;
}

- (NSArray *)modelsSortedByTop
{
    if (!_modelsSortedByTop){
        _modelsSortedByTop = [[NSArray alloc] init];
    }
    return _modelsSortedByTop;
}

- (NSArray *)modelsSortedByBottom
{
    if (!_modelsSortedByBottom) {
        _modelsSortedByBottom = [[NSArray alloc]init];
    }
    return _modelsSortedByBottom;
}

- (NSMutableDictionary *)enterDict
{
    if (nil == _enterDict) {
        _enterDict = [[NSMutableDictionary alloc]init];
    }
    return _enterDict;
}

- (NSMutableDictionary *)recycledMuiIDItemsDic
{
    if(nil == _recycledMuiIDItemsDic) {
        _recycledMuiIDItemsDic = [[NSMutableDictionary alloc]init];
    }
    return _recycledMuiIDItemsDic;
}

- (NSSet *)inScreenVisibleItems
{
    return [_inScreenVisibleItems copy];
}

- (NSSet *)visibleItems
{
    return [_visibleItems copy];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame, self.frame)) {
        [super setFrame:frame];
    }
}

- (void)setDelegate:(id<TMMuiLazyScrollViewDelegate>)delegate
{
    if (!delegate) {
        [super setDelegate:nil];
        _lazyScrollViewDelegate = nil;
    } else {
        _lazyScrollViewDelegate = delegate;
        [super setDelegate:self];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizesSubviews = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _recycledIdentifierItemsDic = [[NSMutableDictionary alloc] init];
        _visibleItems = [[NSMutableSet alloc] init];
        _inScreenVisibleItems = [[NSMutableSet alloc] init];
        _itemsFrames = [[NSMutableArray alloc] init];
        _firstSet = [[NSMutableSet alloc] initWithCapacity:30];
        _secondSet = [[NSMutableSet alloc] initWithCapacity:30];
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    _dataSource = nil;
    self.delegate = nil;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Calculate which views should be shown.
    // Calcuting will cost some time, so here is a buffer for reducing
    // times of calculating.
    CGFloat currentY = scrollView.contentOffset.y;
    CGFloat buffer = RenderBufferWindow / 2;
    if (buffer < ABS(currentY - self.lastScrollOffset.y)) {
        self.lastScrollOffset = scrollView.contentOffset;
        [self assembleSubviews];
        [self findViewsInVisibleRect];
    }
    
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.lazyScrollViewDelegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2)
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.lazyScrollViewDelegate scrollViewDidZoom:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.lazyScrollViewDelegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.lazyScrollViewDelegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.lazyScrollViewDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.lazyScrollViewDelegate scrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.lazyScrollViewDelegate scrollViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.lazyScrollViewDelegate scrollViewDidEndScrollingAnimation:self];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.lazyScrollViewDelegate viewForZoomingInScrollView:self];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2)
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.lazyScrollViewDelegate scrollViewWillBeginZooming:self withView:view];
    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.lazyScrollViewDelegate scrollViewDidEndZooming:self withView:view atScale:scale];
    }
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.lazyScrollViewDelegate scrollViewShouldScrollToTop:self];
    }
    return self.scrollsToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (self.lazyScrollViewDelegate &&
        [self.lazyScrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.lazyScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.lazyScrollViewDelegate scrollViewDidScrollToTop:self];
    }
}

#pragma mark - Core Logic

// Do Binary search here to find index in view model array.
- (NSUInteger)binarySearchForIndex:(NSArray *)frameArray baseLine:(CGFloat)baseLine isFromTop:(BOOL)fromTop
{
    NSInteger min = 0 ;
    NSInteger max = frameArray.count - 1;
    NSInteger mid = ceilf((min + max) * 0.5f);
    while (mid > min && mid < max) {
        CGRect rect = [(TMMuiRectModel *)[frameArray tm_safeObjectAtIndex:mid] absRect];
        // For top
        if(fromTop) {
            CGFloat itemTop = CGRectGetMinY(rect);
            if (itemTop <= baseLine) {
                CGRect nextItemRect = [(TMMuiRectModel *)[frameArray tm_safeObjectAtIndex:mid + 1] absRect];
                CGFloat nextTop = CGRectGetMinY(nextItemRect);
                if (nextTop > baseLine) {
                    break;
                }
                min = mid;
            } else {
                max = mid;
            }
        }
        // For bottom
        else {
            CGFloat itemBottom = CGRectGetMaxY(rect);
            if (itemBottom >= baseLine) {
                CGRect nextItemRect = [(TMMuiRectModel *)[frameArray tm_safeObjectAtIndex:mid + 1] absRect];
                CGFloat nextBottom = CGRectGetMaxY(nextItemRect);
                if (nextBottom < baseLine) {
                    break;
                }
                min = mid;
            } else {
                max = mid;
            }
        }
        mid = ceilf((CGFloat)(min + max) / 2.f);
    }
    return mid;
}

// Get which views should be shown in LazyScrollView.
// The kind of values In NSSet is muiID.
- (NSSet *)showingItemIndexSetFrom:(CGFloat)startY to:(CGFloat)endY
{
    NSUInteger endBottomIndex = [self binarySearchForIndex:self.modelsSortedByBottom baseLine:startY isFromTop:NO];
    [self.firstSet removeAllObjects];
    for (NSUInteger i = 0; i <= endBottomIndex; i++) {
        TMMuiRectModel *model = [self.modelsSortedByBottom tm_safeObjectAtIndex:i];
        if (model != nil) {
            [self.firstSet addObject:model.muiID];
        }
    }
    
    NSUInteger endTopIndex = [self binarySearchForIndex:self.modelsSortedByTop baseLine:endY isFromTop:YES];
    [self.secondSet removeAllObjects];
    for (NSInteger i = 0; i <= endTopIndex; i++) {
        TMMuiRectModel *model = [self.modelsSortedByTop tm_safeObjectAtIndex:i];
        if (model != nil) {
            [self.secondSet addObject:model.muiID];
        }
    }
    
    [self.firstSet intersectSet:self.secondSet];
    return [self.firstSet copy];
}

// Get view models from delegate. Create to indexes for sorting.
- (void)creatScrollViewIndex
{
    NSUInteger count = 0;
    if (self.dataSource &&
        [self.dataSource conformsToProtocol:@protocol(TMMuiLazyScrollViewDataSource)] &&
        [self.dataSource respondsToSelector:@selector(numberOfItemInScrollView:)]) {
        count = [self.dataSource numberOfItemInScrollView:self];
    }
    
    [self.itemsFrames removeAllObjects];
    for (NSUInteger i = 0 ; i< count ; i++) {
        TMMuiRectModel *rectmodel;
        if (self.dataSource &&
            [self.dataSource conformsToProtocol:@protocol(TMMuiLazyScrollViewDataSource)] &&
            [self.dataSource respondsToSelector:@selector(scrollView: rectModelAtIndex:)]) {
            rectmodel = [self.dataSource scrollView:self rectModelAtIndex:i];
            if (rectmodel.muiID.length == 0) {
                rectmodel.muiID = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            }
        }
        [self.itemsFrames tm_safeAddObject:rectmodel];
    }
    
    self.modelsSortedByTop = [self.itemsFrames sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
                                 CGRect rect1 = [(TMMuiRectModel *) obj1 absRect];
                                 CGRect rect2 = [(TMMuiRectModel *) obj2 absRect];
                                 if (rect1.origin.y < rect2.origin.y) {
                                     return NSOrderedAscending;
                                 }  else if (rect1.origin.y > rect2.origin.y) {
                                     return NSOrderedDescending;
                                 } else {
                                     return NSOrderedSame;
                                 }
                             }];
    
    self.modelsSortedByBottom = [self.itemsFrames sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
                                    CGRect rect1 = [(TMMuiRectModel *) obj1 absRect];
                                    CGRect rect2 = [(TMMuiRectModel *) obj2 absRect];
                                    CGFloat bottom1 = CGRectGetMaxY(rect1);
                                    CGFloat bottom2 = CGRectGetMaxY(rect2);
                                    if (bottom1 > bottom2) {
                                        return NSOrderedAscending;
                                    } else if (bottom1 < bottom2) {
                                        return  NSOrderedDescending;
                                    } else {
                                        return NSOrderedSame;
                                    }
                                }];
}

- (void)findViewsInVisibleRect
{
    NSMutableSet *itemViewSet = [self.muiIDOfVisibleViews mutableCopy];
    [itemViewSet minusSet:self.lastVisibleMuiID];
    for (UIView *view in _visibleItems) {
        if (view && [itemViewSet containsObject:view.muiID]) {
            if ([view conformsToProtocol:@protocol(TMMuiLazyScrollViewCellProtocol)] &&
                [view respondsToSelector:@selector(mui_didEnterWithTimes:)]) {
                NSUInteger times = 0;
                if ([self.enterDict tm_safeObjectForKey:view.muiID] != nil) {
                    times = [self.enterDict tm_integerForKey:view.muiID] + 1;
                }
                NSNumber *showTimes = [NSNumber numberWithUnsignedInteger:times];
                [self.enterDict tm_safeSetObject:showTimes forKey:view.muiID];
                [(UIView<TMMuiLazyScrollViewCellProtocol> *)view mui_didEnterWithTimes:times];
            }
        }
    }
    self.lastVisibleMuiID = [self.muiIDOfVisibleViews copy];
}

// A simple method to show view that should be shown in LazyScrollView.
- (void)assembleSubviews
{
    CGRect visibleBounds = self.bounds;
    CGFloat minY = CGRectGetMinY(visibleBounds) - RenderBufferWindow;
    CGFloat maxY = CGRectGetMaxY(visibleBounds) + RenderBufferWindow;
    [self assembleSubviewsForReload:NO minY:minY maxY:maxY];
}

- (void)assembleSubviewsForReload:(BOOL)isReload minY:(CGFloat)minY maxY:(CGFloat)maxY
{
    NSSet *itemShouldShowSet = [self showingItemIndexSetFrom:minY to:maxY];
    self.muiIDOfVisibleViews = [self showingItemIndexSetFrom:CGRectGetMinY(self.bounds) to:CGRectGetMaxY(self.bounds)];
    
    NSMutableSet  *recycledItems = [[NSMutableSet alloc] init];
    // For recycling. Find which views should not in visible area.
    NSSet *visibles = [_visibleItems copy];
    for (UIView *view in visibles) {
        // Make sure whether the view should be shown.
        BOOL isToShow  = [itemShouldShowSet containsObject:view.muiID];
        if (!isToShow) {
            if ([view respondsToSelector:@selector(mui_didLeave)]){
                [(UIView<TMMuiLazyScrollViewCellProtocol> *)view mui_didLeave];
            }
            // If this view should be recycled and the length of its reuseidentifier is over 0.
            if (view.reuseIdentifier.length > 0) {
                // Then recycle the view.
                NSMutableSet *recycledIdentifierSet = [self recycledIdentifierSet:view.reuseIdentifier];
                [recycledIdentifierSet addObject:view];
                view.hidden = YES;
                [recycledItems addObject:view];
                // Also add to muiID recycle dict.
                [self.recycledMuiIDItemsDic tm_safeSetObject:view forKey:view.muiID];
            } else if(isReload && view.muiID) {
                // Need to reload unreusable views.
                [self.shouldReloadItems addObject:view.muiID];
            }
        } else if (isReload && view.muiID) {
            [self.shouldReloadItems addObject:view.muiID];
        }
        
    }
    [_visibleItems minusSet:recycledItems];
    [recycledItems removeAllObjects];
    // Creare new view.
    for (NSString *muiID in itemShouldShowSet) {
        BOOL shouldReload = isReload || [self.shouldReloadItems containsObject:muiID];
        if (![self isCellVisible:muiID] || [self.shouldReloadItems containsObject:muiID]) {
            if (self.dataSource &&
                [self.dataSource conformsToProtocol:@protocol(TMMuiLazyScrollViewDataSource)] &&
                [self.dataSource respondsToSelector:@selector(scrollView:itemByMuiID:)]) {
                // Create view by dataSource.
                // If you call dequeue method in your dataSource, the currentVisibleItemMuiID
                // will be used for searching reusable view.
                if (shouldReload) {
                    self.currentVisibleItemMuiID = muiID;
                }
                UIView *viewToShow = [self.dataSource scrollView:self itemByMuiID:muiID];
                self.currentVisibleItemMuiID = nil;
                // Call afterGetView.
                if ([viewToShow conformsToProtocol:@protocol(TMMuiLazyScrollViewCellProtocol)] &&
                    [viewToShow respondsToSelector:@selector(mui_afterGetView)]) {
                    [(UIView<TMMuiLazyScrollViewCellProtocol> *)viewToShow mui_afterGetView];
                }
                if (viewToShow) {
                    viewToShow.muiID = muiID;
                    viewToShow.hidden = NO;
                    if (![_visibleItems containsObject:viewToShow]) {
                        [_visibleItems addObject:viewToShow];
                    }
                }
            }
            [self.shouldReloadItems removeObject:muiID];
        }
    }
    [_inScreenVisibleItems removeAllObjects];
    for (UIView *view in _visibleItems) {
        if ([view isKindOfClass:[UIView class]] && view.superview) {
            CGRect absRect = [view.superview convertRect:view.frame toView:self];
            if ((absRect.origin.y + absRect.size.height >= CGRectGetMinY(self.bounds)) &&
                (absRect.origin.y <= CGRectGetMaxY(self.bounds))) {
                [_inScreenVisibleItems addObject:view];
            }
        }
    }
}

// Get NSSet accroding to reuse identifier.
- (NSMutableSet *)recycledIdentifierSet:(NSString *)reuseIdentifier;
{
    if (reuseIdentifier.length == 0) {
        return nil;
    }
    
    NSMutableSet *result = [self.recycledIdentifierItemsDic tm_safeObjectForKey:reuseIdentifier];
    if (result == nil) {
        result = [[NSMutableSet alloc] init];
        [self.recycledIdentifierItemsDic setObject:result forKey:reuseIdentifier];
    }
    return result;
}

// Reloads everything and redisplays visible views.
- (void)reloadData
{
    [self creatScrollViewIndex];
    if (self.itemsFrames.count > 0) {
        CGRect visibleBounds = self.bounds;
        CGFloat minY = CGRectGetMinY(visibleBounds) - RenderBufferWindow;
        CGFloat maxY = CGRectGetMaxY(visibleBounds) + RenderBufferWindow;
        [self assembleSubviewsForReload:YES minY:minY maxY:maxY];
        [self findViewsInVisibleRect];
    }

}

// Remove all subviews and reuseable views.
- (void)removeAllLayouts
{
    NSSet *visibles = _visibleItems;
    for (UIView *view in visibles) {
        NSMutableSet *recycledIdentifierSet = [self recycledIdentifierSet:view.reuseIdentifier];
        [recycledIdentifierSet addObject:view];
        view.hidden = YES;
    }
    [_visibleItems removeAllObjects];
    [_recycledIdentifierItemsDic removeAllObjects];
    [_recycledMuiIDItemsDic removeAllObjects];
}

// To acquire an already allocated view that can be reused by reuse identifier.
- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    return [self dequeueReusableItemWithIdentifier:identifier muiID:nil];
}

// To acquire an already allocated view that can be reused by reuse identifier.
// Use muiID for higher priority.
- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier muiID:(NSString *)muiID
{
    UIView *view = nil;
    
    if (self.currentVisibleItemMuiID) {
        NSSet *visibles = _visibleItems;
        for (UIView *v in visibles) {
            if ([v.muiID isEqualToString:self.currentVisibleItemMuiID]) {
                view = v;
                break;
            }
        }
    } else if(muiID && [muiID isKindOfClass:[NSString class]] && muiID.length > 0) {
        // Try to get reusable view from muiID dict.
        view = [self.recycledMuiIDItemsDic tm_safeObjectForKey:muiID class:[UIView class]];
        if (view && view.reuseIdentifier.length > 0 && [view.reuseIdentifier isEqualToString:identifier])
        {
            NSMutableSet *recycledIdentifierSet = [self recycledIdentifierSet:identifier];
            if (muiID && [muiID isKindOfClass:[NSString class]] && muiID.length > 0) {
                [self.recycledMuiIDItemsDic removeObjectForKey:muiID];
            }
            [recycledIdentifierSet removeObject:view];
            view.gestureRecognizers = nil;
        } else {
            view = nil;
        }
    }

    if (nil == view) {
        NSMutableSet *recycledIdentifierSet = [self recycledIdentifierSet:identifier];
        view = [recycledIdentifierSet anyObject];
        if (view && view.reuseIdentifier.length > 0) {
            // If exist reusable view, remove it from recycledSet and recycledMuiIDItemsDic.
            if (view.muiID && [view.muiID isKindOfClass:[NSString class]] && view.muiID.length > 0) {
                [self.recycledMuiIDItemsDic removeObjectForKey:view.muiID];
            }
            [recycledIdentifierSet removeObject:view];
            // Then remove all gesture recognizers of it.
            view.gestureRecognizers = nil;
        } else {
            view = nil;
        }
    }
   
    if ([view conformsToProtocol:@protocol(TMMuiLazyScrollViewCellProtocol)] && [view respondsToSelector:@selector(mui_prepareForReuse)]) {
        [(UIView<TMMuiLazyScrollViewCellProtocol> *)view mui_prepareForReuse];
    }
    return view;
}

//Make sure whether the view is visible accroding to muiID.
- (BOOL)isCellVisible:(NSString *)muiID
{
    BOOL result = NO;
    NSSet *visibles = [_visibleItems copy];
    for (UIView *view in visibles) {
        if ([view.muiID isEqualToString:muiID]) {
            result = YES;
            break;
        }
    }
    return result;
}

- (void)resetViewEnterTimes
{
    [self.enterDict removeAllObjects];
    self.lastVisibleMuiID = nil;
}

@end

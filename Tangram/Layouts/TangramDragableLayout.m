//
//  TangramDragableLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramDragableLayout.h"
#import <VirtualView/UIView+VirtualView.h>
#import "TangramItemModelProtocol.h"
#import "TangramView.h"
@interface TangramDragableLayout ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end
@implementation TangramDragableLayout

@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize itemModels = _itemModels;

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanned:)];
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return _panGestureRecognizer;
}

#pragma mark - overrided methods
- (instancetype)init
{
    if (self = [super init]) {
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
    return self;
}

//- (void)calculateLayout
//{
//    CGFloat width = 0.f,height = 0.f;
//    for (NSObject<TangramItemModelProtocol> *model in self.itemModels) {
//        if ([model respondsToSelector:@selector(marginLeft)]) {
//            [model setItemFrame:CGRectMake(model.itemFrame.origin.x + model.marginLeft, model.itemFrame.origin.y, model.itemFrame.size.width, model.itemFrame.size.height)];
//        }
//        if ([model respondsToSelector:@selector(marginTop)]) {
//            [model setItemFrame:CGRectMake(model.itemFrame.origin.x, model.itemFrame.origin.y + model.marginTop, model.itemFrame.size.width, model.itemFrame.size.height)];
//        }
//        if (CGRectGetMaxX(model.itemFrame) > width) {
//            width = CGRectGetMaxX(model.itemFrame);
//        }
//        if (CGRectGetMaxY(model.itemFrame) > height) {
//            height = CGRectGetMaxY(model.itemFrame);
//        }
//    }
//    self.width = width;
//    self.height = height;
//    [self.superview bringSubviewToFront:self];
//}

#pragma mark - event response
- (void)didPanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    //CGFloat originY = 0.f;
    CGPoint originPoint = self.originPoint;
    CGPoint offset = [gestureRecognizer translationInView:self.superview];
    originPoint.y += offset.y;
    self.originPoint = originPoint;
    gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + offset.x, gestureRecognizer.view.center.y + offset.y);
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self slideToEdge];
    }
}

#pragma mark - animation
- (void)slideToEdge
{
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(wself) sself = wself;
        if (sself) {
            if (sself.superview.vv_centerX < sself.vv_centerX) {
                // 滑向右边贴边
                sself.vv_right = sself.superview.vv_width;
            } else {
                // 滑向左边贴边
                sself.vv_left = 0.f;
            }
            //sself.originPoint = sself.frame.origin;
//            CGFloat topEdge = 0.f;
//            CGFloat bottomEdge = 0.f;
//            if ([sself.superview isKindOfClass:[TangramView class]]) {
//                if ((((TangramView *)(sself.superview)).contentOffset.y + sself.superview.height - topEdge) < sself.vv_bottom) {
//                    sself.vv_bottom = topEdge;
//                }
//                else if (bottomEdge > sself.top) {
//                    sself.top = bottomEdge;
//                }
//            }
           
        }
    }];
    
}
- (TangramLayoutType *)layoutType
{
    return @"tangram_layout_dragable";
}
- (NSString *)position
{
    return @"float";
}
//这个方法的调用时机
//-(void)setAlignType:(DragableAlignType)alignType
//{
//    _alignType = alignType;
//    
//}
@end

//
//  TangramFixLayout.m
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/21.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramFixLayout.h"
#import "TangramItemModelProtocol.h"
//#import "UIViewEX.h"
//#import "NSArrayEX.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
//#import "NSDictionaryEX.h"
//#import "NSStringEX.h"
#import "TangramContext.h"
#import "TangramSafeMethod.h"
#import "TangramEvent.h"

@interface TangramFixLayout()

@property   (nonatomic, strong) NSString        *layoutIdentifier;
@property   (nonatomic, strong) NSString        *bgImgURL;
@property   (nonatomic, strong) UIImageView     *bgImageView;
@property   (nonatomic, strong) UIScrollView    *scrollView;
@property   (nonatomic, assign) CGFloat         layoutHeight;
@property   (nonatomic, assign) BOOL            animating;


@end

@implementation TangramFixLayout

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

- (instancetype)init
{
    if (self = [super init]) {
        self.retainScrollState = YES;
    }
    return self;
}

- (TangramLayoutType *)layoutType
{
    return @"tangram_layout_fix";
}
- (NSString *)identifier
{
    return self.layoutIdentifier;
}
-(void)setIdentifier:(NSString *)identifier
{
    self.layoutIdentifier = identifier;
}
-(UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}
- (UIScrollView *)scrollView
{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled   = YES;
        _scrollView.scrollsToTop    = NO;
        _scrollView.showsHorizontalScrollIndicator  = NO;
        _scrollView.showsVerticalScrollIndicator    = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setTangramBus:(TangramBus *)tangramBus
{
    if (tangramBus != _tangramBus) {
        _tangramBus = tangramBus;
        [self registEvent];
    }
    else{
        _tangramBus = tangramBus;
    }
    
}
- (void)calculateLayout
{
    CGFloat height = 0.f;
    //Fix暂时只会取第一个
    if (self.appearanceType == TangramFixAppearanceScroll) {
        NSObject<TangramItemModelProtocol> *lastModel = nil;
        for (int i = 0; i < self.itemModels.count; i++) {
            NSObject<TangramItemModelProtocol> *model = [self.itemModels tgrm_objectAtIndexCheck:i];
            if ([model respondsToSelector:@selector(marginLeft)]) {
                if (i == 0) {
                    [model setItemFrame:CGRectMake([self.padding tgrm_floatAtIndex:3] + model.marginLeft, model.itemFrame.origin.y ,model.itemFrame.size.width, model.itemFrame.size.height)];
                }
                else{
                    [model setItemFrame:CGRectMake(lastModel.itemFrame.origin.x + lastModel.itemFrame.size.width + model.marginLeft + self.hGap, model.itemFrame.origin.y,model.itemFrame.size.width, model.itemFrame.size.height)];
                }
            }
            if ([model respondsToSelector:@selector(marginTop)]) {
                [model setItemFrame:CGRectMake(model.itemFrame.origin.x, model.itemFrame.origin.y + model.marginTop + [self.padding tgrm_floatAtIndex:0], model.itemFrame.size.width, model.itemFrame.size.height)];
            }
            if ([lastModel respondsToSelector:@selector(marginRight)]) {
                 [model setItemFrame:CGRectMake(model.itemFrame.origin.x + lastModel.marginRight, model.itemFrame.origin.y , model.itemFrame.size.width, model.itemFrame.size.height)];
            }
            if (height < model.itemFrame.size.height) {
                height = model.itemFrame.size.height;
            }
            lastModel = model;
        }
        self.scrollView.frame = CGRectMake(0, 0, self.superview.frame.size.width, height);
        if ([lastModel respondsToSelector:@selector(marginRight)]) {
            self.scrollView.contentSize = CGSizeMake(lastModel.itemFrame.origin.x + lastModel.itemFrame.size.width + lastModel.marginRight + [self.padding tgrm_floatAtIndex:1], height);
        }
        else{
            self.scrollView.contentSize = CGSizeMake(lastModel.itemFrame.origin.x + lastModel.itemFrame.size.width + [self.padding tgrm_floatAtIndex:1], height);
        }
        
        self.width = self.superview.frame.size.width;
    }
    else{
        //保持老逻辑不动
        NSObject<TangramItemModelProtocol> *model = [self.itemModels tgrm_objectAtIndexCheck:0];
        if ([model respondsToSelector:@selector(marginLeft)]) {
            [model setItemFrame:CGRectMake(model.itemFrame.origin.x + model.marginLeft, model.itemFrame.origin.y,CGRectGetWidth(self.frame), model.itemFrame.size.height)];
        }
        if ([model respondsToSelector:@selector(marginTop)]) {
            [model setItemFrame:CGRectMake(model.itemFrame.origin.x, model.itemFrame.origin.y + model.marginTop, CGRectGetWidth(self.frame), model.itemFrame.size.height)];
        }
        if (CGRectGetMaxY(model.itemFrame) > height) {
            height = CGRectGetMaxY(model.itemFrame);
        }
        self.width = model.itemFrame.size.width;
    }
    self.height = height + [self.padding tgrm_floatAtIndex:2];
    self.layoutHeight = self.height;
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.width, self.height);
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
    }
    [self.superview bringSubviewToFront:self];
}

- (void)addSubview:(UIView *)view
{
    if ([view respondsToSelector:@selector(setReuseIdentifier:)] && view != self.scrollView) {
        view.reuseIdentifier = @"";
    }
    if (view && view.reuseIdentifier && self.appearanceType == TangramFixAppearanceScroll && view != self.scrollView) {
        [self.scrollView addSubview:view];
    }
    else {
        [super addSubview:view];
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}
-(NSString *)position
{
    return @"fixed";
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
- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
//    [self calculateLayout];
//    if ([self.superview isKindOfClass:[TangramView class]]) {
//        [((TangramView *)self.superview) heightChanged];
//    }
}
- (void)setBgImgURL:(NSString *)imgURL
{
    _bgImgURL = imgURL;
}
//注册事件
- (void)registEvent
{
    [self.tangramBus registerAction:@"showLayout:" ofExecuter:self onEventTopic:@"TangramFixLayoutShouldShow"];
    [self.tangramBus registerAction:@"hideLayout:" ofExecuter:self onEventTopic:@"TangramFixLayoutShouldHide"];
}

- (void)showLayout:(TangramContext *)context
{
    //必须是这个layout 才做对应的事情
    NSObject *layout = [context.event.params tgrm_objectForKeyCheck:@"layout"];
    if (layout != self) {
        return;
    }
    self.hidden = NO;
    if (!self.retainScrollState && self.appearanceType == TangramFixAppearanceScroll) {
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }
    if (self.animating || self.animationDuration == 0.f) {
        return;
    }
    self.height = 0.f;
    self.animating = YES;
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.layoutHeight, view.frame.size.width, view.frame.size.height);
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.height = self.layoutHeight;
        for (UIView *view in self.subviews) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + self.layoutHeight, view.frame.size.width, view.frame.size.height);
        }
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
}

- (void)hideLayout:(TangramContext *)context
{
    //必须是这个layout 才做对应的事情
    NSObject *layout =  [context.event.params tgrm_objectForKeyCheck:@"layout"];
    if (layout != self) {
        return;
    }
    if (self.animationDuration == 0.f) {
        self.hidden = YES;
        return;
    }
    if (self.animating) {
        return;
    }
    self.animating = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.height = 0.f;
        if (self.enableAlphaEffect) {
            self.alpha = 0.f;
        }
        for (UIView *view in self.subviews) {
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.layoutHeight, view.frame.size.width, view.frame.size.height);
        }
    } completion:^(BOOL finished) {
        for (UIView *view in self.subviews) {
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + self.layoutHeight, view.frame.size.width, view.frame.size.height);
        }
        self.height = self.layoutHeight;
        self.hidden = YES;
        if (self.enableAlphaEffect) {
            self.alpha = 1.f;
        }
        self.animating = NO;
    }];
}



@end

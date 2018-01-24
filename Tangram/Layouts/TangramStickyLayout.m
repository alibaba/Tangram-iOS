//
//  TangramStickyLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramStickyLayout.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import <VirtualView/UIView+VirtualView.h>
#import "TMUtils.h"
#import "TangramEvent.h"

@interface TangramStickyLayout ()

@property   (nonatomic, strong) NSString        *layoutIdentifier;
@property   (nonatomic, strong) NSString        *bgImgURL;
@property   (nonatomic, strong) UIImageView     *bgImageView;
@end
@implementation TangramStickyLayout

@synthesize itemModels  = _itemModels;
- (TangramLayoutType *)layoutType
{
    return @"tangram_layout_sticky";
}
-(UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}
- (void)calculateLayout
{
    CGFloat height = 0.f;
    //吸顶只会取第一个
    NSObject<TangramItemModelProtocol> *model = [self.itemModels tm_safeObjectAtIndex:0];
    if ([model respondsToSelector:@selector(marginLeft)]) {
        [model setItemFrame:CGRectMake(model.itemFrame.origin.x + model.marginLeft, model.itemFrame.origin.y,CGRectGetWidth(self.frame), model.itemFrame.size.height)];
    }
    if ([model respondsToSelector:@selector(marginTop)]) {
        [model setItemFrame:CGRectMake(model.itemFrame.origin.x, model.itemFrame.origin.y + model.marginTop, CGRectGetWidth(self.frame), model.itemFrame.size.height)];
    }
    if (CGRectGetMaxY(model.itemFrame) > height) {
        height = CGRectGetMaxY(model.itemFrame);
    }
    //self.width = width;
    self.vv_height = height;
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.vv_width, self.vv_height);
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
    }
    [self.superview bringSubviewToFront:self];
    //避免吸顶透出更多的东西
    self.clipsToBounds = YES;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.enterFloatStatus == NO) {
        self.originalY = frame.origin.y;
    }
}

-(NSString *)position
{
    return @"sticky";
}
- (NSArray *)margin
{
    if (_margin && 4 == _margin.count) {
        return _margin;
    }
    return @[@0, @0, @0, @0];
}
- (void)setItemModels:(NSArray *)itemModels
{
    _itemModels = itemModels;
}

- (NSArray *)itemModels
{
    return _itemModels;
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

- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
    [self calculateLayout];
    if ([self.superview isKindOfClass:[TangramView class]]) {
        [((TangramView *)self.superview) reloadData];
    }
}
-(NSString *)identifier
{
    return self.layoutIdentifier;
}
- (void)setIdentifier:(NSString *)identifier
{
    self.layoutIdentifier = identifier;
}

- (void)setEnterFloatStatus:(BOOL)enterFloatStatus
{
    if (_enterFloatStatus == NO && enterFloatStatus == YES) {
        TangramEvent *captureImageEvent = [[TangramEvent alloc]initWithTopic:TangramStickyEnterEvent withTangramView:((TangramView *)self.superview) posterIdentifier:nil andPoster:self];
        [self.tangramBus postEvent:captureImageEvent];
    }
    _enterFloatStatus = enterFloatStatus;
}
@end

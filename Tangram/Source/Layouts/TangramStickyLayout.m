//
//  TangramStickyLayout.m
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/23.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramStickyLayout.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import "TangramSafeMethod.h"

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
    //self.width = width;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
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

@end

//
//  TMVVBaseElement.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//
#import "VVTempleteManager.h"
#import "TMVVBaseElement.h"
#import <TMUtils/TMUtils.h>
#import <VirtualView/UIView+VirtualView.h>
#import "TangramEvent.h"
#import "UIView+Tangram.h"
#import <VirtualView/VVViewContainer.h>
#import <LazyScroll/TMLazyItemViewProtocol.h>

static BOOL xmlIsLoad = NO;

@interface TMVVBaseElement ()<VirtualViewDelegate, TMLazyItemViewProtocol>{
    //
}
@property(assign, nonatomic)BOOL    appear;
@end

@implementation TMVVBaseElement

+ (void)initVirtualViewSystem{
    [VVTempleteManager sharedInstance];
}

- (id)init{
    self = [super init];
    if (self) {
        if (xmlIsLoad==NO) {
            [TMVVBaseElement initVirtualViewSystem];
            xmlIsLoad = YES;
        }
    }
    return self;
}

- (CGRect)fitRect:(CGRect)originalFrame
{
    CGFloat left = CGRectGetMinX(originalFrame);
    CGFloat right = CGRectGetMaxX(originalFrame);
    CGFloat top = CGRectGetMinY(originalFrame);
    CGFloat bottom = CGRectGetMaxY(originalFrame);
    left = round(left);
    right = round(right);
    top = round(top);
    bottom = round(bottom);
    return CGRectMake(left, top, right - left, bottom - top);
}

- (void)calculateLayout
{
    ///self.itemModel.type
    self.frame = [self fitRect:self.frame];
    if (self.contentView==nil) {
        self.contentView = [VVViewContainer viewContainerWithTemplateType:self.tangramItemModel.type];
        self.contentView.delegate = self;
        [self addSubview:self.contentView];
    }
    NSUInteger w = self.frame.size.width;
    NSUInteger h = self.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, w, h);
    [self.contentView update:self.tangramItemModel.privateOriginalDict];
}

- (void)virtualViewClickedWithAction:(NSString *)action andValue:(NSString *)value
{
    NSString *actualAction = value;
    if (actualAction.length <= 0) {
        actualAction = [self.tangramItemModel bizValueForKey:action];
    }

    if (self.tangramBus) {
        TangramEvent *event = [[TangramEvent alloc]initWithTopic:TangramEventTopicJumpAction withTangramView:self.inTangramView posterIdentifier:@"singleImage" andPoster:self];
        [event setParam:action forKey:@"action"];
        
        [self.tangramBus postEvent:event];
    }
}


+ (CGFloat)heightByModel:(TangramDefaultItemModel *)itemModel
{
    CGFloat ratio = [[VVTempleteManager sharedInstance]ratioByElementType:itemModel.type];
    if(ratio > 0.f)
    {
        return itemModel.itemFrame.size.width / ratio;
    }
    return [[VVTempleteManager sharedInstance]heightByElementType:itemModel.type];
}

+ (NSString *)reuseIdByModel:(TangramDefaultItemModel *)itemModel
{
    NSString *version = [[VVTempleteManager sharedInstance]localVersionByElementType:itemModel.type];
    return [NSString stringWithFormat:@"%@_%@",itemModel.type,version];
}

-(void)mui_afterGetView
{
    [self calculateLayout];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  TangramPageScrollLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TangramLayoutProtocol.h"
#import "TangramBus.h"
@interface TangramPageScrollLayout : UIView<TangramLayoutProtocol>
typedef NS_ENUM(NSUInteger,IndicatorGravityType)
{
    IndicatorGravityCenter = 0,
    IndicatorGravityLeft,
    IndicatorGravityRight
};
typedef NS_ENUM(NSUInteger,IndicatorPositionType)
{
    
    IndicatorPositionOutside = 0,
    IndicatorPositionInside ,
};

typedef NS_ENUM(NSUInteger,IndicatorStyleType)
{
    IndicatorStyleDot = 0,
    IndicatorStyleStripe ,
};

@property (nonatomic, strong) NSString              *indicatorImg1;
@property (nonatomic, strong) NSString              *indicatorImg2;


@property (nonatomic, assign) CGFloat               indicatorGap;
// Models Array , as protocol request.
@property (nonatomic, strong) NSArray               *itemModels;
// Margin , the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property (nonatomic, strong) NSArray               *margin;
// Padding ,  the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property (nonatomic, strong) NSArray               *padding;
// Aspect ratio of the whole layout
@property (nonatomic, strong) NSString              *aspectRatio;
// Indicator position in horizontal
@property (nonatomic, assign) IndicatorGravityType  indicatorGravity;
// Indicator position in vertical
@property (nonatomic, assign) IndicatorPositionType indicatorPosition;
// Auto scroll time.
@property (nonatomic, assign) NSTimeInterval         autoScrollTime;
// Has more Jump Action
@property (nonatomic, strong) NSString              *hasMoreAction;
// TangramBus
@property (nonatomic, weak)   TangramBus            *tangramBus;
// Gap in horizontal direction
@property (nonatomic, assign) CGFloat               hGap;
// Whether infinite loop. Only
@property  (nonatomic, assign) BOOL                infiniteLoop;
// Load More ImageUrl
@property   (nonatomic, strong) NSString            *loadMoreImgUrl;
// Indicator style type
@property   (nonatomic, assign) IndicatorStyleType indicatorStyleType;
// Page Height for every element.
@property   (nonatomic, assign) CGFloat             pageHeight;
// Page Height for every element. If `pageWidth` is 0, This pageScroll will scroll by page(pagingEnabled = YES).
@property   (nonatomic, assign) CGFloat             pageWidth;
// Whether need Indicator
@property   (nonatomic, assign) BOOL                hasIndicator;
// Whether indicator need auto hide.
@property   (nonatomic, assign) BOOL                indicatorAutoHide;

@property   (nonatomic, assign) CGFloat             indicatorRadius;
@property   (nonatomic, assign) CGFloat             indicatorHeight;
@property   (nonatomic, assign) CGFloat             indicatorWidth;
@property   (nonatomic, strong) NSString            *indicatorColor;
@property   (nonatomic, strong) NSString            *defaultIndicatorColor;
@property   (nonatomic, assign) CGFloat             indicatorMargin;
@property   (nonatomic, assign) CGFloat             scrollMarginLeft;
@property   (nonatomic, assign) CGFloat             scrollMarginRight;
// Margin for every page, the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property   (nonatomic, strong) NSArray             *pageMargin;
@property   (nonatomic, strong) NSString            *layoutLoadAPI;

@property   (nonatomic, strong) NSString            *bgImgURL;

@property   (nonatomic, assign) CGFloat             zIndex;

//启用margin去重，留个坑，滚动布局暂时不做处理
//@property   (nonatomic, assign) BOOL enableMarginDeduplication;

@end

@protocol TangramPageScrollLayoutDelegate <NSObject>
//当滑动到某一页的时候会调用
-(void)layout:(TangramPageScrollLayout *)layout atIndex:(NSUInteger)index;


@end

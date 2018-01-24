//
//  TangramLayoutParseHelper.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//  快捷解析器

#import "TangramLayoutParseHelper.h"
#import "TangramFlowLayout.h"
#import "TangramFixLayout.h"
#import "TangramStickyLayout.h"
#import "TangramWaterFlowLayout.h"
#import "TangramPageScrollLayout.h"
#import "TangramSingleAndDoubleLayout.h"
#import "TangramScrollFlowLayout.h"
#import "TangramScrollWaterFlowLayout.h"
#import "TMUtils.h"
#import "NSString+Tangram.h"

#define SCREEN_SIZE         [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH        SCREEN_SIZE.width
#define SCREEN_HEIGHT       SCREEN_SIZE.height

@implementation TangramLayoutParseHelper

+ (UIView<TangramLayoutProtocol> *)layoutConfigByOriginLayout:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict
{
    if ([layout isKindOfClass:[TangramFlowLayout class]]) {
        layout = [TangramLayoutParseHelper praseFlowLayout:(TangramFlowLayout *)layout withDict:dict];
    }
    else if([layout isKindOfClass:[TangramPageScrollLayout class]])
    {
        layout = [TangramLayoutParseHelper prasePageScrollLayout:(TangramPageScrollLayout *)layout withDict:dict];
    }
    else if([layout isKindOfClass:[TangramWaterFlowLayout class]])
    {
        layout = [TangramLayoutParseHelper praseWaterFlowLayout:(TangramWaterFlowLayout *)layout  withDict:dict];
    }
    else if([layout isKindOfClass:[TangramFixLayout class]])
    {
        layout = [TangramLayoutParseHelper praseFixLayout:(TangramFixLayout *)layout withDict:dict];
    }
    else if([layout isKindOfClass:[TangramStickyLayout class]])
    {
        layout = [TangramLayoutParseHelper praseStickyLayout:(TangramStickyLayout *)layout withDict:dict];
    }
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseFlowLayout:(TangramFlowLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    layout.cols = [styleDict tm_arrayForKey:@"cols"];
    NSArray *margin = [styleDict tm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    layout.padding = [styleDict tm_arrayForKey:@"padding"];
    if ((nil == layout.padding || 4 != [layout.padding count]) && [styleDict tm_stringForKey:@"padding"].length > 0) {
        NSString *originalPaddingString = [styleDict tm_stringForKey:@"padding"];
        NSMutableArray *mutablePaddingArray = [[NSMutableArray alloc]initWithCapacity:4];
        originalPaddingString = [[originalPaddingString trim] substringWithRange:NSMakeRange(1, originalPaddingString.length - 2)];
        NSArray *pArray = [originalPaddingString componentsSeparatedByString:@","];
        for (NSUInteger i = 0 ; i < pArray.count ; i++) {
            if (i == 4) {
                break;
            }
            id onePadding = [pArray tm_safeObjectAtIndex:i];
            NSNumber *onePaddingNumber = nil;
            if ([onePadding isKindOfClass:[NSString class]]) {
                onePaddingNumber =[NSNumber numberWithFloat:[[onePadding trim] floatValue]];
            }
            else if ([onePadding isKindOfClass:[NSNumber class]]) {
                onePaddingNumber = onePadding;
            }
            [mutablePaddingArray tm_safeAddObject:onePaddingNumber];
        }
        if (mutablePaddingArray.count == 4) {
            layout.padding = [mutablePaddingArray copy];
        }
    }
    layout.aspectRatio = [styleDict tm_stringForKey:@"aspectRatio"];
    layout.vGap = [styleDict tm_floatForKey:@"vGap"];
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    layout.autoFill = [styleDict tm_boolForKey:@"autoFill"];
    layout.layoutLoadAPI = [dict tm_stringForKey:@"load"];
    layout.loadType = [dict tm_integerForKey:@"loadType"];
    layout.loadParams = [dict tm_dictionaryForKey:@"loadParams"];
    layout.zIndex = [styleDict tm_floatForKey:@"zIndex"];
    layout.enableInnerZIndexLayout = [styleDict tm_boolForKey:@"enableInnerZIndexLayout"];
    if ([[styleDict tm_stringForKey:@"bgScaleType"] isEqualToString:@"fitStart"]) {
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitStart;
    }
    else{
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitXY;
    }
    if ([layout isKindOfClass:[TangramSingleAndDoubleLayout class]]) {
        ((TangramSingleAndDoubleLayout *)layout).rows = [styleDict tm_arrayForKey:@"rows"];
    }
    if ([styleDict tm_integerForKey:@"column"] > 0) {
        layout.numberOfColumns = [styleDict tm_integerForKey:@"column"];
    }
    if ([layout isKindOfClass:[TangramScrollFlowLayout class]]) {
        if (((TangramScrollFlowLayout *)layout).pagingLength != [styleDict tm_integerForKey:@"pageCount"]) {
            ((TangramScrollFlowLayout *)layout).pagingLength = [styleDict tm_integerForKey:@"pageCount"];
        }
        ((TangramScrollFlowLayout *)layout).bgColors = [styleDict tm_arrayForKey:@"bgColors"];
        ((TangramScrollFlowLayout *)layout).disableScroll = YES;
        //((TangramScrollFlowLayout *)layout).pagingIndex = 0;
        //原本的Tab布局，或者style里面配置了slideable，意味着可以滚动
        if ([styleDict tm_boolForKey:@"slidable"] || [dict tm_boolForKey:@"canHorizontalScroll"]) {
            ((TangramScrollFlowLayout *)layout).disableScroll = NO;
        }
    }
    if ([styleDict tm_boolForKey:@"disableClick"] == YES) {
        ((TangramFlowLayout *)layout).disableUserInteraction = YES;
    }
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)prasePageScrollLayout:(TangramPageScrollLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSArray *margin = [styleDict tm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    layout.padding = [styleDict tm_arrayForKey:@"padding"];
    if ((nil == layout.padding || 4 != [layout.padding count]) && [styleDict tm_stringForKey:@"padding"].length > 0) {
        NSString *originalPaddingString = [styleDict tm_stringForKey:@"padding"];
        NSMutableArray *mutablePaddingArray = [[NSMutableArray alloc]initWithCapacity:4];
        originalPaddingString = [[originalPaddingString trim] substringWithRange:NSMakeRange(1, originalPaddingString.length - 2)];
        NSArray *pArray = [originalPaddingString componentsSeparatedByString:@","];
        for (NSUInteger i = 0 ; i < pArray.count ; i++) {
            if (i == 4) {
                break;
            }
            id onePadding = [pArray tm_safeObjectAtIndex:i];
            NSNumber *onePaddingNumber = nil;
            if ([onePadding isKindOfClass:[NSString class]]) {
                onePaddingNumber =[NSNumber numberWithFloat:[[onePadding trim] floatValue]];
            }
            else if ([onePadding isKindOfClass:[NSNumber class]]) {
                onePaddingNumber = onePadding;
            }
            [mutablePaddingArray tm_safeAddObject:onePaddingNumber];
        }
        if (mutablePaddingArray.count == 4) {
            layout.padding = [mutablePaddingArray copy];
        }
    }
    
    layout.aspectRatio = [styleDict tm_stringForKey:@"aspectRatio"];
    layout.indicatorGap = [styleDict tm_floatForKey:@"indicatorGap"];
    layout.indicatorImg1 = [styleDict tm_stringForKey:@"indicatorImg1"];
    layout.indicatorImg2 = [styleDict tm_stringForKey:@"indicatorImg2"];
    layout.autoScrollTime = [styleDict tm_floatForKey:@"autoScroll"]/1000.0;
    layout.layoutLoadAPI = [dict tm_stringForKey:@"load"];
    layout.zIndex = [styleDict tm_floatForKey:@"zIndex"];
    if ([styleDict tm_stringForKey:@"infiniteMinCount"].length > 0) {
        layout.infiniteLoop = YES;
    }
    if ([[styleDict tm_stringForKey:@"indicatorPosition"] isEqualToString:@"inside"]) {
        layout.indicatorPosition = IndicatorPositionInside;
    }
    else  {
        layout.indicatorPosition = IndicatorPositionOutside;
    }
    if ([[styleDict tm_stringForKey:@"indicatorGravity"] isEqualToString:@"left"]) {
        layout.indicatorGravity = IndicatorGravityLeft;
    }
    else if ([[styleDict tm_stringForKey:@"indicatorGravity"] isEqualToString:@"right"])
    {
        layout.indicatorGravity = IndicatorGravityRight;
    }
    else{
        layout.indicatorGravity = IndicatorGravityCenter;
    }
    layout.loadMoreImgUrl = [styleDict tm_stringForKey:@"loadMoreImgUrl"];
    if ([[styleDict tm_stringForKey:@"indicatorStyle"] isEqualToString:@"stripe"]) {
        layout.indicatorStyleType = IndicatorStyleStripe;
    }
    else{
        layout.indicatorStyleType = IndicatorStyleDot;
    }
    layout.hasMoreAction = [styleDict tm_stringForKey:@"hasMoreAction"];
    layout.pageMargin = [styleDict tm_arrayForKey:@"pageMargin"];
    layout.pageWidth = SCREEN_WIDTH * [styleDict tm_floatForKey:@"pageRatio"];
    BOOL disableScale = [styleDict tm_boolForKey:@"disableScale"];
    CGFloat pageWidthInConfig = [styleDict tm_floatForKey:@"pageWidth"];
    if (pageWidthInConfig > 0.f) {
        if (disableScale) {
            layout.pageWidth = pageWidthInConfig;
        }
        else{
            layout.pageWidth = pageWidthInConfig/375.f*SCREEN_WIDTH;
        }
    }
    CGFloat pageHeightInConfig = [styleDict tm_floatForKey:@"pageHeight"];
    if (disableScale) {
        layout.pageHeight = pageHeightInConfig;
    }
    else{
        layout.pageHeight = pageHeightInConfig/375.f*SCREEN_WIDTH;
    }
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    if ([[styleDict tm_stringForKey:@"hasIndicator"] isEqualToString:@"false"]) {
        layout.hasIndicator = NO;
    }
    else{
        layout.hasIndicator = YES;
    }
    layout.indicatorAutoHide = [styleDict tm_boolForKey:@"indicatorAutoHide"];
    layout.indicatorColor = [styleDict tm_stringForKey:@"indicatorColor"];
    layout.defaultIndicatorColor = [styleDict tm_stringForKey:@"defaultIndicatorColor"];
    layout.indicatorRadius = [styleDict tm_floatForKey:@"indicatorRadius"];
    layout.indicatorMargin = [styleDict tm_floatForKey:@"indicatorMargin"];
    //height 和 width 仅会应用在dot类型
    layout.indicatorHeight = [styleDict tm_floatForKey:@"indicatorHeight"];
    if (layout.indicatorHeight > 0) {
        // 需要根据layout.indicatorImg1图片宽高比计算，这里默认先乘以3
        layout.indicatorWidth = layout.indicatorHeight * 3;
    }
    if (layout.indicatorMargin == 0.f) {
        layout.indicatorMargin = 3.f;
    }
    layout.scrollMarginLeft = [styleDict tm_floatForKey:@"scrollMarginLeft"];
    layout.scrollMarginRight = [styleDict tm_floatForKey:@"scrollMarginRight"];
    
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseFixLayout:(TangramFixLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSString *alignInStyle = [styleDict tm_stringForKey:@"align"];
    if ([alignInStyle isEqualToString:@"top_left"]) {
        layout.alignType = TopLeft;
    }
    else if ([alignInStyle isEqualToString:@"top_right"]) {
        layout.alignType = TopRight;
    }
    else if ([alignInStyle isEqualToString:@"bottom_left"]) {
        layout.alignType = BottomLeft;
    }
    else if ([alignInStyle isEqualToString:@"bottom_right"]) {
        layout.alignType = BottomRight;
    }
    layout.offsetX = [styleDict tm_floatForKey:@"x"];
    layout.offsetY = [styleDict tm_floatForKey:@"y"];
    NSString *showTypeInStyle = [styleDict tm_stringForKey:@"showType"];
    if ([showTypeInStyle isEqualToString:@"showOnEnter"]) {
        layout.showType = FixLayoutShowOnEnter;
    }
    else if([showTypeInStyle isEqualToString:@"showOnLeave"])
    {
        layout.showType = FixLayoutShowOnLeave;
    }
    if ([[styleDict tm_stringForKey:@"appearanceType"] isEqualToString:@"scroll"]) {
        layout.appearanceType = TangramFixAppearanceScroll;
    }
    else{
        layout.appearanceType = TangramFixAppearanceInline;
    }
    layout.enableAlphaEffect = [styleDict tm_boolForKey:@"enableAlphaEffect"];
    layout.animationDuration = [styleDict tm_floatForKey:@"animationDuration"]/1000.f;
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    layout.padding = [styleDict tm_arrayForKey:@"padding"];
    id tmpValue = [styleDict tm_safeObjectForKey:@"retainScrollState"];
    if (tmpValue && ([tmpValue isKindOfClass:[NSNumber class]] || [tmpValue isKindOfClass:[NSString class]])) {
        layout.retainScrollState = [tmpValue boolValue];
    } else {
        layout.retainScrollState = YES;
    }
    layout.zIndex = [styleDict tm_floatForKey:@"zIndex"];
    if ((nil == layout.padding || 4 != [layout.padding count]) && [styleDict tm_stringForKey:@"padding"].length > 0) {
        NSString *originalPaddingString = [styleDict tm_stringForKey:@"padding"];
        NSMutableArray *mutablePaddingArray = [[NSMutableArray alloc]initWithCapacity:4];
        originalPaddingString = [[originalPaddingString trim] substringWithRange:NSMakeRange(1, originalPaddingString.length - 2)];
        NSArray *pArray = [originalPaddingString componentsSeparatedByString:@","];
        for (NSUInteger i = 0 ; i < pArray.count ; i++) {
            if (i == 4) {
                break;
            }
            id onePadding = [pArray tm_safeObjectAtIndex:i];
            NSNumber *onePaddingNumber = nil;
            if ([onePadding isKindOfClass:[NSString class]]) {
                onePaddingNumber =[NSNumber numberWithFloat:[[onePadding trim] floatValue]];
            }
            else if ([onePadding isKindOfClass:[NSNumber class]]) {
                onePaddingNumber = onePadding;
            }
            [mutablePaddingArray tm_safeAddObject:onePaddingNumber];
        }
        if (mutablePaddingArray.count == 4) {
            layout.padding = [mutablePaddingArray copy];
        }
    }
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseStickyLayout:(TangramStickyLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSArray *margin = [styleDict tm_arrayForKey:@"margin"];
    layout.zIndex = [styleDict tm_floatForKey:@"zIndex"];
    NSString *originMarginString = [styleDict tm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    NSString *stickyStatus = [styleDict tm_stringForKey:@"sticky"];
    if ([stickyStatus isEqualToString:@"end"]) {
        layout.stickyBottom = YES;
    }
    else{
        layout.stickyBottom = NO;
    }
    layout.extraOffset = [styleDict tm_floatForKey:@"offset"];
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseWaterFlowLayout:(TangramWaterFlowLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    layout.vGap = [styleDict tm_floatForKey:@"vGap"];
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    layout.layoutLoadAPI = [dict tm_stringForKey:@"load"];
    layout.loadType = [dict tm_integerForKey:@"loadType"];
    layout.zIndex = [styleDict tm_floatForKey:@"zIndex"];
    NSArray *margin = [styleDict tm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    //padding支持，以后抽出解析margin和padding的代码，很多地方会用到
    layout.padding = [styleDict tm_arrayForKey:@"padding"];
    if ((nil == layout.padding || 4 != [layout.padding count]) && [styleDict tm_stringForKey:@"padding"].length > 0) {
        NSString *originalPaddingString = [styleDict tm_stringForKey:@"padding"];
        NSMutableArray *mutablePaddingArray = [[NSMutableArray alloc]initWithCapacity:4];
        originalPaddingString = [[originalPaddingString trim] substringWithRange:NSMakeRange(1, originalPaddingString.length - 2)];
        NSArray *pArray = [originalPaddingString componentsSeparatedByString:@","];
        for (NSUInteger i = 0 ; i < pArray.count ; i++) {
            if (i == 4) {
                break;
            }
            id onePadding = [pArray tm_safeObjectAtIndex:i];
            NSNumber *onePaddingNumber = nil;
            if ([onePadding isKindOfClass:[NSString class]]) {
                onePaddingNumber =[NSNumber numberWithFloat:[[onePadding trim] floatValue]];
            }
            else if ([onePadding isKindOfClass:[NSNumber class]]) {
                onePaddingNumber = onePadding;
            }
            [mutablePaddingArray tm_safeAddObject:onePaddingNumber];
        }
        if (mutablePaddingArray.count == 4) {
            layout.padding = [mutablePaddingArray copy];
        }
    }
    if ([layout isKindOfClass:[TangramScrollWaterFlowLayout class]]) {
        ((TangramScrollWaterFlowLayout *)layout).pagingLength = [styleDict tm_integerForKey:@"pageCount"];
        ((TangramScrollWaterFlowLayout *)layout).disableScroll = YES;
        //原本的Tab布局，或者style里面配置了slideable，意味着可以滚动
        if ([styleDict tm_boolForKey:@"slidable"] || [dict tm_boolForKey:@"canHorizontalScroll"]) {
            ((TangramScrollWaterFlowLayout *)layout).disableScroll = NO;
        }
    }
    return layout;
}
@end

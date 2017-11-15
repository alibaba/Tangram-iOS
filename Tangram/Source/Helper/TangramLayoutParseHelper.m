//
//  TangramLayoutParseHelper.m
//  Pods
//
//  Created by xiaoxia on 2017/1/3.
//
//
//  快捷解析器
#import "TangramLayoutParseHelper.h"
#import "TangramFlowLayout.h"
#import "TangramFixLayout.h"
#import "TangramStickyLayout.h"
#import "TangramWaterFlowLayout.h"
#import "TangramPageScrollLayout.h"
#import "TangramSingleAndDoubleLayout.h"
#import "TMUtils.h"
//#import "TMImageView.h"

@implementation TangramLayoutParseHelper

+ (UIView<TangramLayoutProtocol> *)layoutConfigByOriginLayout:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict
{
    //对于所有layout都适用的属性，不用放在plist的style中明确写出
    //已知的一定会加载的属性有：id,bgColor,bgImgURL
    layout.identifier = [dict tm_stringForKey:@"id"];
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSString *backgroundColor = [styleDict tm_stringForKey:@"bgColor"];
    if (backgroundColor.length > 0) {
        layout.backgroundColor = [TangramLayoutParseHelper colorFromHexString:backgroundColor];
    }
    NSString *bgImgURL = [styleDict tm_stringForKey:@"bgImgUrl"];
    if (bgImgURL.length > 0 && [layout respondsToSelector:@selector(setBgImgURL:)]) {
        layout.bgImgURL = bgImgURL;
    }
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
    NSArray *padding = [styleDict tm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    layout.aspectRatio = [styleDict tm_stringForKey:@"aspectRatio"];
    layout.vGap = [styleDict tm_floatForKey:@"vGap"];
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    layout.autoFill = [styleDict tm_boolForKey:@"autoFill"];
    layout.layoutLoadAPI = [dict tm_stringForKey:@"load"];
    layout.loadType = [dict tm_integerForKey:@"loadType"];
    layout.loadParams = [dict tm_dictionaryForKey:@"loadParams"];
    if ([[styleDict tm_stringForKey:@"bgScaleType"] isEqualToString:@"fitStart"]) {
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitStart;
    }
    else{
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitXY;
    }
    if ([layout isKindOfClass:[TangramSingleAndDoubleLayout class]]) {
        ((TangramSingleAndDoubleLayout *)layout).rows = [styleDict tm_arrayForKey:@"rows"];
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
    NSArray *padding = [styleDict tm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    layout.aspectRatio = [styleDict tm_stringForKey:@"aspectRatio"];
    layout.indicatorGap = [styleDict tm_floatForKey:@"indicatorGap"];
    layout.indicatorImg1 = [styleDict tm_stringForKey:@"indicatorImg1"];
    layout.indicatorImg2 = [styleDict tm_stringForKey:@"indicatorImg2"];
    layout.autoScrollTime = [styleDict tm_floatForKey:@"autoScroll"]/1000.0;
    layout.layoutLoadAPI = [dict tm_stringForKey:@"load"];
    if ([styleDict tm_stringForKey:@"infinite"].length > 0) {
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
    layout.pageWidth = [UIScreen mainScreen].bounds.size.width * [styleDict tm_floatForKey:@"pageRatio"];
    BOOL disableScale = [styleDict tm_boolForKey:@"disableScale"];
    CGFloat pageWidthInConfig = [styleDict tm_floatForKey:@"pageWidth"];
    if (pageWidthInConfig > 0.f) {
        if (disableScale) {
            layout.pageWidth = pageWidthInConfig;
        }
        else{
            layout.pageWidth = pageWidthInConfig/375.f*[UIScreen mainScreen].bounds.size.width;
        }
    }
    CGFloat pageHeightInConfig = [styleDict tm_floatForKey:@"pageHeight"];
    if (disableScale) {
        layout.pageHeight = pageHeightInConfig;
    }
    else{
        layout.pageHeight = pageHeightInConfig/375.f*[UIScreen mainScreen].bounds.size.width;
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
    layout.animationDuration = [styleDict tm_floatForKey:@"animationDuration"]/1000.f;
    layout.hGap = [styleDict tm_floatForKey:@"hGap"];
    NSArray *padding = [styleDict tm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    id tmpValue = [styleDict tm_safeObjectForKey:@"retainScrollState"];
    if (tmpValue && ([tmpValue isKindOfClass:[NSNumber class]] || [tmpValue isKindOfClass:[NSString class]])) {
        layout.retainScrollState = [tmpValue boolValue];
    } else {
        layout.retainScrollState = YES;
    }
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseStickyLayout:(TangramStickyLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSArray *margin = [styleDict tm_arrayForKey:@"margin"];
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
    return layout;
}

//仅支持#FFFFFF (井号 + 6位 RGB颜色)
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


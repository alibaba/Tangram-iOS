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
#import "TangramSafeMethod.h"
//#import "TMImageView.h"

@implementation TangramLayoutParseHelper

+ (UIView<TangramLayoutProtocol> *)layoutConfigByOriginLayout:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict
{
    //对于所有layout都适用的属性，不用放在plist的style中明确写出
    //已知的一定会加载的属性有：id,bgColor,bgImgURL
    layout.identifier = [dict tgrm_stringForKey:@"id"];
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    NSString *backgroundColor = [styleDict tgrm_stringForKey:@"bgColor"];
    if (backgroundColor.length > 0) {
        layout.backgroundColor = [TangramLayoutParseHelper colorFromHexString:backgroundColor];
    }
    NSString *bgImgURL = [styleDict tgrm_stringForKey:@"bgImgUrl"];
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
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    layout.cols = [styleDict tgrm_arrayForKey:@"cols"];
    NSArray *margin = [styleDict tgrm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tgrm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    NSArray *padding = [styleDict tgrm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tgrm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    layout.aspectRatio = [styleDict tgrm_stringForKey:@"aspectRatio"];
    layout.vGap = [styleDict tgrm_floatForKey:@"vGap"];
    layout.hGap = [styleDict tgrm_floatForKey:@"hGap"];
    layout.autoFill = [styleDict tgrm_boolForKey:@"autoFill"];
    layout.layoutLoadAPI = [dict tgrm_stringForKey:@"load"];
    layout.loadType = [dict tgrm_integerForKey:@"loadType"];
    layout.loadParams = [dict tgrm_dictionaryForKey:@"loadParams"];
    if ([[styleDict tgrm_stringForKey:@"bgScaleType"] isEqualToString:@"fitStart"]) {
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitStart;
    }
    else{
        layout.bgScaleType = TangramFlowLayoutBgImageScaleTypeFitXY;
    }
    if ([layout isKindOfClass:[TangramSingleAndDoubleLayout class]]) {
        ((TangramSingleAndDoubleLayout *)layout).rows = [styleDict tgrm_arrayForKey:@"rows"];
    }
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)prasePageScrollLayout:(TangramPageScrollLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    NSArray *margin = [styleDict tgrm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tgrm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    NSArray *padding = [styleDict tgrm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tgrm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    layout.aspectRatio = [styleDict tgrm_stringForKey:@"aspectRatio"];
    layout.indicatorGap = [styleDict tgrm_floatForKey:@"indicatorGap"];
    layout.indicatorImg1 = [styleDict tgrm_stringForKey:@"indicatorImg1"];
    layout.indicatorImg2 = [styleDict tgrm_stringForKey:@"indicatorImg2"];
    layout.autoScrollTime = [styleDict tgrm_floatForKey:@"autoScroll"]/1000.0;
    layout.layoutLoadAPI = [dict tgrm_stringForKey:@"load"];
    if ([styleDict tgrm_stringForKey:@"infiniteMinCount"].length > 0) {
        layout.infiniteLoop = YES;
    }
    if ([[styleDict tgrm_stringForKey:@"indicatorPosition"] isEqualToString:@"inside"]) {
        layout.indicatorPosition = IndicatorPositionInside;
    }
    else  {
        layout.indicatorPosition = IndicatorPositionOutside;
    }
    if ([[styleDict tgrm_stringForKey:@"indicatorGravity"] isEqualToString:@"left"]) {
        layout.indicatorGravity = IndicatorGravityLeft;
    }
    else if ([[styleDict tgrm_stringForKey:@"indicatorGravity"] isEqualToString:@"right"])
    {
        layout.indicatorGravity = IndicatorGravityRight;
    }
    else{
        layout.indicatorGravity = IndicatorGravityCenter;
    }
    layout.loadMoreImgUrl = [styleDict tgrm_stringForKey:@"loadMoreImgUrl"];
    if ([[styleDict tgrm_stringForKey:@"indicatorStyle"] isEqualToString:@"stripe"]) {
        layout.indicatorStyleType = IndicatorStyleStripe;
    }
    else{
        layout.indicatorStyleType = IndicatorStyleDot;
    }
    layout.hasMoreAction = [styleDict tgrm_stringForKey:@"hasMoreAction"];
    layout.pageMargin = [styleDict tgrm_arrayForKey:@"pageMargin"];
    layout.pageWidth = [UIScreen mainScreen].bounds.size.width * [styleDict tgrm_floatForKey:@"pageRatio"];
    BOOL disableScale = [styleDict tgrm_boolForKey:@"disableScale"];
    CGFloat pageWidthInConfig = [styleDict tgrm_floatForKey:@"pageWidth"];
    if (pageWidthInConfig > 0.f) {
        if (disableScale) {
            layout.pageWidth = pageWidthInConfig;
        }
        else{
            layout.pageWidth = pageWidthInConfig/375.f*[UIScreen mainScreen].bounds.size.width;
        }
    }
    CGFloat pageHeightInConfig = [styleDict tgrm_floatForKey:@"pageHeight"];
    if (disableScale) {
        layout.pageHeight = pageHeightInConfig;
    }
    else{
        layout.pageHeight = pageHeightInConfig/375.f*[UIScreen mainScreen].bounds.size.width;
    }
    layout.hGap = [styleDict tgrm_floatForKey:@"hGap"];
    if ([[styleDict tgrm_stringForKey:@"hasIndicator"] isEqualToString:@"false"]) {
        layout.hasIndicator = NO;
    }
    else{
        layout.hasIndicator = YES;
    }
    layout.indicatorAutoHide = [styleDict tgrm_boolForKey:@"indicatorAutoHide"];
    layout.indicatorColor = [styleDict tgrm_stringForKey:@"indicatorColor"];
    layout.defaultIndicatorColor = [styleDict tgrm_stringForKey:@"defaultIndicatorColor"];
    layout.indicatorRadius = [styleDict tgrm_floatForKey:@"indicatorRadius"];
    layout.indicatorMargin = [styleDict tgrm_floatForKey:@"indicatorMargin"];
    if (layout.indicatorMargin == 0.f) {
        layout.indicatorMargin = 3.f;
    }
    layout.scrollMarginLeft = [styleDict tgrm_floatForKey:@"scrollMarginLeft"];
    layout.scrollMarginRight = [styleDict tgrm_floatForKey:@"scrollMarginRight"];
    
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseFixLayout:(TangramFixLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    NSString *alignInStyle = [styleDict tgrm_stringForKey:@"align"];
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
    layout.offsetX = [styleDict tgrm_floatForKey:@"x"];
    layout.offsetY = [styleDict tgrm_floatForKey:@"y"];
    NSString *showTypeInStyle = [styleDict tgrm_stringForKey:@"showType"];
    if ([showTypeInStyle isEqualToString:@"showOnEnter"]) {
        layout.showType = FixLayoutShowOnEnter;
    }
    else if([showTypeInStyle isEqualToString:@"showOnLeave"])
    {
        layout.showType = FixLayoutShowOnLeave;
    }
    if ([[styleDict tgrm_stringForKey:@"appearanceType"] isEqualToString:@"scroll"]) {
        layout.appearanceType = TangramFixAppearanceScroll;
    }
    else{
        layout.appearanceType = TangramFixAppearanceInline;
    }
    layout.animationDuration = [styleDict tgrm_floatForKey:@"animationDuration" defaultValue:0.f]/1000.f;
    layout.hGap = [styleDict tgrm_floatForKey:@"hGap" defaultValue:0.f];
    NSArray *padding = [styleDict tgrm_arrayForKey:@"padding"];
    layout.padding = padding;
    NSString *originPaddingString = [styleDict tgrm_stringForKey:@"padding"];
    if (padding.count  != 4 && originPaddingString.length > 3) {
        NSString *splitString = [originPaddingString substringWithRange:NSMakeRange(1, originPaddingString.length-2)];
        NSArray *splitPaddingArray = [splitString componentsSeparatedByString:@","];
        if (splitPaddingArray.count == 4) {
            layout.padding = splitPaddingArray;
        }
    }
    layout.retainScrollState = [styleDict tgrm_boolForKey:@"retainScrollState" defaultValue:YES];
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseStickyLayout:(TangramStickyLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    NSArray *margin = [styleDict tgrm_arrayForKey:@"margin"];
    NSString *originMarginString = [styleDict tgrm_stringForKey:@"margin"];
    if (margin.count  != 4 && originMarginString.length > 3) {
        NSString *splitString = [originMarginString substringWithRange:NSMakeRange(1, originMarginString.length-2)];
        NSArray *splitMarginArray = [splitString componentsSeparatedByString:@","];
        if (splitMarginArray.count == 4) {
            layout.margin = splitMarginArray;
        }
    }
    NSString *stickyStatus = [styleDict tgrm_stringForKey:@"sticky"];
    if ([stickyStatus isEqualToString:@"end"]) {
        layout.stickyBottom = YES;
    }
    else{
        layout.stickyBottom = NO;
    }
    layout.extraOffset = [styleDict tgrm_floatForKey:@"offset"];
    return layout;
}

+ (UIView<TangramLayoutProtocol> *)praseWaterFlowLayout:(TangramWaterFlowLayout *)layout withDict:(NSDictionary *)dict
{
    NSDictionary *styleDict = [dict tgrm_dictionaryForKey:@"style"];
    layout.vGap = [styleDict tgrm_floatForKey:@"vGap"];
    layout.hGap = [styleDict tgrm_floatForKey:@"hGap"];
    layout.layoutLoadAPI = [dict tgrm_stringForKey:@"load"];
    layout.loadType = [dict tgrm_integerForKey:@"loadType"];
    NSArray *margin = [styleDict tgrm_arrayForKey:@"margin"];
    layout.margin = margin;
    NSString *originMarginString = [styleDict tgrm_stringForKey:@"margin"];
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


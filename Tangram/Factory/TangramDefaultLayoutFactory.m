//
//  TangramDefaultLayoutFactory.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramDefaultLayoutFactory.h"
#import "TMUtils.h"
#import "TangramScrollFlowLayout.h"
#import "TangramLayoutParseHelper.h"
#import <VirtualView/UIColor+VirtualView.h>

@interface TangramDefaultLayoutFactory()
//Key : type(String) , Value: layout class name(String)
@property (nonatomic, strong) NSMutableDictionary *layoutTypeMap;

@end

@implementation TangramDefaultLayoutFactory

+ (TangramDefaultLayoutFactory*)sharedInstance
{
    static TangramDefaultLayoutFactory *_layoutFactory = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _layoutFactory = [[TangramDefaultLayoutFactory alloc] init];
        
    });
    return _layoutFactory;
}

- (instancetype)init
{
    if (self = [super init]) {
        _layoutTypeMap = [[NSMutableDictionary alloc]init];
        NSString *layoutMapPath = [[NSBundle mainBundle] pathForResource:@"TangramLayoutTypeMap" ofType:@"plist"];
        [_layoutTypeMap addEntriesFromDictionary:[TangramDefaultLayoutFactory decodeTypeMap:[NSArray arrayWithContentsOfFile:layoutMapPath]]];
    }
    return self;
}

/**
 Regist Layout Type and its className
 
 @param type is TangramLayoutType In TangramLayoutProtocol
 @param layoutClassName layoutClassName
 */
+ (void)registLayoutType:(NSString *)type className:(NSString *)layoutClassName
{
    if (type.length > 0 && layoutClassName.length > 0) {
        [[TangramDefaultLayoutFactory sharedInstance].layoutTypeMap setObject:[type copy] forKey:[layoutClassName copy]];
    }
}

/**
 Generate a layout by a dictionary
 
 @param dict dict
 @return layout
 */
+ (UIView<TangramLayoutProtocol> *)layoutByDict:(NSDictionary *)dict
{
    NSString *type = [dict tm_safeObjectForKey:@"type" class:[NSString class]];
    if (type.length <= 0) {
        return nil;
    }
    NSString *layoutClassName = [[TangramDefaultLayoutFactory sharedInstance].layoutTypeMap tm_stringForKey:type];
    UIView<TangramLayoutProtocol> *layout = nil;
    if ([dict tm_boolForKey:@"canHorizontalScroll"] && ([type integerValue] <= 4 || [type integerValue] == 9)) {
        layout = [[TangramScrollFlowLayout alloc] init];
        ((TangramScrollFlowLayout *)layout).numberOfColumns = (NSUInteger)[type integerValue];
    }
    else {
        layout = (UIView<TangramLayoutProtocol> *)[[NSClassFromString(layoutClassName) alloc]init];
    }
    if (!layout) {
        NSLog(@"[TangramDefaultLayoutFactory] layoutByDict : cannot find layout by type , type :%@",type);
        return nil;
    }
    return [TangramDefaultLayoutFactory fillLayoutProperty:layout withDict:dict];
}

/**
 Fill Layout Property

 @param layout layout
 @param dict dict
 @return layout filled property
 */
+ (UIView<TangramLayoutProtocol> *)fillLayoutProperty:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict
{
    layout.identifier = [dict tm_stringForKey:@"id"];
    NSDictionary *styleDict = [dict tm_dictionaryForKey:@"style"];
    NSString *backgroundColor = [styleDict tm_stringForKey:@"bgColor"];
    if (backgroundColor.length <= 0 ) {
        backgroundColor = [styleDict tm_stringForKey:@"background-color"];
    }
    if (backgroundColor.length > 0) {
        layout.backgroundColor = [UIColor vv_colorWithString:backgroundColor];
    }
    NSString *bgImgURL = [styleDict tm_stringForKey:@"bgImgUrl"];
    if (bgImgURL.length <= 0) {
        bgImgURL = [styleDict tm_stringForKey:@"background-image"];
    }
    if (bgImgURL.length > 0 && [layout respondsToSelector:@selector(setBgImgURL:)]) {
        layout.bgImgURL = bgImgURL;
    }
    return [TangramLayoutParseHelper layoutConfigByOriginLayout:layout withDict:dict];
}

+ (NSMutableDictionary *)decodeTypeMap:(NSArray *)mapArray
{
    NSMutableDictionary *mapDict = [[NSMutableDictionary alloc]init];
    for (NSDictionary *dict in mapArray) {
        NSString *key = [dict tm_safeObjectForKey:@"type" class:[NSString class]];
        NSString *value = [dict tm_safeObjectForKey:@"class" class:[NSString class]];
        if (key.length > 0 && value.length > 0) {
            //NSAssert(![[mapDict allKeys] containsObject:key], @"model有重复注册!请检查注册的type!");
            [mapDict setObject:value forKey:key];
        }
    }
    return mapDict;
}

+ (NSArray *)preprocessedDataArrayFromOriginalArray:(NSArray *)originalArray
{
    NSMutableArray *layouts = [[NSMutableArray alloc]init];
    for (NSUInteger i = 0 ; i < originalArray.count ; i ++) {
        NSDictionary *dict = [originalArray tm_dictionaryAtIndex:i];
        NSString *type = [dict tm_stringForKey:@"type"];
        if (type.length <= 0) {
            break;
        }
        NSDictionary *style = [dict tm_dictionaryForKey:@"style"];
        NSString *forLabel = [style tm_stringForKey:@"forLabel"];
        if (forLabel.length > 0 && i < originalArray.count - 1)
        {
            NSDictionary *nestLayoutDict = [originalArray tm_safeObjectAtIndex:i + 1];
            if (![forLabel isEqualToString:[nestLayoutDict tm_stringForKey:@"id"]] || [nestLayoutDict tm_arrayForKey:@"items"].count <= 0)
            {
                continue;
            }
        }
        NSArray *originalItems = [dict tm_arrayForKey:@"items"];
        //24 TabsLayout，做数据拆分
        if ([type isEqualToString:@"24"]) {
            //解析出来顶部的header
            NSString *originalIdentifier = [dict tm_stringForKey:@"id"];
            NSString *layoutClassType = @"20";
            NSString *headerIdentifier = [NSString stringWithFormat:@"%@-tabheader",originalIdentifier];
            NSMutableDictionary *tabHeaderDictionary = [[NSMutableDictionary alloc]init];
            [tabHeaderDictionary setObject:headerIdentifier forKey:@"id"];
            if (style) {
                [tabHeaderDictionary setObject:[style copy] forKey:@"style"];
            }
            [tabHeaderDictionary setObject:layoutClassType forKey:@"type"];
            [tabHeaderDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"canHorizontalScroll"];
            [tabHeaderDictionary setObject:[[originalItems tm_dictionaryAtIndex:0] copy] forKey:@"items"];
            [layouts tm_safeAddObject:tabHeaderDictionary];
            //解析其他内容，删掉第一个组件
            NSMutableDictionary *layoutMutableDict = [dict mutableCopy];
            NSMutableArray *contentItems = [originalItems mutableCopy];
            if (contentItems.count > 1) {
                [contentItems removeObjectAtIndex:0];
                [layoutMutableDict setObject:contentItems forKey:@"items"];
            }
            [layouts tm_safeAddObject:[layoutMutableDict copy]];
        }
        //11 MixLayout, 做数据拆分
        if ([type isEqualToString:@"11"]) {
            NSMutableArray *mutableOriginalItems = [originalItems mutableCopy];
            NSString *identifier = [dict tm_stringForKey:@"id"];
            //获得了N个Layout实例
            NSArray *mixLayoutoriginalArray = [[dict tm_dictionaryForKey:@"style"] tm_arrayForKey:@"mixedLayouts"];
            NSUInteger originalArrayCount = 1;
            if (![type isEqualToString:@"24"]) {
                originalArrayCount = mixLayoutoriginalArray.count;
            }
            
            for (NSUInteger i = 0 ; i< originalArrayCount ; i++) {
                NSDictionary *mixLayoutDict = [mixLayoutoriginalArray tm_dictionaryAtIndex:i];
                NSMutableDictionary *mutableDict = [mixLayoutDict mutableCopy];
                [mutableDict setObject:[NSString stringWithFormat:@"%@-%ld",identifier,(long)(i+1)] forKey:@"id"];
                NSUInteger count = [dict tm_integerForKey:@"count"];
                if (mutableOriginalItems.count > 0 ) {
                    if (mutableOriginalItems.count < count) {
                        count = mutableOriginalItems.count;
                    }
                    NSArray *itemModels = [mutableOriginalItems objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
                    [mutableDict setObject:[itemModels copy] forKey:@"items"];
                    [mutableOriginalItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
                }
                [layouts tm_safeAddObject:mutableDict];
            }
        }
        [layouts tm_safeAddObject:dict];
    }
    return [layouts copy];
}

+ (NSString *)layoutClassNameByType:(NSString *)type
{
    return [[TangramDefaultLayoutFactory sharedInstance].layoutTypeMap tm_stringForKey:@"type"];
}
@end

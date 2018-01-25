//
//  TangramDefaultItemModelFactory.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramDefaultItemModelFactory.h"
#import "TangramDefaultItemModel.h"
#import "TMUtils.h"

@interface TangramDefaultItemModelFactory()

@property (nonatomic, strong) NSMutableDictionary *elementTypeMap;

@end

@implementation TangramDefaultItemModelFactory

+ (TangramDefaultItemModelFactory*)sharedInstance
{
    static TangramDefaultItemModelFactory *_itemModelFactory= nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _itemModelFactory = [[TangramDefaultItemModelFactory alloc] init];
    });
    return _itemModelFactory;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.elementTypeMap = [[NSMutableDictionary alloc]init];
        NSString *elementMapPath = [[NSBundle mainBundle] pathForResource:@"TangramKitVVElementTypeMap" ofType:@"plist"];
        [self.elementTypeMap addEntriesFromDictionary:[TangramDefaultItemModelFactory decodeElementTypeMap:[NSArray arrayWithContentsOfFile:elementMapPath]]];
    }
    return self;
}

+ (NSObject<TangramItemModelProtocol> *)itemModelByDict:(NSDictionary *)dict
{
    NSString *type = [dict tm_stringForKey:@"type"];
//    if (type.length <= 0) {
//        return nil;
//    }
    TangramDefaultItemModel *itemModel = [[TangramDefaultItemModel alloc]init];
    //布局参数解析
    itemModel.type = type;
    NSDictionary *styleDict =[dict tm_dictionaryForKey:@"style"];
    NSObject *margin =[styleDict objectForKey:@"margin"];
    if ([margin isKindOfClass:[NSString class]]) {
        NSString *marginString = [(NSString *)margin stringByReplacingOccurrencesOfString:@"[" withString:@""];
        marginString = [marginString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *marginArray = [marginString componentsSeparatedByString:@","];
        if (marginArray && 4 == marginArray.count) {
            itemModel.margin = @[
                                 @([marginArray tm_floatAtIndex:0]),
                                 @([marginArray tm_floatAtIndex:1]),
                                 @([marginArray tm_floatAtIndex:2]),
                                 @([marginArray tm_floatAtIndex:3]),
                                 ];
        }
    }
    else if([margin isKindOfClass:[NSArray class]])
    {
        itemModel.margin = (NSArray *)margin;
    }
    else{
        itemModel.margin = @[@0, @0, @0, @0];
    }
    if ([[styleDict tm_stringForKey:@"display"] isEqualToString:@"block"]) {
        itemModel.display = @"block";
    }
    else{
        itemModel.display = @"inline";
    }
    //针对style中的height和width
    if ([styleDict tm_floatForKey:@"height"] > 0.f) {
        itemModel.heightFromStyle = [styleDict tm_floatForKey:@"height"]/375.f*[UIScreen mainScreen].bounds.size.width;
    }
    if ([styleDict tm_floatForKey:@"width"] > 0.f) {
        itemModel.widthFromStyle = [styleDict tm_floatForKey:@"width"]/375.f*[UIScreen mainScreen].bounds.size.width;
    }
    else if ([[styleDict tm_stringForKey:@"width"] isEqualToString:@"-1"]) {
        //width 配-1 意味着屏幕宽度
        itemModel.widthFromStyle = [UIScreen mainScreen].bounds.size.width;
    }
    if ([styleDict tm_floatForKey:@"aspectRatio"] > 0.f) {
        itemModel.modelAspectRatio  = [styleDict tm_floatForKey:@"aspectRatio"];
    }
    if ([styleDict tm_floatForKey:@"ratio"] > 0.f) {
        itemModel.modelAspectRatio = [styleDict tm_floatForKey:@"ratio"];
    }
    itemModel.colspan = [styleDict tm_integerForKey:@"colspan"];
    itemModel.position = [dict tm_stringForKey:@"position"];
//    itemModel.ctrClickParam = [dict tm_stringForKey:@"ctrClickParam"];
    itemModel.specificReuseIdentifier = [styleDict tm_stringForKey:@"reuseId"];
    itemModel.disableReuse = [styleDict tm_boolForKey:@"disableReuse"];
    
    for (NSString *key in [dict allKeys]) {
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"style"] ) {
            continue;
        }
        else{
            [itemModel setBizValue:[dict tm_safeObjectForKey:key] forKey:key];
        }
    }
    for (NSString *key in [styleDict allKeys]) {
        if ([key isEqualToString:@"margin"] || [key isEqualToString:@"display"]||[key isEqualToString:@"colspan"]
            || [key isEqualToString:@"height"] || [key isEqualToString:@"width"]  ) {
            continue;
        }
        else{
            [itemModel setStyleValue:[styleDict tm_safeObjectForKey:key] forKey:key];
        }
    }
    if ([[dict tm_stringForKey:@"kind"] isEqualToString:@"row"]) {
        itemModel.layoutIdentifierForLayoutModel = [dict tm_stringForKey:@"id"];
    }
    itemModel.linkElementName = [[TangramDefaultItemModelFactory sharedInstance].elementTypeMap tm_stringForKey:itemModel.type];

    return itemModel;
}
+ (NSMutableDictionary *)decodeElementTypeMap:(NSArray *)mapArray
{
    NSMutableDictionary *mapDict = [[NSMutableDictionary alloc]init];
    for (NSDictionary *dict in mapArray) {
        NSString *key = [dict tm_stringForKey:@"type"];
        NSString *value = [dict tm_stringForKey:@"element"];
        if (key.length > 0 && value.length > 0) {
            NSAssert(![[mapDict allKeys] containsObject:key], @"There are repeat registration for element!Please check type!");
            [mapDict setObject:value forKey:key];
        }
    }
    return mapDict;
}
/**
 Regist Element
 
 @param type In ItemModel we need return a itemType, the itemType will be used here
 */
+ (void)registElementType:(NSString *)type className:(NSString *)elementClassName
{
    if ([type isKindOfClass:[NSString class]] && type.length > 0
        && [elementClassName isKindOfClass:[NSString class]] && elementClassName.length > 0) {
        [[TangramDefaultItemModelFactory sharedInstance].elementTypeMap tm_safeSetObject:[elementClassName copy] forKey:[type copy]];
    }
}

@end

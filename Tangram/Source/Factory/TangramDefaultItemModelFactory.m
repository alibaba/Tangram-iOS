//
//  TangramDefaultItemModelFactory.m
//  Pods
//
//  Created by xiaoxia on 2017/1/13.
//
//

#import "TangramDefaultItemModelFactory.h"
#import "TangramDefaultItemModel.h"
#import "TangramSafeMethod.h"

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
        //暂时先放在这里，之后移除到自己的factory中!
        self.elementTypeMap = [[NSMutableDictionary alloc]init];
        NSString *tangramMapPath = [[NSBundle mainBundle]pathForResource:@"TangramHelperMapping" ofType:@"plist"];
        NSArray *mapArray = [NSArray arrayWithContentsOfFile:tangramMapPath];
        for (NSDictionary *dict in mapArray) {
            NSString *elementMapString = [dict tgrm_stringForKey:@"modelMap"];
            NSString *elementMapPath = [[NSBundle mainBundle] pathForResource:elementMapString ofType:@"plist"];
            [self.elementTypeMap addEntriesFromDictionary:[TangramDefaultItemModelFactory decodeElementTypeMap:[NSArray arrayWithContentsOfFile:elementMapPath]]];
        }
    }
    return self;
}

+ (NSObject<TangramItemModelProtocol> *)itemModelByDict:(NSDictionary *)dict
{
    NSString *type = [dict tgrm_stringForKey:@"type"];
//    if (type.length <= 0) {
//        return nil;
//    }
    TangramDefaultItemModel *itemModel = [[TangramDefaultItemModel alloc]init];
    //布局参数解析
    itemModel.type = type;
    NSDictionary *styleDict =[dict tgrm_dictionaryForKey:@"style"];
    NSObject *margin =[styleDict objectForKey:@"margin"];
    if ([margin isKindOfClass:[NSString class]]) {
        NSString *marginString = [(NSString *)margin stringByReplacingOccurrencesOfString:@"[" withString:@""];
        marginString = [marginString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *marginArray = [marginString componentsSeparatedByString:@","];
        if (marginArray && 4 == marginArray.count) {
            itemModel.margin = @[
                                 @([marginArray tgrm_floatAtIndex:0]),
                                 @([marginArray tgrm_floatAtIndex:1]),
                                 @([marginArray tgrm_floatAtIndex:2]),
                                 @([marginArray tgrm_floatAtIndex:3]),
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
    if ([[styleDict tgrm_stringForKey:@"display"] isEqualToString:@"block"]) {
        itemModel.display = @"block";
    }
    else{
        itemModel.display = @"inline";
    }
    //针对style中的height和width
    if ([styleDict tgrm_floatForKey:@"height"] > 0.f) {
        itemModel.heightFromStyle = [styleDict tgrm_floatForKey:@"height"]/375.f*[UIScreen mainScreen].bounds.size.width;
    }
    if ([styleDict tgrm_floatForKey:@"width"] > 0.f) {
        itemModel.widthFromStyle = [styleDict tgrm_floatForKey:@"width"]/375.f*[UIScreen mainScreen].bounds.size.width;
    }
    else if ([[styleDict tgrm_stringForKey:@"width"] isEqualToString:@"-1"]) {
        //width 配-1 意味着屏幕宽度
        itemModel.widthFromStyle = [UIScreen mainScreen].bounds.size.width;
    }
    if ([styleDict tgrm_floatForKey:@"aspectRatio"] > 0.f) {
        itemModel.modelAspectRatio  = [styleDict tgrm_floatForKey:@"aspectRatio"];
    }
    if ([styleDict tgrm_floatForKey:@"ratio"] > 0.f) {
        itemModel.modelAspectRatio = [styleDict tgrm_floatForKey:@"ratio"];
    }
    itemModel.colspan = [styleDict tgrm_integerForKey:@"colspan"];
    itemModel.position = [dict tgrm_stringForKey:@"position"];
//    itemModel.ctrClickParam = [dict tgrm_stringForKey:@"ctrClickParam"];
    itemModel.specificReuseIdentifier = [styleDict tgrm_stringForKey:@"reuseId"];
    itemModel.disableReuse = [styleDict tgrm_boolForKey:@"disableReuse"];
    
    for (NSString *key in [dict allKeys]) {
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"style"] ) {
            continue;
        }
        else{
            [itemModel setBizValue:[dict tgrm_objectForKeyCheck:key] forKey:key];
        }
    }
    for (NSString *key in [styleDict allKeys]) {
        if ([key isEqualToString:@"margin"] || [key isEqualToString:@"display"]||[key isEqualToString:@"colspan"]
            || [key isEqualToString:@"height"] || [key isEqualToString:@"width"]  ) {
            continue;
        }
        else{
            [itemModel setStyleValue:[styleDict tgrm_objectForKeyCheck:key] forKey:key];
        }
    }
    if ([[dict tgrm_stringForKey:@"kind"] isEqualToString:@"row"]) {
        itemModel.layoutIdentifierForLayoutModel = [dict tgrm_stringForKey:@"id"];
    }
    itemModel.linkElementName = [[TangramDefaultItemModelFactory sharedInstance].elementTypeMap tgrm_stringForKey:itemModel.type];

    return itemModel;
}
+ (NSMutableDictionary *)decodeElementTypeMap:(NSArray *)mapArray
{
    NSMutableDictionary *mapDict = [[NSMutableDictionary alloc]init];
    for (NSDictionary *dict in mapArray) {
        NSString *key = [dict tgrm_stringForKey:@"type"];
        NSString *value = [dict tgrm_stringForKey:@"element"];
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
 @param elementClassName
 */
+ (void)registElementType:(NSString *)type className:(NSString *)elementClassName
{
    if ([type isKindOfClass:[NSString class]] && type.length > 0
        && [elementClassName isKindOfClass:[NSString class]] && elementClassName.length > 0) {
        [[TangramDefaultItemModelFactory sharedInstance].elementTypeMap setObject:[elementClassName copy] forKey:[type copy]];
    }
}

@end

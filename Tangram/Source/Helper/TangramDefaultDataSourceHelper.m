//
//  TangramDefaultDataSourceHelper.m
//  Pods
//
//  Created by xiaoxia on 2017/1/18.
//
//
#import <objc/runtime.h>

#import <LazyScroll/TMMuiLazyScrollView.h>
#import "TangramLayoutProtocol.h"
#import "TangramItemModelProtocol.h"
#import "TangramEasyElementProtocol.h"
#import "TangramLayoutParseHelper.h"
#import "TangramSafeMethod.h"
#import "TangramDefaultItemModelFactory.h"
#import "TangramDefaultItemModel.h"
#import "TangramSafeMethod.h"
#import "TangramEasyElementProtocol.h"
#import "TangramDefaultDataSourceHelper.h"

@interface TangramDefaultDataSourceHelper()

@property (nonatomic, strong) Class<TangramLayoutFactoryProtocol> layoutFactoryClass;

@property (nonatomic, strong) Class<TangramItemModelFactoryProtocol> itemModelFactoryClass;

@property (nonatomic, strong) Class<TangramElementFactoryProtocol> elementFactoryClass;

@end

@implementation TangramDefaultDataSourceHelper

+ (TangramDefaultDataSourceHelper*)sharedInstance
{
    static TangramDefaultDataSourceHelper *_dataSourceHelper = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _dataSourceHelper = [[TangramDefaultDataSourceHelper alloc] init];
    });
    return _dataSourceHelper;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.layoutFactoryClass = NSClassFromString(@"TangramDefaultLayoutFactory");
        self.itemModelFactoryClass = NSClassFromString(@"TangramDefaultItemModelFactory");
        self.elementFactoryClass = NSClassFromString(@"TangramDefaultElementFactory");
    }
    return self;
}
#pragma mark - Quick Parser
+(UIView<TangramLayoutProtocol> *)layoutWithDictionary: (NSDictionary *)dict
{
    return [self layoutWithDictionary:dict tangramBus:nil];
}

+(UIView<TangramLayoutProtocol> *)layoutWithDictionary: (NSDictionary *)dict tangramBus:(TangramBus *)tangramBus
{
    NSString *type = [dict tgrm_stringForKey:@"type"];
    if (type.length <= 0) {
        return nil;
    }
    UIView<TangramLayoutProtocol> *layout = nil;
    layout = [[TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass layoutByDict:dict];
    return [self fillLayoutProperty:layout withDict:dict tangramBus:tangramBus];
}


+ (NSArray<UIView<TangramLayoutProtocol> *> *)layoutsWithArray: (NSArray<NSDictionary *> *)dictArray
{
    return [self layoutsWithArray:dictArray tangramBus:nil];
}
+(NSArray<UIView<TangramLayoutProtocol> *> *)layoutsWithArray: (NSArray<NSDictionary *> *)dictArray
                                                   tangramBus: (TangramBus *)tangramBus
{
    NSMutableArray *layouts = [[NSMutableArray alloc]init];
    if ([(Class)([TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass) instanceMethodForSelector:@selector(preprocessedDataArrayFromOriginalArray:)]) {
        dictArray = [[TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass preprocessedDataArrayFromOriginalArray:dictArray];
    }
    for (NSDictionary *dict in dictArray) {
        UIView<TangramLayoutProtocol> *layout = [[TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass layoutByDict:dict];
        [self fillLayoutProperty:layout withDict:dict tangramBus:tangramBus];
        [layouts tgrm_addObjectCheck:layout];
        for (int i = 0 ; i< layout.itemModels.count; i++) {
            TangramDefaultItemModel *itemModel = [layout.itemModels tgrm_objectAtIndexCheck:i];
            if ([itemModel isKindOfClass:[TangramDefaultItemModel class]]) {
                itemModel.index = i;
            }
        }
    }
    return [layouts copy];
}


+(NSObject<TangramItemModelProtocol> *)modelWithDictionary : (NSDictionary *)dict
{
    NSString *type = [dict tgrm_stringForKey:@"type"];
    if (type.length <= 0) {
        return nil;
    }
    NSObject<TangramItemModelProtocol> *itemModel = nil;
    itemModel = [[TangramDefaultDataSourceHelper sharedInstance].itemModelFactoryClass itemModelByDict:dict];
    if ([[dict tgrm_stringForKey:@"kind"] isEqualToString:@"row"]) {
        if ([(Class)([TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass) instanceMethodForSelector:@selector(layoutClassNameByType:)]) {
            itemModel.linkElementName = [[TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass layoutClassNameByType:itemModel.itemType];
        }
    }
    return itemModel;
}

+(NSArray *)modelsWithDictArray : (NSArray *)dictArray {
    NSMutableArray *mutArray = [NSMutableArray array];
    for (NSDictionary *dict in dictArray) {
        [mutArray tgrm_addObjectCheck:[self modelWithDictionary:dict]];
    }
    return [mutArray copy];
}

+(NSMutableArray *)modelsWithLayoutDictionary : (NSDictionary *)dict
{
    if (dict.count == 0) {
        return  [[NSMutableArray alloc]init];
    }
    NSMutableArray *itemModels = [[NSMutableArray alloc]init];
    NSArray *itemModelArray = [dict tgrm_arrayForKey:@"items"];
    for (NSUInteger i = 0 ; i < itemModelArray.count ; i++) {
        NSDictionary *dict = [itemModelArray tgrm_dictionaryAtIndex:i];
        NSObject<TangramItemModelProtocol> *model =  [self modelWithDictionary:dict];
        if (model) {
            [itemModels tgrm_addObjectCheck:model];
        }
        if ([model isKindOfClass:[TangramDefaultItemModel class]]) {
            ((TangramDefaultItemModel *)model).index = i;
        }
    }
    return itemModels;
}

+(UIView *)refreshElement:(UIView *)element byModel:(NSObject<TangramItemModelProtocol> *)model
{
    return [self refreshElement:element byModel:model layout:nil tangramBus:nil];
}

+(UIView *)refreshElement:(UIView *)element byModel:(NSObject<TangramItemModelProtocol> *)model
                   layout:(UIView<TangramLayoutProtocol> *)layout
               tangramBus:(TangramBus *)tangramBus
{
    if ([model respondsToSelector:@selector(layoutIdentifierForLayoutModel)] && model.layoutIdentifierForLayoutModel && model.layoutIdentifierForLayoutModel.length > 0) {
        return nil;
    }
    element = [[TangramDefaultDataSourceHelper sharedInstance].elementFactoryClass refreshElement:element byModel:model];
    if ([element conformsToProtocol:@protocol(TangramEasyElementProtocol)]){
        if (model && [element respondsToSelector:@selector(setTangramItemModel:)] && [model isKindOfClass:[TangramDefaultItemModel class]]) {
            [((UIView<TangramEasyElementProtocol> *)element) setTangramItemModel:(TangramDefaultItemModel *)model];
        }
        if (layout && [element respondsToSelector:@selector(setAtLayout:)]) {
            //if its nested itemModel, here should bind tangrambus
            if ([model isKindOfClass:[TangramDefaultItemModel class]]
                && [layout respondsToSelector:@selector(subLayoutDict)]
                && [layout respondsToSelector:@selector(subLayoutIdentifiers)]
                && model.inLayoutIdentifier.length > 0) {
                [((UIView<TangramEasyElementProtocol> *)element) setAtLayout:[layout.subLayoutDict tgrm_objectForKeyCheck:model.inLayoutIdentifier]];
            }
            else{
                [((UIView<TangramEasyElementProtocol> *)element) setAtLayout:layout];
            }
        }
        if (tangramBus && [element respondsToSelector:@selector(setTangramBus:)] ) {
            [((UIView<TangramEasyElementProtocol> *)element) setTangramBus:tangramBus];
        }
    }
    return element;
}

+(UIView *)elementByModel:(NSObject<TangramItemModelProtocol> *)model
{
    return [self elementByModel:model layout:nil tangramBus:nil];
}
+(UIView *)elementByModel:(NSObject<TangramItemModelProtocol> *)model
                   layout:(UIView<TangramLayoutProtocol> *)layout
               tangramBus:(TangramBus *)tangramBus
{
    UIView *element = [[TangramDefaultDataSourceHelper sharedInstance].elementFactoryClass elementByModel:model];
    element.reuseIdentifier = model.reuseIdentifier;
    if ([element conformsToProtocol:@protocol(TangramEasyElementProtocol)]){
        if (model && [element respondsToSelector:@selector(setTangramItemModel:)] && [model isKindOfClass:[TangramDefaultItemModel class]]) {
            [((UIView<TangramEasyElementProtocol> *)element) setTangramItemModel:(TangramDefaultItemModel *)model];
        }
        if (layout && [element respondsToSelector:@selector(setAtLayout:)]) {
            //if its nested itemModel, here should bind tangrambus
            if ([model isKindOfClass:[TangramDefaultItemModel class]]
                && [layout respondsToSelector:@selector(subLayoutDict)]
                && [layout respondsToSelector:@selector(subLayoutIdentifiers)]
                && model.inLayoutIdentifier.length > 0) {
                [((UIView<TangramEasyElementProtocol> *)element) setAtLayout:[layout.subLayoutDict tgrm_objectForKeyCheck:model.inLayoutIdentifier]];
            }
            else{
                [((UIView<TangramEasyElementProtocol> *)element) setAtLayout:layout];
            }
        }
        if (tangramBus && [element respondsToSelector:@selector(setTangramBus:)] ) {
            [((UIView<TangramEasyElementProtocol> *)element) setTangramBus:tangramBus];
        }
    }
    return element;
}


#pragma mark - Private
+ (UIView<TangramLayoutProtocol> *)fillLayoutProperty :(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict tangramBus:(TangramBus *)tangramBus
{
    layout.itemModels = [self modelsWithLayoutDictionary:dict];
    //Check whether its nested layout
    NSMutableDictionary *mutableInnerLayoutDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *mutableInnerLayoutIdentifierArray = [[NSMutableArray alloc]init];
    NSMutableArray *itemModelToBeAdded = [[NSMutableArray alloc]init];
    NSMutableArray *itemModelToBeRemoved = [[NSMutableArray alloc]init];
    for (NSUInteger i = 0 ; i < layout.itemModels.count ; i++) {
        NSObject<TangramItemModelProtocol> *model = [layout.itemModels tgrm_objectAtIndexCheck:i];
        //Analyze whether its nested layout.
        if ([model respondsToSelector:@selector(layoutIdentifierForLayoutModel)] &&  model.layoutIdentifierForLayoutModel && model.layoutIdentifierForLayoutModel.length > 0) {
            NSDictionary *modelDict = [[dict tgrm_arrayForKey:@"items"] tgrm_dictionaryAtIndex:i];
            if ( 0 >= [modelDict tgrm_arrayForKey:@"items"].count) {
                [itemModelToBeRemoved tgrm_addObjectCheck:model];
                continue;
            }
            //Generate layout
            UIView<TangramLayoutProtocol> *innerLayout = [self layoutWithDictionary:modelDict  tangramBus:tangramBus];
            if (innerLayout && innerLayout.identifier.length > 0) {
                [mutableInnerLayoutDict setObject:innerLayout forKey:innerLayout.identifier];
                [mutableInnerLayoutIdentifierArray tgrm_addObjectCheck:innerLayout.identifier];
            }
            
            NSArray *innerLayoutItemModels = innerLayout.itemModels;
            for (NSObject<TangramItemModelProtocol> *innerModel in innerLayoutItemModels) {
                if ([innerModel conformsToProtocol:@protocol(TangramItemModelProtocol)]){
                    if([innerModel respondsToSelector:@selector(setInnerItemModel:)]) {
                        innerModel.innerItemModel = YES;
                    }
                    if ([innerModel respondsToSelector:@selector(setInLayoutIdentifier:)]) {
                        innerModel.inLayoutIdentifier = innerLayout.identifier;
                    }
                }
            }
            if (innerLayoutItemModels && [innerLayoutItemModels isKindOfClass:[NSArray class]] && innerLayoutItemModels.count > 0) {
                [itemModelToBeAdded addObjectsFromArray:innerLayoutItemModels];
            }
        }
    }
    NSMutableArray *originMutableItemModels = [layout.itemModels mutableCopy];
    for (NSObject<TangramItemModelProtocol> *model in itemModelToBeRemoved) {
        [originMutableItemModels removeObject:model];
    }
    [originMutableItemModels addObjectsFromArray:itemModelToBeAdded];
    layout.itemModels = [originMutableItemModels copy];
    if ([layout respondsToSelector:@selector(setSubLayoutDict:)] && mutableInnerLayoutDict.count > 0) {
        layout.subLayoutDict = [mutableInnerLayoutDict copy];
        layout.subLayoutIdentifiers = [mutableInnerLayoutIdentifierArray copy];
    }
    //bind tangrambus
    if (tangramBus && [tangramBus isKindOfClass:[TangramBus class]] && [layout respondsToSelector:@selector(setTangramBus:)] ) {
        [layout setTangramBus:tangramBus];
    }
    return layout;
}


+ (NSUInteger)innerViewCountInLayouts:(NSArray *)layoutArray
{
    NSUInteger count = 0;
    if (layoutArray.count > 0) {
        for (NSUInteger i = 0 ; i < layoutArray.count; i++) {
            UIView *layout = [layoutArray tgrm_objectAtIndexCheck:i];
            if([layout isKindOfClass:[UIView class]])
            {
                count += [layout subviews].count;
            }
        }
    }
    return count;
}
+ (NSUInteger)innerModelCountInLayouts:(NSArray *)layoutArray
{
    NSUInteger count = 0;
    if (layoutArray.count > 0) {
        for (NSUInteger i = 0 ; i < layoutArray.count; i++) {
            UIView<TangramLayoutProtocol> *layout = [layoutArray tgrm_objectAtIndexCheck:i];
            if( [layout conformsToProtocol:@protocol(TangramLayoutProtocol)] && [layout isKindOfClass:[UIView class]])
            {
                count += [layout itemModels].count;
            }
        }
    }
    return count;
}

+ (void)registLayoutFactoryClassName:(NSString *)layoutFactoryClassName
{
    //Class<TangramLayoutFactoryProtocol> layoutFactoryClass = NSClassFromString(layoutFactoryClassName);
    if ([NSClassFromString(layoutFactoryClassName) instanceMethodForSelector:@selector(layoutByDict:)]) {
        [TangramDefaultDataSourceHelper sharedInstance].layoutFactoryClass = NSClassFromString(layoutFactoryClassName);
    }
}
+ (void)registItemModelFactoryClassName:(NSString *)itemModelFactoryClassName
{
    if ([NSClassFromString(itemModelFactoryClassName) instanceMethodForSelector:@selector(itemModelByDict:)]) {
        [TangramDefaultDataSourceHelper sharedInstance].itemModelFactoryClass = NSClassFromString(itemModelFactoryClassName);
    }
}
+ (void)registElementFactoryClassName:(NSString *)elementFactoryClassName
{
    if ([NSClassFromString(elementFactoryClassName) instanceMethodForSelector:@selector(elementByModel:)]
        && [NSClassFromString(elementFactoryClassName) instanceMethodForSelector:@selector(refreshElement:byModel:)] ) {
        [TangramDefaultDataSourceHelper sharedInstance].elementFactoryClass = NSClassFromString(elementFactoryClassName);
    }
}



@end

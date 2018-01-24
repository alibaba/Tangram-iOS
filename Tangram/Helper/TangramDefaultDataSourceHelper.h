//
//  TangramDefaultDataSourceHelper.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramItemModelProtocol.h"
#import "TangramLayoutProtocol.h"
#import "TangramDefaultItemModel.h"
#import "TangramBus.h"
#import "TangramLayoutFactoryProtocol.h"
#import "TangramItemModelFactoryProtocol.h"
#import "TangramElementFactoryProtocol.h"

//  There are three main functions in TangramDataSourceHelper
//  1. JSON to Layout
//  2. JSON to model
//  3. Model to element
//  Three functions executed by three generator. These three generator can be replaced.

@interface TangramDefaultDataSourceHelper : NSObject
/////////////////////////////////Core Class Method///////////////////////////////////////////


/**
 *  Generate layouts array by a NSDictionary array
 *  Besides, this method will generate itemModels for every layout
 *  You can get itemModels from layout generated.
 *  @param dictArray NSDictionary array
 *
 *  @return Layout Array
 */
+(NSArray<UIView<TangramLayoutProtocol> *> *)layoutsWithArray: (NSArray<NSDictionary *> *)dictArray;
/**
 *  Generate layouts array by a NSDictionary array
 *  Besides, this method will generate itemModels for every layout
 *  You can get itemModels from layout generated.
 *  If tangram is not nil, helper will bind layouts with this tangrambus.
 *  @param dictArray NSDictionary array
 *
 *  @return Layout Array
 */
+(NSArray<UIView<TangramLayoutProtocol> *> *)layoutsWithArray: (NSArray<NSDictionary *> *)dictArray
                                                   tangramBus: (TangramBus *)tangramBus;

/**
 *  Generate element By Model
 *
 *  @param model TangramModel
 *
 *  @return Element instance
 */
+(UIView *)elementByModel:(NSObject<TangramItemModelProtocol>  *)model;
/**
 *  Generate element By Model. Here will bind Model,Layout,tangramBus to element
 *
 *  @param model      model
 *  @param layout     layout
 *  @param tangramBus Tangram event bus
 *
 *  @return Element instance
 */
+(UIView *)elementByModel:(NSObject<TangramItemModelProtocol> *)model
                   layout:(UIView<TangramLayoutProtocol> *)layout
               tangramBus:(TangramBus *)tangramBus;
/**
 *  Refresh element By Model
 *
 *  @param element UIView element can be reused
 *
 *  @return refreshed element
 */
+(UIView *)refreshElement:(UIView *)element byModel:(NSObject<TangramItemModelProtocol> *)model;
/**
 *  Refresh element By Model. Here will bind Model,Layout,tangramBus to element
 *
 *  @param element    element can be reused
 *  @param model      model
 *  @param layout     layout
 *  @param tangramBus Tangram event bus
 *
 *  @return refreshed element
 */
+(UIView *)refreshElement:(UIView *)element byModel:(NSObject<TangramItemModelProtocol> *)model
                   layout:(UIView<TangramLayoutProtocol> *)layout
               tangramBus:(TangramBus *)tangramBus;

/**
 *  Generate a model by NSDictionary
 *
 *  @param dict The Dictionary of a model
 *
 *  @return TangramModel
 */
+(TangramDefaultItemModel *)modelWithDictionary : (NSDictionary *)dict;
/**
 *  Generate models by NSDictionary array
 *
 *  @param dictArray dictArray
 *
 *  @return NSArray
 */
+(NSArray<TangramDefaultItemModel *> *)modelsWithDictArray : (NSArray *)dictArray;

/**
 *  根据Dict生成layout
 *  这里生成的layout内的itemModels是有值的,那model可以直接用layout.itemModels取
 *  @param dict layout的dict
 *
 *  @return  layout
 */
+(UIView<TangramLayoutProtocol> *)layoutWithDictionary: (NSDictionary *)dict tangramBus:(TangramBus *)tangramBus;


/////////////////////////////////Core Class Method end/////////////////////////////////////////////


/////////////////////////////////Method will be depracated/////////////////////////////////////////
+(UIView<TangramLayoutProtocol> *)layoutWithDictionary:(NSDictionary *)dict;

+(NSMutableArray *)modelsWithLayoutDictionary : (NSDictionary *)dict;
//////////////////////////////Method will be depracated end////////////////////////////////////////


//////////////////////////////////Other Helper method//////////////////////////////////////////////

/**
 Return inner View in layouts

 @param layoutArray layout instance array
 @return Inner view count.
 */
+ (NSUInteger)innerViewCountInLayouts:(NSArray *)layoutArray;

/**
 Return inner models in layouts

 @param layoutArray layout instance array
 @return Inner model count
 */
+ (NSUInteger)innerModelCountInLayouts:(NSArray *)layoutArray;

//////////////////////////////////Other Helper method end//////////////////////////////////////////

//////////////////////////////Regist Factory class Method Start////////////////////////////////////

/**
 Regist layout factory
 */
+ (void)registLayoutFactoryClassName:(NSString *)layoutFactoryClassName;

/**
 Regist itemModel factory
 */
+ (void)registItemModelFactoryClassName:(NSString *)itemModelFactoryClassName;

/**
 Regist element factory
 */
+ (void)registElementFactoryClassName:(NSString *)elementFactoryClassName;

////////////////////////////////Regist Factory class Method end/////////////////////////////////////

@end

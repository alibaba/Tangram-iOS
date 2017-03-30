//
//  TangramDataSourceHelper.h
//  TmallClient4iOS-Tangram
//
//  Copyright © 2015 tmall.com. All rights reserved.
//
//  There are three main functions in TangramDataSourceHelper
//  1. JSON to Layout
//  2. JSON to model
//  3. Model to element
//  Three functions executed by three generator. These three generator can be replaced.

#import <Foundation/Foundation.h>
#import "TangramItemModelProtocol.h"
#import "TangramLayoutProtocol.h"
#import "TangramBus.h"
#import "TangramLayoutFactoryProtocol.h"
#import "TangramItemModelFactoryProtocol.h"
#import "TangramElementFactoryProtocol.h"



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
 *  @param UIView element can be reused
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
+(NSObject<TangramItemModelProtocol> *)modelWithDictionary : (NSDictionary *)dict;
/**
 *  Generate models by NSDictionary array
 *
 *  @param dictArray
 *
 *  @return NSArray
 */
+(NSArray *)modelsWithDictArray : (NSArray *)dictArray;
/////////////////////////////////Core Class Method end/////////////////////////////////////////////


/////////////////////////////////Method will be depracated/////////////////////////////////////////

+(UIView<TangramLayoutProtocol> *)layoutWithDictionary: (NSDictionary *)dict;

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

/**
 Quick merge layout Data to another layout.

 @param layout Origin Layout
 @param dict An NSDictionary contains data to merged, it should be a NSDictionary for layout.
 @param tangramBus Tangram Event Bus
 @return Layout merged by a origin layout instance and an NSDictionary of a layout.
 */
+ (UIView<TangramLayoutProtocol> *)fillLayoutProperty :(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict tangramBus:(TangramBus *)tangramBus;

//////////////////////////////////Other Helper method end//////////////////////////////////////////

//////////////////////////////Regist Factory class Method Start////////////////////////////////////

/**
 Regist layout factory

 @param layoutFactoryClassName
 */
+ (void)registLayoutFactoryClassName:(NSString *)layoutFactoryClassName;

/**
 Regist itemModel factory

 @param itemModelFactoryClassName
 */
+ (void)registItemModelFactoryClassName:(NSString *)itemModelFactoryClassName;

/**
 Regist element factory

 @param elementFactoryClassName
 */
+ (void)registElementFactoryClassName:(NSString *)elementFactoryClassName;
////////////////////////////////Regist Factory class Method end/////////////////////////////////////
@end

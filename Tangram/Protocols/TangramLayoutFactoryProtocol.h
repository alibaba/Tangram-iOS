//
//  TangramLayoutFactoryProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramLayoutProtocol.h"
@protocol TangramLayoutFactoryProtocol <NSObject>

@required
/**
 Generate a layout by a dictionary

 @return layout
 */
+ (UIView<TangramLayoutProtocol> *)layoutByDict:(NSDictionary *)dict;



@optional

/**
 Return class name by type to ItemModelFactory
 in order to support nesting of layout
 
 @return layout class
 */
+ (NSString *)layoutClassNameByType:(NSString *)type;
/**
 Regist Layout Type and its className
 
 @param type is TangramLayoutType In TangramLayoutProtocol
 */
+ (void)registLayoutType:(NSString *)type className:(NSString *)layoutClassName;

/**
 Preprocess DataArray from original Array
 if implement this method in the layout factory, helper will call this methid in `layoutsWithArray`

 @return preprocess in originalarray
 */
+ (NSArray *)preprocessedDataArrayFromOriginalArray:(NSArray *)originalArray;

@end

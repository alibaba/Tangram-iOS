//
//  TangramLayoutFactoryProtocol.h
//  Tangram
//
//  Created by xiaoxia on 2017/1/9.
//
//

#import <Foundation/Foundation.h>
#import "TangramLayoutProtocol.h"
@protocol TangramLayoutFactoryProtocol <NSObject>

@required
/**
 Generate a layout by a dictionary

 @param dict
 @return layout
 */
+ (UIView<TangramLayoutProtocol> *)layoutByDict:(NSDictionary *)dict;



@optional

/**
 Return class name by type to ItemModelFactory
 in order to support nesting of layout
 
 @param type
 @return layout class
 */
+ (NSString *)layoutClassNameByType:(NSString *)type;
/**
 Regist Layout Type and its className
 
 @param type is TangramLayoutType In TangramLayoutProtocol
 @param layoutClassName
 */
+ (void)registLayoutType:(NSString *)type className:(NSString *)layoutClassName;

/**
 Preprocess DataArray from original Array
 if implement this method in the layout factory, helper will call this methid in `layoutsWithArray`

 @param originalArray
 @return preprocess in originalarray
 */
+ (NSArray *)preprocessedDataArrayFromOriginalArray:(NSArray *)originalArray;

@end

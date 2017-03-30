//
//  TangramItemModelFactoryProtocol.h
//  Tangram
//
//  Created by xiaoxia on 2017/1/9.
//
//

#import <Foundation/Foundation.h>
#import "TangramItemModelProtocol.h"

@protocol TangramItemModelFactoryProtocol <NSObject>

@required

/**
 Generate itemModel by a dictionary

 @param dict
 @return itemModel
 */
+ (NSObject<TangramItemModelProtocol> *)itemModelByDict:(NSDictionary *)dict;
/**
 Regist Element
 
 @param type In ItemModel we need return a itemType, the itemType will be used here
 @param elementClassName
 */
+ (void)registElementType:(NSString *)type className:(NSString *)elementClassName;
@end

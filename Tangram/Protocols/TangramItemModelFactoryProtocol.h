//
//  TangramItemModelFactoryProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
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

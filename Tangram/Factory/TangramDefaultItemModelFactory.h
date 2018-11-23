//
//  TangramDefaultItemModelFactory.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramItemModelFactoryProtocol.h"
#import "TangramDefaultItemModel.h"

@interface TangramDefaultItemModelFactory : NSObject<TangramItemModelFactoryProtocol>

+ (TangramDefaultItemModel *)praseDictToItemModel:(TangramDefaultItemModel *)itemModel dict:(NSDictionary *)dict;

@end

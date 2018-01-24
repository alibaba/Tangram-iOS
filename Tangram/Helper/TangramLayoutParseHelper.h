//
//  TangramLayoutParseHelper.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramLayoutProtocol.h"

@interface TangramLayoutParseHelper : NSObject

//Config layout property
+ (UIView<TangramLayoutProtocol> *)layoutConfigByOriginLayout:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict;

@end

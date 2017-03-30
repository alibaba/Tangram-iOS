//
//  TangramLayoutParseHelper.h
//  Pods
//
//  Created by xiaoxia on 2017/1/3.
//
//

#import <Foundation/Foundation.h>
#import "TangramLayoutProtocol.h"

@interface TangramLayoutParseHelper : NSObject

//Config layout property
+ (UIView<TangramLayoutProtocol> *)layoutConfigByOriginLayout:(UIView<TangramLayoutProtocol> *)layout withDict:(NSDictionary *)dict;

@end

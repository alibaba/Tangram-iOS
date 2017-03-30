//
//  TangramElementReuseIdentifierProtocol.h
//  Pods
//
//  Created by xiaoxia on 2017/1/16.
//
//

#import <Foundation/Foundation.h>

@class TangramDefaultItemModel;
@protocol TangramElementReuseIdentifierProtocol <NSObject>

+ (NSString *)reuseIdByModel:(TangramDefaultItemModel *)itemModel;

@end

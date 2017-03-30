//
//  TangramElementHeightProtocol.h
//  Pods
//
//  Created by xiaoxia on 2017/1/16.
//
//

#import <Foundation/Foundation.h>

@class TangramDefaultItemModel;
@protocol TangramElementHeightProtocol <NSObject>

+ (CGFloat)heightByModel:(TangramDefaultItemModel *)itemModel;

@end

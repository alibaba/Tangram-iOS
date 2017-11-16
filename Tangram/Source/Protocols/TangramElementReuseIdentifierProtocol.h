//
//  TangramElementReuseIdentifierProtocol.h
//  Tangram
//
//  Copyright (c) 2015-2017 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramDefaultItemModel;


@protocol TangramElementReuseIdentifierProtocol <NSObject>

+ (NSString *)reuseIdByModel:(TangramDefaultItemModel *)itemModel;

@end

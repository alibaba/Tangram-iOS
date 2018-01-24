//
//  TangramElementReuseIdentifierProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramDefaultItemModel;


@protocol TangramElementReuseIdentifierProtocol <NSObject>

+ (NSString *)reuseIdByModel:(TangramDefaultItemModel *)itemModel;

@end

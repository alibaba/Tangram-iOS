//
//  TangramBusIndex.h
//  Tangram
//
//  Copyright (c) 2016-2017 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramAction;

@interface TangramBusIndex : NSObject

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier;
- (NSArray *)actionsOnEvent:(TangramEvent *)event;

@end



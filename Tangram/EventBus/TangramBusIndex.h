//
//  TangramBusIndex.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramAction;

@interface TangramBusIndex : NSObject

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier;
- (NSArray *)actionsOnEvent:(TangramEvent *)event;

@end



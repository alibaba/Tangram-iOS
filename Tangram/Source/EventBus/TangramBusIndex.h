//
//  TangramBusIndex.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramAction;
@protocol TangramBusIndexProtocol <NSObject>

@required
- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier;
- (NSArray *)actionsOnEvent:(TangramEvent *)event;

@end

@interface TangramBusIndex : NSObject<TangramBusIndexProtocol>

@end

@class TangramEvent;
@class TangramContext;
@interface TangramAction : NSObject

@property   (nonatomic, weak)               id                  target;
@property   (nonatomic, unsafe_unretained)  SEL                 selector;
@property   (nonatomic, strong)             dispatch_queue_t    executeQueue;

- (void)executeWithContext:(TangramContext *)context;

@end

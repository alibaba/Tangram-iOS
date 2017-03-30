//
//  TangramEventQueue.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramEventQueue.h"
#import "TangramEvent.h"
#import "TangramSafeMethod.h"

@interface TangramEventQueue ()

@property   (nonatomic, strong) NSMutableArray      *queue;

@end

@implementation TangramEventQueue

#pragma mark - Getter & Setter
- (NSMutableArray *)queue
{
    if (nil == _queue) {
        _queue = [[NSMutableArray alloc] init];
    }
    return _queue;
}

#pragma mark - Public
- (NSUInteger)length
{
    return [self.queue count];
}

- (void)pushEvent:(TangramEvent *)event
{
    if ([event isKindOfClass:[TangramEvent class]]) {
        [self.queue tgrm_addObjectCheck:event];
    }
}

- (TangramEvent *)pop
{
    if (![self.queue isKindOfClass:[NSArray class]]) {
        return nil;
    }
    TangramEvent *firstEvent = [self.queue firstObject];
    if (firstEvent) {
        [self.queue removeObjectAtIndex:0];
    }
    return firstEvent;
}

@end

//
//  TangramEventQueue.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramEventQueue.h"
#import "TangramEvent.h"

@interface TangramEventQueue ()

@property (nonatomic, strong) NSMutableArray *queue;

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
        [self.queue addObject:event];
    }
}

- (TangramEvent *)popEvent
{
    if (self.length == 0) {
        return nil;
    }
    TangramEvent *firstEvent = [self.queue firstObject];
    if (firstEvent) {
        [self.queue removeObjectAtIndex:0];
    }
    if ([firstEvent isKindOfClass:[TangramEvent class]]) {
        return firstEvent;
    }
    return nil;
}

@end

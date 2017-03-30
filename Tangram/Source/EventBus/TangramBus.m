//
//  TangramBus.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramBus.h"
#import "TangramBusIndex.h"
#import "TangramEvent.h"
#import "TangramEventQueue.h"
#import "TangramEventDispatcher.h"

@interface TangramBus ()

@property   (nonatomic, strong) TangramEventQueue       *queue;
@property   (nonatomic, strong) dispatch_queue_t        saveConfigurationSerialQueue;
@property   (nonatomic, strong) TangramEventDispatcher  *dispatcher;

@end

@implementation TangramBus

#pragma mark - Private
- (void)dispatchEvent
{
    __weak typeof(self) wself = self;
    dispatch_async(self.saveConfigurationSerialQueue, ^{
        __strong typeof(wself) sself = wself;
        TangramEvent *event = [sself.queue pop];
        // 遍历之！
        while (event) {
            [sself.dispatcher dispatchEvent:event];
            event = [sself.queue pop];
        }
    });
}

#pragma mark - Getter & Setter
- (TangramEventDispatcher *)dispatcher
{
    if (nil == _dispatcher) {
        _dispatcher = [[TangramEventDispatcher alloc] init];
    }
    return _dispatcher;
}
//Default in main thread.
- (dispatch_queue_t)saveConfigurationSerialQueue
{
    return dispatch_get_main_queue();
}

- (TangramEventQueue *)queue
{
    if (nil == _queue) {
        _queue = [[TangramEventQueue alloc] init];
    }
    return _queue;
}

#pragma mark - Public
- (void)postEvent:(TangramEvent *)event
{
    [self.queue pushEvent:event];
    [self dispatchEvent];
}

- (void)registerAction:(NSString *)anAction ofExecuter:(id)executer onEventTopic:(NSString *)topic fromPosterIdentifier:(NSString *)identifier inQueue:(dispatch_queue_t)queue
{
    if (executer) {
        TangramAction *action = [[TangramAction alloc] init];
        action.target = executer;
        action.executeQueue = queue;
        if (anAction) {
            action.selector = NSSelectorFromString(anAction);
        }
        
        [self.dispatcher registerAction:action onEventTopic:topic andIdentifier:identifier];
    }
}

- (void)registerAction:(NSString *)anAction ofExecuter:(id)executer onEventTopic:(NSString *)topic fromPosterIdentifier:(NSString *)identifier
{
    [self registerAction:anAction ofExecuter:executer onEventTopic:topic fromPosterIdentifier:identifier inQueue:nil];
}

- (void)registerAction:(NSString *)action ofExecuter:(id)executer onEventTopic:(NSString *)topic
{
    [self registerAction:action ofExecuter:executer onEventTopic:topic fromPosterIdentifier:nil];
}

@end

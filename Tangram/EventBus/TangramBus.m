//
//  TangramBus.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramBus.h"
#import "TangramAction.h"
#import "TangramEvent.h"
#import "TangramEventQueue.h"
#import "TangramEventDispatcher.h"

@interface TangramBus ()

@property (nonatomic, strong) TangramEventQueue *queue;
@property (nonatomic, strong) TangramEventDispatcher *dispatcher;

@end

@implementation TangramBus

#pragma mark - Private
- (void)dispatchEvent
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = wself;
        TangramEvent *event = [sself.queue popEvent];
        while (event) {
            [sself.dispatcher dispatchEvent:event];
            event = [sself.queue popEvent];
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

- (void)registerAction:(NSString *)action
            ofExecuter:(id)executer
          onEventTopic:(NSString *)topic
{
    [self registerAction:action ofExecuter:executer onEventTopic:topic fromPosterIdentifier:nil];
}

- (void)registerAction:(NSString *)anAction
            ofExecuter:(id)executer
          onEventTopic:(NSString *)topic
  fromPosterIdentifier:(NSString *)identifier
{
    if (executer) {
        TangramAction *action = [[TangramAction alloc] init];
        action.target = executer;
        if (anAction && anAction.length > 0) {
            action.selector = NSSelectorFromString(anAction);
        }
        
        [self.dispatcher registerAction:action onEventTopic:topic andIdentifier:identifier];
    }
}

@end

//
//  TangramEventDispatcher.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramEventDispatcher.h"
#import "TangramAction.h"
#import "TangramEvent.h"
#import "TangramBusIndexClass.h"
#import "TangramBusIndexTopic.h"

@interface TangramEventDispatcher ()

@property (nonatomic, strong) TangramBusIndexClass *classIndex;
@property (nonatomic, strong) TangramBusIndexTopic *topicIndex;

@end

@implementation TangramEventDispatcher

#pragma mark - Public
- (void)dispatchEvent:(TangramEvent *)event
{
    NSMutableArray *actionList = [[NSMutableArray alloc] init];

    NSArray *topicActions = [self.topicIndex actionsOnEvent:event];
    if (topicActions && topicActions.count > 0) {
        [actionList addObjectsFromArray:topicActions];
    }
    
    NSArray *classActions = [self.classIndex actionsOnEvent:event];
    if (classActions && classActions.count > 0) {
        [actionList addObjectsFromArray:classActions];
    }

    for (TangramAction *action in actionList) {
        if (action && [action isKindOfClass:[TangramAction class]]) {
            [action executeWithContext:event.context];
        }
    }
}

- (void)registerAction:(TangramAction *)action onEventTopic:(NSString *)topic andIdentifier:(NSString *)identifier
{
    if (identifier && 0 < identifier.length) {
        [self.classIndex addAction:action forTopic:topic andPoster:identifier];
    } else {
        [self.topicIndex addAction:action forTopic:topic andPoster:nil];
    }
}

#pragma mark - Getter * Setter
- (TangramBusIndexClass *)classIndex
{
    if (nil == _classIndex) {
        _classIndex = [[TangramBusIndexClass alloc] init];
    }
    return _classIndex;
}

- (TangramBusIndexTopic *)topicIndex
{
    if (nil == _topicIndex) {
        _topicIndex = [[TangramBusIndexTopic alloc] init];
    }
    return _topicIndex;
}

@end

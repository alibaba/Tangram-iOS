//
//  TangramEventDispatcher.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramEventDispatcher.h"
#import "TangramEvent.h"
#import "TangramBusIndexClass.h"
#import "TangramBusIndexTopic.h"

@interface TangramEventDispatcher ()

@property   (nonatomic, strong) TangramBusIndexClass        *classIndex;
@property   (nonatomic, strong) TangramBusIndexTopic        *topicIndex;

@end

@implementation TangramEventDispatcher

#pragma mark - Public
- (void)dispatchEvent:(TangramEvent *)event
{
    // 在索引里查找Acton
    NSMutableArray *actionList = [[NSMutableArray alloc] init];

    NSArray *topicActions = [self.topicIndex actionsOnEvent:event];
    if (topicActions) {
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
    }
    else {
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

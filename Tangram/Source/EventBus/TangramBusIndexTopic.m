//
//  TangramBusIndexTopic.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramBusIndexTopic.h"
#import "TangramEvent.h"
#import "TangramSafeMethod.h"

@interface TangramBusIndexTopic ()

@property   (nonatomic, strong) NSMutableDictionary     *index;

@end

@implementation TangramBusIndexTopic

- (NSMutableDictionary *)index
{
    if (nil == _index) {
        _index = [[NSMutableDictionary alloc] init];
    }
    return _index;
}

- (NSArray *)actionsOnEvent:(TangramEvent *)event
{
    return [self.index tgrm_arrayForKey:event.topic];
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
    NSMutableArray *mutableActions = nil;
    NSArray *actions = [self.index tgrm_arrayForKey:topic];
    if (nil == actions) {
        mutableActions = [[NSMutableArray alloc] init];
    }
    else if ([actions isKindOfClass:[NSMutableArray class]]) {
        mutableActions = (NSMutableArray *)actions;
    }
    else if ([actions isKindOfClass:[NSArray class]]) {
        mutableActions = [actions mutableCopy];
    }
    else {
        mutableActions = [[NSMutableArray alloc] init];
    }
    [mutableActions tgrm_addObjectCheck:action];
    [self.index tgrm_setObjectCheck:mutableActions forKey:topic];
}

@end

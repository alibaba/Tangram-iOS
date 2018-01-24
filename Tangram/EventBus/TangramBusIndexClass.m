//
//  TangramBusIndexClass.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramBusIndexClass.h"
#import "TangramEvent.h"
#import "TMUtils.h"


@interface TangramBusIndexClass ()

@property (nonatomic, strong) NSMutableDictionary *index;

@end

@implementation TangramBusIndexClass

- (NSMutableDictionary *)index
{
    if (nil == _index) {
        _index = [[NSMutableDictionary alloc] init];
    }
    return _index;
}

- (NSArray *)actionsOnEvent:(TangramEvent *)event
{
    NSArray *actions = nil;
    if (event.identifier) {
        NSString *key = [event.topic stringByAppendingFormat:@"_%@", event.identifier];
        actions = [self.index tm_arrayForKey:key];
    }
    return actions;
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
    if (identifier && 0 < identifier.length) {
        NSString *key = [topic stringByAppendingFormat:@"_%@", identifier];
        NSMutableArray *actions = [self.index tm_safeObjectForKey:key class:[NSMutableArray class]];
        if (nil == actions) {
            actions = [[NSMutableArray alloc] init];
        }
        [actions tm_safeAddObject:action];
        [self.index tm_safeSetObject:actions forKey:key];
    }
}

@end

//
//  TangramBusIndexTopic.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramBusIndexTopic.h"
#import "TangramEvent.h"
#import "TMUtils.h"

@interface TangramBusIndexTopic ()

@property (nonatomic, strong) NSMutableDictionary *index;

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
    return [self.index tm_arrayForKey:event.topic];
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
    NSMutableArray *actions = [self.index tm_safeObjectForKey:topic class:[NSMutableArray class]];
    if (nil == actions) {
        actions = [[NSMutableArray alloc] init];
    }
    [actions tm_safeAddObject:action];
    [self.index tm_safeSetObject:actions forKey:topic];
}

@end

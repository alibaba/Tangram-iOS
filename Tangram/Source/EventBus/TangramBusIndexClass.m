//
//  TangramBusIndexClass.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramBusIndexClass.h"
#import "TangramEvent.h"
#import "TangramSafeMethod.h"


@interface TangramBusIndexClass ()

@property   (nonatomic, strong) NSMutableDictionary     *index;

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
        actions = [self.index tgrm_arrayForKey:key];
    }
    return actions;
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
    NSMutableArray *mutableActions = nil;
    if (identifier && 0 < identifier.length) {
        NSString *key = [topic stringByAppendingFormat:@"_%@", identifier];
        NSArray *actions = [self.index tgrm_arrayForKey:key];
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
        [self.index setObject:mutableActions forKey:key];
    }
}

@end

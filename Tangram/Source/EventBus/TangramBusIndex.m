//
//  TangramBusIndex.m
//  Tangram
//
//  Copyright (c) 2016-2017 Taobao lnc. All rights reserved.
//

#import "TangramBusIndex.h"
#import "TangramEvent.h"
#import "TangramAction.h"

@implementation TangramBusIndex

- (NSArray *)actionsOnEvent:(TangramEvent *)event
{
    return nil;
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
}

@end


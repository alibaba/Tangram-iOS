//
//  TangramEventDispatcher.h
//  Tangram
//
//  Copyright (c) 2016-2017 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramAction;


@interface TangramEventDispatcher : NSObject

- (void)registerAction:(TangramAction *)action onEventTopic:(NSString *)topic andIdentifier:(NSString *)identifier;
- (void)dispatchEvent:(TangramEvent *)event;

@end

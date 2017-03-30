//
//  TangramEventDispatcher.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramAction;
@interface TangramEventDispatcher : NSObject

- (void)registerAction:(TangramAction *)action onEventTopic:(NSString *)topic andIdentifier:(NSString *)identifier;
- (void)dispatchEvent:(TangramEvent *)event;

@end

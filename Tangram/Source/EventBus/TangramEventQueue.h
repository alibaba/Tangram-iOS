//
//  TangramEventQueue.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@interface TangramEventQueue : NSObject

/**
 * The length of the event queue.
 */
- (NSUInteger)length;

/**
 * Add a event to queue.
 */
- (void)pushEvent:(TangramEvent *)event;

/**
 * Get a event
 */
- (TangramEvent *)pop;

@end

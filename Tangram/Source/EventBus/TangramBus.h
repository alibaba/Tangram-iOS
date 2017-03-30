//
//  TangramBus.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;
@class TangramContext;
@protocol TangramActionProtocol <NSObject>

- (void)executeWithContext:(nonnull TangramContext *)context;

@end

@interface TangramBus : NSObject

/**
 * Post a event to eventbus
 * 
 * @param   TangramEvent    event
 */
- (void)postEvent:(nonnull TangramEvent *)event;
/**
 * Regist an action to some event. Action will be executed in main thread.
 *
 * @param   NSString    action      the name of executing method
 * @param   NSString    executer    a instance
 * @param   NSString    event       event topic
 */
- (void)registerAction:(nonnull NSString *)action ofExecuter:(nonnull id)executer onEventTopic:(nonnull NSString *)topic;
/**
 * Regist an action to some event. Action will be executed in main thread.
 *
 * @param   NSString    action      the name of executing method
 * @param   NSString    executer    a instance
 * @param   NSString    event       event topic
 * @param   NSString    identifier  the identifier of poster
 */
- (void)registerAction:(nonnull NSString *)action ofExecuter:(nonnull id)executer onEventTopic:(nonnull NSString *)topic fromPosterIdentifier:(nullable NSString *)identifier;

/**
 * Regist an action to some event
 *
 * @param   NSString    action      the name of executing method
 * @param   NSString    executer    a instance
 * @param   NSString    event       event topic
 * @param   NSString    identifier  the identifier of poster
 * @param   dispatch_queue_t    queue  the queue of action
 */
- (void)registerAction:(nonnull NSString *)action ofExecuter:(nonnull id)executer onEventTopic:(nonnull NSString *)topic fromPosterIdentifier:(nullable NSString *)identifier inQueue:(nullable dispatch_queue_t)queue;



@end

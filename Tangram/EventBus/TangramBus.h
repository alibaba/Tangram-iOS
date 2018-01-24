//
//  TangramBus.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramEvent;


@interface TangramBus : NSObject

/**
 * Post a event to eventbus
 * 
 * @param   event   TangramEvent    event
 */
- (void)postEvent:(nonnull TangramEvent *)event;

/**
 * Regist an action to some event. Action will be executed in main thread.
 *
 * @param   action      NSString    the name of executing method
 * @param   executer    NSString    a instance or class name
 * @param   topic       NSString    event topic
 */
- (void)registerAction:(nonnull NSString *)action
            ofExecuter:(nonnull id)executer
          onEventTopic:(nonnull NSString *)topic;

/**
 * Regist an action to some event. Action will be executed in main thread.
 *
 * @param   action      NSString    the name of executing method
 * @param   executer    NSString    a instance or class name
 * @param   topic       NSString    event topic
 * @param   identifier  NSString    the identifier of poster
 */
- (void)registerAction:(nonnull NSString *)action
            ofExecuter:(nonnull id)executer
          onEventTopic:(nonnull NSString *)topic
  fromPosterIdentifier:(nullable NSString *)identifier;

@end

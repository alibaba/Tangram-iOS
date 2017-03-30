//
//  TangramEvent.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramContext;
@class TangramView;
@interface TangramEvent : NSObject

/**
 * Event Topic
 */
@property   (nonnull, nonatomic, copy, readonly)     NSString        *topic;

/**
 * the id of sponsor.
 */
@property   (nullable, nonatomic, copy, readonly)     NSString        *identifier;

/**
 * context, it contains the weak reference of TangramView, event instance, and poster.
 */
@property   (nonnull, nonatomic, strong, readonly)   TangramContext  *context;

/**
 * Business Params
 */
- (nullable NSDictionary *)params;

/**
 * Meta Params
 */
- (nullable NSDictionary *)meta;

/**
 * Add a param to business params(can be read from params)
 */
- (void)setParam:(nonnull id)param forKey:(nonnull NSString *)key;

/**
 * Add a param to meta params(can be read from meta)
 */
- (void)setMeta:(nonnull id)param forKey:(nonnull NSString *)key;

/**
 * Generate a context instance
 * @param   TangramView tangram     TangramView
 * @param   NSString    topic       Event topic
 * @param   NSString    identifier  The id of poster
 * @param   id          poster      The instance of poster
 */
- (nonnull instancetype)initWithTopic:(nonnull NSString *)topic withTangramView:(nonnull TangramView *)tangram posterIdentifier:(nullable NSString *)identifier andPoster:(nonnull id)poster;

@end

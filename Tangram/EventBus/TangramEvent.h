//
//  TangramEvent.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TangramEventTopicJumpAction   @"openUrl"

@class TangramContext;
@class TangramView;


@interface TangramEvent : NSObject

/**
 * Event Topic.
 */
@property (nonnull, nonatomic, copy, readonly) NSString *topic;

/**
 * The id of sponsor.
 */
@property (nullable, nonatomic, copy, readonly) NSString *identifier;

/**
 * Context, it contains the weak reference of TangramView, event instance, and poster.
 */
@property (nonnull, nonatomic, strong, readonly) TangramContext *context;

/**
 * Business Params.
 */
- (nullable NSDictionary *)params;

/**
 * Meta Params.
 */
- (nullable NSDictionary *)meta;

/**
 * Add a param to business params (can be read from params)
 */
- (void)setParam:(nonnull id)param forKey:(nonnull NSString *)key;

/**
 * Add a param to meta params (can be read from meta)
 */
- (void)setMeta:(nonnull id)param forKey:(nonnull NSString *)key;

/**
 * Generate a context instance
 *
 * @param   tangram     TangramView     Tangram instance
 * @param   topic       NSString        Event topic
 * @param   identifier  NSString        The id of poster
 * @param   poster      id              The instance of poster
 */
- (nonnull instancetype)initWithTopic:(nonnull NSString *)topic
                      withTangramView:(nullable TangramView *)tangram
                     posterIdentifier:(nullable NSString *)identifier
                            andPoster:(nonnull id)poster;

@end

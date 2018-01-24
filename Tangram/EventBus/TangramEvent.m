//
//  TangramEvent.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramEvent.h"
#import "TangramContext.h"
#import "TangramView.h"
#import "TMUtils.h"

@interface TangramEvent () {
    NSMutableDictionary *_params;
    NSMutableDictionary *_meta;
}

@end

@implementation TangramEvent

#pragma mark - Getter & Setter
- (NSDictionary *)params
{
    return _params ? [_params copy] : nil;
}

- (NSDictionary *)meta
{
    return _meta ? [_meta copy] : nil;
}

- (void)setParam:(id)param forKey:(NSString *)key
{
    if (nil == _params) {
        _params = [[NSMutableDictionary alloc] init];
    }
    [_params tm_safeSetObject:param forKey:key];
}

- (void)setMeta:(id)meta forKey:(NSString *)key
{
    if (nil == _meta) {
        _meta = [[NSMutableDictionary alloc] init];
    }
    [_meta tm_safeSetObject:meta forKey:key];
}

#pragma mark - Public

- (instancetype)initWithTopic:(NSString *)topic
              withTangramView:(TangramView *)tangram
             posterIdentifier:(NSString *)identifier
                    andPoster:(id)poster
{
    self = [super init];
    if (self) {
        _topic = topic;
        _identifier = identifier;
        _context = [[TangramContext alloc] init];
        _context.poster = poster;
        _context.tangram = tangram;
        _context.event = self;
    }
    return self;
}

@end

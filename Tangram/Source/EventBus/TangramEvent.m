//
//  TangramEvent.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramEvent.h"
#import "TangramContext.h"
#import "TangramSafeMethod.h"

@interface TangramEvent ()

@property   (nonatomic, strong) NSDictionary            *params;
@property   (nonatomic, strong) NSDictionary            *meta;

@property   (nonatomic, strong) NSMutableDictionary     *mParams;
@property   (nonatomic, strong) NSMutableDictionary     *mMeta;

@end

@implementation TangramEvent

#pragma mark - Getter & Setter
- (NSDictionary *)params
{
    if (nil == _params) {
        _params = [NSDictionary dictionaryWithDictionary:_mParams];
    }
    return _params;
}

- (NSDictionary *)meta
{
    if (nil == _meta) {
        _meta = [NSDictionary dictionaryWithDictionary:self.mMeta];
    }
    return _meta;
}

- (void)setParam:(id)param forKey:(NSString *)key
{
    if (nil == _mParams) {
        _mParams = [[NSMutableDictionary alloc] init];
    }
    if (param && key) {
        [_mParams setObject:param forKey:key];
    }
    _params = [NSDictionary dictionaryWithDictionary:_mParams];
}

- (void)setMeta:(id)meta forKey:(NSString *)key
{
    if (nil == _mMeta) {
        _mMeta = [[NSMutableDictionary alloc] init];
    }
    if (meta && key) {
        [_mMeta setObject:meta forKey:key];
    }
    _meta = [NSDictionary dictionaryWithDictionary:_mMeta];
}

#pragma mark - Public
- (instancetype)initWithTopic:(NSString *)topic withTangramView:(TangramView *)tangram
             posterIdentifier:(NSString *)identifier andPoster:(id)poster
{
    self = [super init];
    if (self) {
        _topic      = topic;
        _identifier = identifier;
        _context = [[TangramContext alloc] init];
        _context.poster     = poster;
        _context.tangram    = tangram;
        //增加一个对event的反向依赖，可以通过context找到event，event是weak的
        _context.event = self;
    }
    return self;
}

@end

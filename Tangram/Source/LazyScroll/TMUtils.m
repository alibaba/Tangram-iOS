//
//  TMUtils.m
//  LazyScrollView
//
//  Copyright (c) 2017 tmall. All rights reserved.
//

#import "TMUtils.h"

@implementation NSArray (TMUtil)

- (id)tm_safeObjectAtIndex:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

@end

@implementation NSMutableArray (TMUtil)

- (void)tm_safeAddObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

@end

@implementation NSDictionary (TMUtil)

- (id)tm_safeObjectForKey:(id)key
{
    if (key == nil) {
        return nil;
    }
    id value = [self objectForKey:key];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (id)tm_safeObjectForKey:(id)key class:(Class)aClass
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}

- (NSInteger)tm_integerForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSArray *)tm_arrayForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSArray class]];
}

@end

@implementation NSMutableDictionary (TMUtil)

- (void)tm_safeSetObject:(id)anObject forKey:(id)key
{
    if (key == nil || anObject == nil) {
        return;
    }
    [self setObject:anObject forKey:key];
}

@end

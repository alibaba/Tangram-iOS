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

- (id)tm_safeObjectAtIndex:(NSUInteger)index class:(Class)aClass
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}

- (bool)tm_boolAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (CGFloat)tm_floatAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}

- (NSInteger)tm_integerAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSString *)tm_stringAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSString class]];
}

- (NSDictionary *)tm_dictionaryAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSDictionary class]];
}

- (NSArray *)tm_arrayAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSArray class]];
}

@end

@implementation NSMutableArray (TMUtil)

- (void)tm_safeAddObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

- (void)tm_safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject && index <= self.count) {
        [self insertObject:anObject atIndex:index];
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

- (bool)tm_boolForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (CGFloat)tm_floatForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}

- (NSInteger)tm_integerForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSString *)tm_stringForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSString class]];
}

- (NSDictionary *)tm_dictionaryForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSDictionary class]];
}

- (NSArray *)tm_arrayForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSArray class]];
}

- (id)tm_safeValueForKey:(NSString *)key
{
    return [self tm_safeObjectForKey:key];
}

- (void)tm_safeSetValue:(id)value forKey:(NSString *)key
{
    if (key && [key isKindOfClass:[NSString class]]) {
        [self setValue:value forKey:key];
    }
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

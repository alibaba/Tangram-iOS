//
//  TangramSafeMethod.m
//  Pods
//
//  Created by xiaoxia on 2017/1/11.
//
//
#import "TangramSafeMethod.h"

@implementation TangramSafeMethod

@end

@implementation NSMutableDictionary (TangramSafeMethod)

/**
 If value or key is nil, here will not crash
 
 @param value
 @param key
 */
- (void)tgrm_setObjectCheck:(id)value forKey:(id)key
{
    if (key == nil || value == nil) {
        return;
    }
    [self setObject:value forKey:key];
}

@end

@implementation NSDictionary (TangramSafeMethod)

/**
 Check the key whether is NSNull,if it is NSNull, here will return nil
 
 @param aKey key
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key
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


/**
 Check the key whether it is desiredClass, if no or get nil, return defaultValue
 
 @param aKey
 @param aClass
 @param defaultValue
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass
{
    id value = [self tgrm_objectForKeyCheck:key];
    if (![value isKindOfClass:aClass]) {
        return nil;
    }
    return value;
}
/**
 Check the key whether it is desiredClass, if no or get nil, return defaultValue
 
 @param aKey
 @param aClass
 @param defaultValue
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue
{
    id value = [self tgrm_objectForKeyCheck:key];
    if (![value isKindOfClass:aClass]) {
        return defaultValue;
    }
    return value;
}

/**
 Check the key whether it's true, support NSNumber and NSString , defaultValue is NO
 
 @param key key
 @return BOOL YES/NO
 */
- (BOOL)tgrm_boolForKey:(id)key
{
     return [self tgrm_boolForKey:key defaultValue:NO];
}

/**
 Check the key whether it's true, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (BOOL)tgrm_boolForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    else {
        return defaultValue;
    }
}

/**
 Check the key whether it's true, support NSNumber and NSString , defaultValue is NO
 
 @param key key
 @return BOOL YES/NO
 */
- (CGFloat)tgrm_floatForKey:(id)key
{
    return [self tgrm_floatForKey:key defaultValue:0.f];
}

/**
 Check the key whether it's true, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (CGFloat)tgrm_floatForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    else {
        return defaultValue;
    }

}

/**
 Check the key whether it's true, support NSNumber and NSString , defaultValue is NO
 
 @param key key
 @return BOOL YES/NO
 */
- (NSInteger)tgrm_integerForKey:(id)key
{
    return [self tgrm_integerForKey:key defaultValue:0];
}

/**
 Check the key whether it's true, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (NSInteger)tgrm_integerForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    else {
        return defaultValue;
    }
}

/**
 Check the key whether it's NSString or the subclass of NSString, defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSString *)tgrm_stringForKey:(id)key
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}
/**
 Check the key whether it's NSDictionary or the subclass of NSDictionary , defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSDictionary *)tgrm_dictionaryForKey:(id)key
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}
/**
 Check the key whether it's NSArray or the subclass of NSArray , defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSArray *)tgrm_arrayForKey:(id)key
{
    id value = [self tgrm_objectForKeyCheck:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

@end

@implementation NSArray (TangramSafeMethod)

/**
 Check the key of index whether it is NSNull,if it is NSNull, here will return nil
 
 @param index
 @return value
 */
- (id)tgrm_objectAtIndexCheck:(NSUInteger)index
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

/**
 Check the key whether it is desiredClass, if no or get nil, return nil
 
 @param aKey
 @param aClass
 @return value
 */
- (id)tgrm_objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass
{
    id value = [self tgrm_objectAtIndexCheck:index];
    if (![value isKindOfClass:aClass]) {
        return nil;
    }
    return value;
}

/**
 Check the key whether it is desiredClass, if no or get nil, return defaultValue
 
 @param aKey
 @param aClass
 @param defaultValue
 @return value
 */
- (id)tgrm_objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue
{
    id value = [self tgrm_objectAtIndexCheck:index];
    if (![value isKindOfClass:aClass]) {
        return defaultValue;
    }
    return value;
}


/**
 add object to Array
 if object is nil or array is not NSMutableArray, here won't crash.
 
 @param object
 */
- (void)tgrm_addObjectCheck:(id)object
{
    if ([self isKindOfClass:[NSMutableArray class]] && nil != object) {
        [(NSMutableArray *)self addObject:object];
    }
}
- (CGFloat)tgrm_floatAtIndex:(NSUInteger)index
{
    id value = [self tgrm_objectAtIndexCheck:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0.f;
}


- (NSDictionary *)tgrm_dictionaryAtIndex:(NSUInteger)index
{
    id value = [self tgrm_objectAtIndexCheck:index];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSString *)tgrm_stringAtIndex:(NSUInteger)index
{
    id value = [self tgrm_objectAtIndexCheck:index];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}
@end

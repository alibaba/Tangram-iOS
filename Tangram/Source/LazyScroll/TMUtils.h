//
//  TMUtils.h
//  LazyScrollView
//
//  Copyright (c) 2017 tmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TMUtil)

- (id)tm_safeObjectAtIndex:(NSUInteger)index;
- (id)tm_safeObjectAtIndex:(NSUInteger)index class:(Class)aClass;

- (bool)tm_boolAtIndex:(NSUInteger)index;
- (CGFloat)tm_floatAtIndex:(NSUInteger)index;
- (NSInteger)tm_integerAtIndex:(NSUInteger)index;
- (NSString *)tm_stringAtIndex:(NSUInteger)index;
- (NSDictionary *)tm_dictionaryAtIndex:(NSUInteger)index;
- (NSArray *)tm_arrayAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (TMUtil)

- (void)tm_safeAddObject:(id)anObject;

@end

@interface NSDictionary (TMUtil)

- (id)tm_safeObjectForKey:(id)key;
- (id)tm_safeObjectForKey:(id)key class:(Class)aClass;

- (bool)tm_boolForKey:(id)key;
- (CGFloat)tm_floatForKey:(id)key;
- (NSInteger)tm_integerForKey:(id)key;
- (NSString *)tm_stringForKey:(id)key;
- (NSDictionary *)tm_dictionaryForKey:(id)key;
- (NSArray *)tm_arrayForKey:(id)key;

- (id)tm_safeValueForKey:(NSString *)key;
- (void)tm_safeSetValue:(id)value forKey:(NSString *)key;

@end

@interface NSMutableDictionary (TMUtil)

- (void)tm_safeSetObject:(id)anObject forKey:(id)key;

@end

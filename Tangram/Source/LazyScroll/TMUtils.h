//
//  TMUtils.h
//  LazyScrollView
//
//  Copyright (c) 2017 tmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TMUtil)

- (id)tm_safeObjectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (TMUtil)

- (void)tm_safeAddObject:(id)anObject;

@end

@interface NSDictionary (TMUtil)

- (id)tm_safeObjectForKey:(id)key;
- (id)tm_safeObjectForKey:(id)key class:(Class)aClass;
- (NSInteger)tm_integerForKey:(id)key;

@end

@interface NSMutableDictionary (TMUtil)

- (void)tm_safeSetObject:(id)anObject forKey:(id)key;

@end

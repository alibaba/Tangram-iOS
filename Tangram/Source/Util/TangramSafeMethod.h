//
//  TangramSafeMethod.h
//  Pods
//
//  Created by xiaoxia on 2017/1/11.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TangramSafeMethod : NSObject


@end

@interface NSMutableDictionary (TangramSafeMethod)

/**
 If value or key is nil, here will not crash
 
 @param value
 @param key
 */
- (void)tgrm_setObjectCheck:(id)value forKey:(id)key;
@end

@interface NSDictionary (TangramSafeMethod)



/**
 Check the key whether is NSNull,if it is NSNull, here will return nil

 @param aKey key
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key;
/**
 Check the key whether it is desiredClass, if no or get nil, return nil
 
 @param aKey
 @param aClass
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass;

/**
  Check the key whether it is desiredClass, if no or get nil, return defaultValue

 @param aKey
 @param aClass
 @param defaultValue
 @return value
 */
- (id)tgrm_objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue;

/**
 Check the key whether it's true, support NSNumber and NSString , defaultValue is NO

 @param key key
 @return BOOL YES/NO
 */
- (BOOL)tgrm_boolForKey:(id)key;

/**
 Check the key whether it's true, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (BOOL)tgrm_boolForKey:(id)key defaultValue:(BOOL)defaultValue;
/**
 Check the key whether it's float value, support NSNumber and NSString , defaultValue is 0
 
 @param key key
 @return BOOL YES/NO
 */
- (CGFloat)tgrm_floatForKey:(id)key;

/**
 Check the key whether it's float value, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (CGFloat)tgrm_floatForKey:(id)key defaultValue:(BOOL)defaultValue;
/**
 Check the key whether it's integer value, support NSNumber and NSString , defaultValue is 0
 
 @param key key
 @return BOOL YES/NO
 */
- (NSInteger)tgrm_integerForKey:(id)key;

/**
 Check the key whether it's integer value, support NSNumber and NSString, you can customize defaultValue
 
 @param key key
 @return BOOL YES/NO
 */
- (NSInteger)tgrm_integerForKey:(id)key defaultValue:(BOOL)defaultValue;

/**
 Check the key whether it's NSString or the subclass of NSString, defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSString *)tgrm_stringForKey:(id)key;
/**
 Check the key whether it's NSDictionary or the subclass of NSDictionary , defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSDictionary *)tgrm_dictionaryForKey:(id)key;
/**
 Check the key whether it's NSArray or the subclass of NSArray , defaultValue is nil
 
 @param key key
 @return BOOL YES/NO
 */
- (NSArray *)tgrm_arrayForKey:(id)key;


@end


@interface NSArray (TangramSafeMethod)

/**
 Check the key of index whether it is NSNull,if it is NSNull, here will return nil

 @param index
 @return value
 */
- (id)tgrm_objectAtIndexCheck:(NSUInteger)index;

/**
 Check the key whether it is desiredClass, if no or get nil, return defaultValue
 
 @param aKey
 @param aClass
 @param defaultValue
 @return value
 */
- (id)tgrm_objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue;


/**
 add object to Array 
 if object is nil or array is not NSMutableArray, here won't crash.

 @param object
 */
- (void)tgrm_addObjectCheck:(id)object;


/**
 Get a float value from Array by index
 if object is not a NSNumber/NSString , here will return nil.
 
 @param object
 */
- (CGFloat)tgrm_floatAtIndex:(NSUInteger)index;

/**
 Get a NSDictionary value from Array by index
 if object is not a NSDictionary , here will return nil
 @param object
 */
- (NSDictionary *)tgrm_dictionaryAtIndex:(NSUInteger)index;

/**
 Get a NSDictionary value from Array by index
 if object is not a NSstring , here will return nil
 @param object
 */
- (NSString *)tgrm_stringAtIndex:(NSUInteger)index;

@end


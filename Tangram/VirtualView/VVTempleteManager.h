//
//  VVTempleteManager.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TangramBus;
@interface VVTempleteManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *templeteHeightDict;

@property (nonatomic, strong) NSMutableDictionary *templeteRatioDict;

/**
 用于更新模板的时候向外面发消息用
 */
@property (nonatomic, weak) TangramBus *tangramBus;

/**
 获取Manager单例

 @return Manager单例
 */
+ (VVTempleteManager*)sharedInstance;

/**
 加载缓存模板，这个方法目前只在初始化的时候执行一次

 */
- (void)registCacheTemplete;

/**
 读取本地模板
 */
- (void)loadCachedTemplete;

/**
 获取目前已有的组件列表

 @return 组件列表，Array里面是String
 */
- (NSArray *)elementList;

/**
 获取组件高度

 @param elementType 组件type
 @return  组件高度
 */
- (CGFloat)heightByElementType:(NSString *)elementType;


- (CGFloat)ratioByElementType:(NSString *)elementType;
/**
 获取某个组件的本地使用版本

 @param elementType 组件type
 @return 本地使用版本
 */
- (NSString *)localVersionByElementType:(NSString *)elementType;

@end

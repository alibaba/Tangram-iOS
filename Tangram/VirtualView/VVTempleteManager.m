//
//  VVTempleteManager.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

//  这个里面维持的内容有：全量组件列表，打底组件列表对应的文件名，下发组件对应的文件名
//  NativeCache映射关系: NSDictionary : key  type  value : dictionary-> version/filePath/sign

#define VVBundleName @"VVTempleteBundle"
#define APPMONITOR_MODULE @"VirtualView"
#import "VVTempleteManager.h"
#import <TMUtils/TMUtils.h>
#import "VVBinaryLoader.h"
#import "TangramDefaultDataSourceHelper.h"
#import "TangramEvent.h"
#import <VirtualView/VVTemplateManager.h>

@interface VVTempleteManager()

@property (nonatomic, strong) NSDictionary *localTempleteDict;

@property (nonatomic, strong) NSMutableArray *templeteVersionArray;

@property (nonatomic, strong) NSMutableDictionary *templeteVersionDict;

@end

@implementation VVTempleteManager

+ (VVTempleteManager*)sharedInstance
{
    static VVTempleteManager *_vvTempleteManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _vvTempleteManager = [[VVTempleteManager alloc] init];
    });
    return _vvTempleteManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self loadCachedTemplete];
    }
    return self;
}

- (NSArray *)elementList
{
    return [self.localTempleteDict allKeys];
}

- (NSMutableArray *)templeteVersionArray
{
    if (nil == _templeteVersionArray) {
        _templeteVersionArray = [[NSMutableArray alloc]init];
    }
    return _templeteVersionArray;
}

- (NSMutableDictionary *)templeteVersionDict
{
    if (nil == _templeteVersionDict) {
        _templeteVersionDict = [[NSMutableDictionary alloc]init];
    }
    return _templeteVersionDict;
}

- (NSMutableDictionary *)templeteHeightDict
{
    if (nil == _templeteHeightDict)
    {
        _templeteHeightDict = [[NSMutableDictionary alloc]init];
    }
    return _templeteHeightDict;
}

- (NSMutableDictionary *)templeteRatioDict
{
    if (nil == _templeteRatioDict)
    {
        _templeteRatioDict = [[NSMutableDictionary alloc]init];
    }
    return _templeteRatioDict;
}

- (void)loadCachedTemplete
{
    //获取本地全量组件列表
    [self readLocalTempleteDict];
    [self registCacheTemplete];
}

//获取全量组件列表
- (void)readLocalTempleteDict
{
    NSMutableDictionary *localTempleteDict = [[NSMutableDictionary alloc]init];
    //目前来说，先获取TangramKit的全量组件列表，把type拿出来
    //从 TangramKitVVElementTypeMap.plist里面拿
    NSString *vvElementMapPath = [[NSBundle mainBundle] pathForResource:@"TangramKitVVElementTypeMap" ofType:@"plist"];
    NSArray *vvElementArrayFromPlist = [NSArray arrayWithContentsOfFile:vvElementMapPath];
    for (NSDictionary *dict in vvElementArrayFromPlist) {
        NSString *key = [dict tm_stringForKey:@"type"];
        if (key.length == 0) {
            continue;
        }
        NSString *fileName = [dict tm_stringForKey:@"fileName"];
        NSString *height = [dict tm_stringForKey:@"height"];
        NSString *ratio = [dict tm_stringForKey:@"ratio"];
        if (fileName.length > 0) {
            [localTempleteDict tm_safeSetObject:fileName forKey:key];
        }
        if (height.length > 0) {
            [self.templeteHeightDict tm_safeSetObject:height forKey:key];
        }
        if(ratio.length > 0)
        {
            [self.templeteRatioDict tm_safeSetObject:ratio forKey:key];
        }
    }
    //返回本地组件列表
    self.localTempleteDict = localTempleteDict;
}


- (void)registCacheTemplete
{
    //获取全量组件列表,来源：本地内置 + 网络请求后存在NativeCache的列表
    NSArray *elementList = [self.localTempleteDict allKeys];
    for (NSString *templeteType in elementList) {
        NSMutableDictionary *templeteVersionDict = [[NSMutableDictionary alloc]init];
        [templeteVersionDict tm_safeSetObject:templeteType forKey:@"type"];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        //如果是本地的模板的话，直接version = 1
        NSString *localFileName = [self.localTempleteDict tm_stringForKey:templeteType];
        NSString* localPath =[[NSBundle mainBundle] pathForResource:localFileName ofType:@"out"];
        if (localFileName.length > 0 && localPath.length > 0 && [fileManager fileExistsAtPath:localPath]) {
            [[VVTemplateManager sharedManager] loadTemplateFileAsync:localPath forType:templeteType completion:nil];
            [templeteVersionDict tm_safeSetObject:@"1" forKey:@"version"];
            [self.templeteVersionDict tm_safeSetObject:@"1" forKey:templeteType];
            [self.templeteVersionArray tm_safeAddObject:templeteVersionDict];
            //作为预置本地组件，默认已经做过注册，不再注册了
            //[TangramDataSourceHelper registElementType:templeteType className:@"TMVVBaseElement"];
        }
    }
}

/**
 当模板发生变化时，需要把所有的模板清空之后重新加载
 */
- (void)reloadTemplete
{
    [self loadCachedTemplete];
    TangramEvent *event = [[TangramEvent alloc]initWithTopic:@"reloadDataByHelper" withTangramView:nil posterIdentifier:nil andPoster:self];
    [self.tangramBus postEvent:event];
}

- (CGFloat)heightByElementType:(NSString *)elementType
{
    return [self.templeteHeightDict tm_floatForKey:elementType];
}

- (CGFloat)ratioByElementType:(NSString *)elementType
{
    return [self.templeteRatioDict tm_floatForKey:elementType];
}

- (NSString *)localVersionByElementType:(NSString *)elementType
{
    NSString *version = [self.templeteVersionDict tm_stringForKey:elementType];
    if (version == nil || version.length <= 0) {
        //0 其实就是异常了
        version = @"0";
    }
    return version;
}

@end

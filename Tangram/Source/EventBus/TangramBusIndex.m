//
//  TangramBusIndex.m
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import "TangramBusIndex.h"
#import "TangramEvent.h"
#import "TangramContext.h"
#import "TangramBus.h"
#import "TangramSafeMethod.h"

@implementation TangramBusIndex

- (NSArray *)actionsOnEvent:(TangramEvent *)event
{
    return nil;
}

- (void)addAction:(TangramAction *)action forTopic:(NSString *)topic andPoster:(NSString *)identifier
{
}

@end

@implementation TangramAction

- (void)executeWithContext:(TangramContext *)context
{
    // 默认Protocol里的那个方法
    if (nil == self.selector) {
        self.selector = @selector(executeWithContext:);
    }
    if (self.target && [self.target respondsToSelector:self.selector]) {
        // 默认主线程
        if (nil == self.executeQueue) {
            self.executeQueue = dispatch_get_main_queue();
        }
        
        // context里的几个属性都是week的，所以在下边的gcd异步执行之前（当前函数执行结束）就已经被干掉了
        // 所以这里用一个holder持有一下这些可能被干掉的东西，然后在gcd方法里调用个空方法管理释放。
        __block NSMutableArray *holder = [[NSMutableArray alloc] init];
        if (context.event) {
            [holder tgrm_addObjectCheck:context.event];
        }
        if (context.poster) {
            [holder tgrm_addObjectCheck:context.poster];
        }
        if (context.tangram) {
            [holder tgrm_addObjectCheck:context.tangram];
        }

        __weak typeof(self) wself = self;
        dispatch_async(self.executeQueue, ^{
            __strong typeof(wself) sself = wself;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [sself.target performSelector:sself.selector withObject:context];

            // 调用这个空方法，目的是在生命周期里持有holder和holder持有的东西
            // 这个方法执行完，holder和holder持有的东西就会被干掉了
            [sself releaseThings:holder];
#pragma clang diagnostic pop
        });
    }
}

- (void)releaseThings:(NSArray *)array
{
    // For holding the items in array.
}

@end

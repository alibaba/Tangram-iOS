//
//  TangramAction.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramAction.h"
#import "TangramContext.h"
#import "TMUtils.h"

@implementation TangramAction

- (void)executeWithContext:(TangramContext *)context
{
    if (NULL == self.selector) {
        self.selector = @selector(executeWithContext:);
    }
    if (self.target && [self.target respondsToSelector:self.selector]) {
        // Properties of context are weak properties，so we use a holder to holder them.
        // Make sure they will not be released in dispatch body.
        __block NSMutableArray *holder = [[NSMutableArray alloc] init];
        if (context.event) {
            [holder tm_safeAddObject:context.event];
        }
        if (context.poster) {
            [holder tm_safeAddObject:context.poster];
        }
        if (context.tangram) {
            [holder tm_safeAddObject:context.tangram];
        }
        
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = wself;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [sself.target performSelector:sself.selector withObject:context];
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

//
//  UIView+Tangram.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <VirtualView/UIView+VirtualView.h>
#import "TangramView.h"


@implementation UIView (Tangram)

- (TangramView *)inTangramView
{
    for (UIView *next = [self superview]; next; next = next.superview) {
        if ([next isKindOfClass:[TangramView class]]) {
            return (TangramView *)next;
        }
    }
    return nil;
}

@end

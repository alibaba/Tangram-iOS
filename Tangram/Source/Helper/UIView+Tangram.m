//
//  UIView+Tangram.m
//  Pods
//
//  Created by xiaoxia on 16/8/23.
//
//

#import "UIView+Tangram.h"
#import "TangramView.h"

@implementation UIView(Tangram)

- (TangramView *)inTangramView
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        if ([next isKindOfClass:[TangramView class]]) {
            return (TangramView *)next;
        }
    }
    return nil;
}

@end

//
//  UIView+Tangram.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TangramView;


@interface UIView (Tangram)

/**
 * Get outer TangramView for UIView
 */
- (TangramView *)inTangramView;

@end

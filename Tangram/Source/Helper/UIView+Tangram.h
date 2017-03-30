//
//  UIView+Tangram.h
//  Pods
//
//  Created by xiaoxia on 16/8/23.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TangramView;
@interface UIView(Tangram)

// Get outer TangramView for UIView
- (TangramView *)inTangramView;

@end

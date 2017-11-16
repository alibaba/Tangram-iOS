//
//  TangramYosemiteEventDelegate.h
//  Tangram
//
//  Copyright (c) 2015-2017 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TangramDefaultItemModel;


@protocol TangramDefaultEventDelegate <NSObject>

@required

- (void)elementClicked:(UIView *)element itemModel:(TangramDefaultItemModel *)itemModel action:(NSString *)action userInfo:(NSDictionary *)userInfo;

@optional

- (void)elementExposure:(UIView *)element itemModel:(TangramDefaultItemModel *)itemModel;

@end

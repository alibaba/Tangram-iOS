//
//  TangramDefaultEventDelegate.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
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

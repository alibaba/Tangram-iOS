//
//  TangramContext.h
//  Tangram
//
//  Copyright (c) 2016-2017 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramView;
@class TangramEvent;


@interface TangramContext : NSObject

@property (nonatomic, weak) id poster;
@property (nonatomic, weak) TangramView *tangram;
@property (nonatomic, weak) TangramEvent *event;

@end

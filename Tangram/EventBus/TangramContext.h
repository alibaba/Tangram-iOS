//
//  TangramContext.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramView;
@class TangramEvent;


@interface TangramContext : NSObject

@property (nonatomic, weak) id poster;
@property (nonatomic, weak) TangramView *tangram;
@property (nonatomic, weak) TangramEvent *event;

@end

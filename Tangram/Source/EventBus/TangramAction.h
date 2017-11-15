//
//  TangramAction.h
//  Tangram
//
//  Copyright (c) 2016-2017 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramContext;


@protocol TangramActionProtocol <NSObject>

- (void)executeWithContext:(nonnull TangramContext *)context;

@end

@interface TangramAction : NSObject

@property (nonatomic, weak, nullable) id target;
@property (nonatomic, assign, nullable) SEL selector;

- (void)executeWithContext:(nonnull TangramContext *)context;

@end

//
//  TangramEasyElementProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramDefaultItemModel.h"
#import "TangramDefaultEventDelegate.h"
#import "TangramLayoutProtocol.h"
#import "TangramBus.h"


@protocol TangramEasyElementProtocol <NSObject>

@required

//Get itemModel
- (TangramDefaultItemModel *)tangramItemModel;
//Set itemModel
- (void)setTangramItemModel: (TangramDefaultItemModel *)tangramItemModel;

@optional

// delegate
- (id<TangramDefaultEventDelegate>)tangramEventDelegate;
- (void)setTangramEventDelegate: (id<TangramDefaultEventDelegate>)delegate;

// Bind layout
- (void)setAtLayout: (UIView<TangramLayoutProtocol> *)layout;
- (UIView<TangramLayoutProtocol> *)atLayout;

// Bind TangramBus
- (void)setTangramBus:(TangramBus *)tangramBus;

- (void)buildControlNameByPrefix:(NSString *)prefix extraArgs:(NSDictionary *)args;

- (void)setReadCacheInMainThread:(BOOL)mainThread;

- (void)buildContent:(BOOL)shouldReload;

@end

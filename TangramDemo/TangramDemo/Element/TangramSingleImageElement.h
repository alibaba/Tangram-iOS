//
//  TangramSingleImageElement.h
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//
#import <UIkit/UIkit.h>
#import "TangramElementHeightProtocol.h"
#import "TMMuiLazyScrollView.h"
#import "TangramDefaultItemModel.h"
#import "TangramEasyElementProtocol.h"

@interface TangramSingleImageElement : UIControl<TangramElementHeightProtocol,TMMuiLazyScrollViewCellProtocol,TangramEasyElementProtocol>

@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, weak) TangramDefaultItemModel *tangramItemModel;

@property (nonatomic, weak) UIView<TangramLayoutProtocol> *atLayout;

@property (nonatomic, weak) TangramBus *tangramBus;

@property (nonatomic, strong) NSString *action;

@end

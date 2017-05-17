//
//  TangramSingleImageElement.h
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/26.
//  Copyright © 2015年 tmall.com. All rights reserved.
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

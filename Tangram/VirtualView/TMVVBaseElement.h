//
//  TMVVBaseElement.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <VirtualView/VVViewFactory.h>
#import <VirtualView/VVBinaryLoader.h>
#import <VirtualView/VVViewContainer.h>
#import "TangramElementReuseIdentifierProtocol.h"
#import "TangramElementHeightProtocol.h"
#import "TangramEasyElementProtocol.h"
#import "TangramDefaultItemModel.h"
#import "TangramBus.h"

@interface TMVVBaseElement : UIView <TangramElementReuseIdentifierProtocol, TangramEasyElementProtocol, TangramElementHeightProtocol>
@property(nonatomic, strong)VVViewContainer* contentView;
@property(nonatomic, assign)BOOL disableCache;
@property   (nonatomic, strong) TangramDefaultItemModel        *tangramItemModel;
@property   (nonatomic, weak)   TangramBus                      *tangramBus;

//实际用来刷新vv的内容
@property(nonatomic, strong)NSMutableDictionary *vvDict;

- (void)calculateLayout;

@end

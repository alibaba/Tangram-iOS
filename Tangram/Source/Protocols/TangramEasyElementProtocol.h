//
//  TangramEasyElementProtocol.h
//  Pods
//
//  Created by xiaoxia on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TangramDefaultItemModel.h"
#import "TangramLayoutProtocol.h"
@class TangramBus;

@protocol TangramEasyElementProtocol <NSObject>

@required
//Get itemModel
- (TangramDefaultItemModel *)tangramItemModel;
//Set itemModel
- (void)setTangramItemModel: (TangramDefaultItemModel *)tangramItemModel;

@optional

// Bind layout
- (void)setAtLayout: (UIView<TangramLayoutProtocol> *)layout;
- (UIView<TangramLayoutProtocol> *)atLayout;

// Bind TangramBus
- (void)setTangramBus:(TangramBus *)tangramBus;

@end

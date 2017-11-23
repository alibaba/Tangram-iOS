//
//  TMVVBaseElement.h
//  Pods
//
//  Created by nigel on 2017/5/17.
//
//

#import "VVViewFactory.h"
#import "VVBinaryLoader.h"
#import "VVViewContainer.h"
#import "TangramElementReuseIdentifierProtocol.h"
#import "TangramDefaultItemModel.h"
#import "TangramBus.h"

@interface TMVVBaseElement : UIView <TangramElementReuseIdentifierProtocol>
@property(nonatomic, strong)VVViewContainer* contentView;
@property(nonatomic, assign)BOOL disableCache;
@property   (nonatomic, strong) TangramDefaultItemModel        *itemModel;
@property   (nonatomic, weak)   TangramBus                      *tangramBus;

//实际用来刷新vv的内容
@property(nonatomic, strong)NSMutableDictionary *vvDict;
@end

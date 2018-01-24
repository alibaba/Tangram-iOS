//
//  TangramStickyLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#define TangramStickyEnterEvent @"TangramStickyEnterEvent"

#import "TangramItemModelProtocol.h"
#import "TangramLayoutProtocol.h"

@interface TangramStickyLayout : UIView<TangramLayoutProtocol>
//默认NO吸顶 YES吸底 
@property (nonatomic, assign) BOOL stickyBottom;
//暂未启用 -- 吸顶/吸底的终结Layoutid
//@property (nonatomic, assign) NSString *endLayoutId;
//记录原始的高度,为TangramView内部判断而准备
@property (nonatomic, assign) CGFloat originalY;
//是否进入"吸"的状态，为TangramView内部判断而准备
@property (nonatomic, assign) BOOL enterFloatStatus;
// Margin  top, right, bottom, left的顺序, 接收NSNumber / NSString
@property (nonatomic, strong) NSArray         *margin;
// Models数组，Protocol要求的
@property (nonatomic, strong) NSArray         *itemModels;
//针对吸顶但是需要离顶端/底端一定距离的情况，增加一个可设定的值
@property (nonatomic, assign) CGFloat extraOffset;
@property (nonatomic, weak)   TangramBus            *tangramBus;

@property   (nonatomic, assign) CGFloat             zIndex;

@end

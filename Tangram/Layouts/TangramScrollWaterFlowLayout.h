//
//  TangramScrollWaterFlowLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramWaterFlowLayout.h"
#import "TangramScrollLayoutProtocol.h"

@interface TangramScrollWaterFlowLayout : TangramWaterFlowLayout<TangramScrollLayoutProtocol>

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) CGFloat offsetToLoadingView;
@property (nonatomic, assign) BOOL disableScroll;

@property (nonatomic, assign) NSInteger pagingIndex;
@property (nonatomic, assign) NSInteger pagingLength;


@end

//
//  TangramSimpleTextElement.h
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TangramElementHeightProtocol.h"
#import <LazyScroll/TMLazyScrollView.h>
#import <TMLazyItemViewProtocol.h>

@interface TangramSimpleTextElement : UIView<TangramElementHeightProtocol,TMLazyItemViewProtocol>

@property (nonatomic, strong) NSString *text;

@end

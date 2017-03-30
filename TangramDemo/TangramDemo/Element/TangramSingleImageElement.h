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

@interface TangramSingleImageElement : UIView<TangramElementHeightProtocol,TMMuiLazyScrollViewCellProtocol>

@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSNumber *number;

@end

//
//  TangramSimpleTextElement.h
//  TangramDemo
//
//  Created by xiaoxia on 2017/3/7.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TangramElementHeightProtocol.h"
#import "TMMuiLazyScrollView.h"

@interface TangramSimpleTextElement : UIView<TangramElementHeightProtocol,TMMuiLazyScrollViewCellProtocol>

@property (nonatomic, strong) NSString *text;

@end

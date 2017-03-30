//
//  TangramSingleAndDoubleLayout.h
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/19.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramFlowLayout.h"

@interface TangramSingleAndDoubleLayout : TangramFlowLayout

// The ratio of the upper and lower lines.
// Only read first two element. Two elements added up should be 100
// The type of element in `rows` can be NSString or NSNumber
@property (nonatomic, strong) NSArray *rows;

@end

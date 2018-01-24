//
//  TangramSingleAndDoubleLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramFlowLayout.h"

@interface TangramSingleAndDoubleLayout : TangramFlowLayout

// The ratio of the upper and lower lines.
// Only read first two element. Two elements added up should be 100
// The type of element in `rows` can be NSString or NSNumber
@property (nonatomic, strong) NSArray *rows;

@end

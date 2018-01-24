//
//  TangramScrollLayoutProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ScrollLayoutDidMoveToPage @"ScrollFlowLayoutDidMoveToPage"
#define ScrollLayoutCaptureImage @"ScrollLayoutCaptureImage"
@protocol TangramScrollLayoutProtocol <NSObject>

@required

@property (nonatomic, assign) NSInteger pagingIndex;
@property (nonatomic, assign) NSInteger pagingLength;

@end

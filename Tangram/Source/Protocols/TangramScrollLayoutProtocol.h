//
//  TangramScrollLayoutProtocol.h
//  Pods
//
//  Created by xiaoxia on 2017/2/6.
//
//

#import <Foundation/Foundation.h>
#define ScrollLayoutDidMoveToPage @"ScrollFlowLayoutDidMoveToPage"
#define ScrollLayoutCaptureImage @"ScrollLayoutCaptureImage"
@protocol TangramScrollLayoutProtocol <NSObject>

@required

@property (nonatomic, assign) NSInteger pagingIndex;
@property (nonatomic, assign) NSInteger pagingLength;

@end

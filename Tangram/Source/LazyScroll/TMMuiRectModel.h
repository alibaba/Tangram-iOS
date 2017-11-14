//
//  TMMuiRectModel.h
//  LazyScrollView
//
//  Copyright (c) 2017 tmall. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 It is a view model that holding information of view.
 At least holding absRect and muiID.
 */
@interface TMMuiRectModel : NSObject

// A rect that relative to the scroll view.
@property (nonatomic,assign) CGRect absRect;
// A uniq string that identify a model.
@property (nonatomic,copy) NSString *muiID;

@end

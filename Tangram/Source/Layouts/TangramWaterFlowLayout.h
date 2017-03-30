//
//  TangramWaterFlowLayout.h
//  Pods
//
//  Created by xiaoxia on 15/12/12.
//
//

#import <UIKit/UIKit.h>
#import "TangramLayoutProtocol.h"
@interface TangramWaterFlowLayout : UIView<TangramLayoutProtocol>

// Models Array , as protocol request.
@property (nonatomic, strong) NSArray               *itemModels;
// Number of columns.
@property (nonatomic, assign) NSUInteger            numberOfColumns;
// Percentage number of every cols
@property (nonatomic, strong) NSArray               *cols;
// Aspect ratio of every row
@property (nonatomic, strong) NSString              *aspectRatio;
// Margin , the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property (nonatomic, strong) NSArray               *margin;
// Gap in horizontal direction
@property (nonatomic, assign) CGFloat               hGap;
// Gap in vertical direction
@property (nonatomic, assign) CGFloat               vGap;
// Element width
@property (nonatomic, assign, readonly) CGFloat     cellWidth;

@property (nonatomic, weak)   TangramBus            *tangramBus;

@property (nonatomic, assign) TangramLayoutLoadType  loadType;

@property (nonatomic, strong) NSString               *layoutLoadAPI;

@end

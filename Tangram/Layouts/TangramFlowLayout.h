//
//  TangramFlowLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TangramLayoutProtocol.h"
#import "TangramView.h"
typedef NS_ENUM(NSUInteger,TangramFlowLayoutBgImageScaleType)
{
    TangramFlowLayoutBgImageScaleTypeFitXY = 0,
    TangramFlowLayoutBgImageScaleTypeFitStart
};
@interface TangramFlowLayout : UIView<TangramLayoutProtocol>

// Models Array , as protocol request.
@property   (nonatomic, strong) NSArray         *itemModels;
// Number of columns.The default value is 1.
@property   (nonatomic, assign) NSUInteger      numberOfColumns;
// Percentage number of every cols
@property   (nonatomic, strong) NSArray         *cols;
// Aspect ratio of every row
@property   (nonatomic, strong) NSString        *aspectRatio;
// Margin , the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property   (nonatomic, strong) NSArray         *margin;
// Padding ,  the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property   (nonatomic, strong) NSArray         *padding;
// Gap in horizontal direction
@property   (nonatomic, assign) CGFloat          hGap;
// Gap in vertical direction
@property   (nonatomic, assign) CGFloat          vGap;
// Only for first row,if `autoFill` is true，flowlayout will change the number of columns to fill a row,
// when the count of `itemModels` less than the number of columns
@property   (nonatomic, assign) BOOL             autoFill;
//id
@property   (nonatomic, strong) NSString        *layoutLoadAPI;
// Background Image View
@property   (nonatomic, strong) UIImageView     *bgImageView;
// Background ImageUrl
@property   (nonatomic, strong) NSString        *bgImgURL;
// TangramBus
@property   (nonatomic, weak)   TangramBus      *tangramBus;

@property   (nonatomic, weak)   TangramView     *tangramView;
// Background ImageView scale.
@property   (nonatomic, assign) TangramFlowLayoutBgImageScaleType bgScaleType;
// Params for LoadAPI
@property   (nonatomic, strong) NSDictionary          *loadParams;

@property   (nonatomic, assign) TangramLayoutLoadType loadType;

@property   (nonatomic, strong) NSDictionary    *subLayoutDict;

@property   (nonatomic, strong) NSArray         *subLayoutIdentifiers;

@property   (nonatomic, assign) BOOL enableMarginDeduplication;

@property   (nonatomic, assign) CGFloat zIndex;

@property   (nonatomic, assign) BOOL disableUserInteraction;

@property   (nonatomic, assign) BOOL enableInnerZIndexLayout;

@end

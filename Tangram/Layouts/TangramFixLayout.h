//
//  TangramFixLayout.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TangramLayoutProtocol.h"
typedef NS_ENUM(NSInteger, FixAlignType)
{
    TopLeft = 0,
    TopRight,
    BottomLeft,
    BottomRight
};
typedef NS_ENUM(NSInteger, FixShowType)
{
    //Always Show
    FixLayoutShowAlways = 0,
    //Show before the previous layout enter
    FixLayoutShowOnEnter,
    //Show before the previous layout leave
    FixLayoutShowOnLeave
};

typedef NS_ENUM(NSInteger, TangramFixAppearanceType)
{
    //Default inline
    TangramFixAppearanceInline = 0,
    //Scroll Type
    TangramFixAppearanceScroll,
};
@interface TangramFixLayout : UIView<TangramLayoutProtocol>

// Models Array , as protocol request.
@property   (nonatomic, strong) NSArray         *itemModels;
// Margin , the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property   (nonatomic, strong) NSArray         *margin;
// Padding ,  the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property   (nonatomic, strong) NSArray         *padding;
//@property   (nonatomic, assign) CGFloat         originalY;
// offset in horizontal direction
@property   (nonatomic, assign) CGFloat         offsetX;
// offset in vertical direction
@property   (nonatomic, assign) CGFloat         offsetY;
// Align type, four corner of the scrollview
@property   (nonatomic, assign) FixAlignType    alignType;

@property   (nonatomic, assign) FixShowType     showType;

@property   (nonatomic, assign) CGPoint         originPoint;
// Vertical position to show.
@property   (nonatomic, assign) CGFloat         showY;

@property   (nonatomic, weak)   TangramBus      *tangramBus;

@property   (nonatomic, assign) TangramFixAppearanceType appearanceType;

// Gap in horizontal direction (Only for `TangramFixAppearanceScroll` alignType)
@property   (nonatomic, assign) CGFloat          hGap;
// Animation Duration for enter and leave time (Only in FixLayoutShowOnEnter and FixLayoutShowOnLeave AlignType)
@property   (nonatomic, assign) CGFloat         animationDuration;
// Whether enable alpha effect  for enter and leave time (Only in FixLayoutShowOnEnter and FixLayoutShowOnLeave AlignType)
@property   (nonatomic, assign) BOOL            enableAlphaEffect;
// Whether retain scroll position (Only for TangramFixAppearanceScroll)
@property   (nonatomic, assign) BOOL            retainScrollState;

@property   (nonatomic, assign) CGFloat             zIndex;

@end

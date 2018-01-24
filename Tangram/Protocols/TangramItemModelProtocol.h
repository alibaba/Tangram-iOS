//
//  TangramItemModelProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NSString TangramItemType;

@protocol TangramItemModelProtocol <NSObject>

@required

// This property is used for layout to change the frame of itemModel.
@property (nonatomic, assign) CGRect itemFrame;

// model type
- (TangramItemType *)itemType;

// Reuseidentifier for LazyscrollView ,
- (NSString *)reuseIdentifier;

// Margin Top/Right/Bottom/Right
- (CGFloat)marginTop;
- (CGFloat)marginRight;
- (CGFloat)marginBottom;
- (CGFloat)marginLeft;

// Like `display` in CSS. if `display` return 'block' , element will fill the whole row in flowlayout.
- (NSString *)display;

@optional

// Absolute Rect
@property (nonatomic, assign) CGRect absRect;
// MuiID for LazyScrollView
@property (nonatomic, strong) NSString *muiID;

////////////////For nested cards(Experimental function, only for FlowLayout and PageScrollLayout)
// Layout identifier(if the model is for nested card)
@property (nonatomic, strong) NSString *layoutIdentifierForLayoutModel;
// Whether this model is for a nested card
@property (nonatomic, assign) BOOL innerItemModel;
// The identifier for the outer layout of this nested card
@property (nonatomic, strong) NSString *inLayoutIdentifier;
////////////////For nested cards end
// Binded element class name
@property (nonatomic, strong) NSString *linkElementName;
// Insert position for layout
-(NSString *)position;
// The number of colums an element will fill.
-(NSUInteger )colspan;
// Bound View ClassName, if has value, get height from view's static method
-(NSString *)linkElementClassName;

-(CGFloat )zIndex;

@end

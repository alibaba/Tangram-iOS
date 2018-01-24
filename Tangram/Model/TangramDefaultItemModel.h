//
//  TangramDefaultItemModel.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramItemModelProtocol.h"
#import "TMMuiLazyScrollView.h"

@interface TangramDefaultItemModel : TMMuiRectModel <TangramItemModelProtocol>

// type
@property (nonatomic, strong) NSString *type;
// Margin for layouts
@property (nonatomic, strong) NSArray *margin;
// If the value of `display` is block in FlowLayout, the view will be shown in a whole line.
@property (nonatomic, strong) NSString *display;
// Insert squence in layout
@property (nonatomic, strong) NSString *position;
// The number of occupying columns, Only use in FlowLayout .
@property (nonatomic, assign) NSUInteger colspan;
// AspectRatio for model.The priority of this property is below `heightFromStyle` and `widthFromStyle`
@property (nonatomic, assign) CGFloat modelAspectRatio;
// Height in style.This property is highest priority for height.
@property (nonatomic, assign) CGFloat heightFromStyle;
// Width in style. This property is highest priority for width.
@property (nonatomic, assign) CGFloat widthFromStyle;
// Height get from `TangramElementHeightProtocol`.
@property (nonatomic, assign) CGFloat heightFromElement;
// Index in layout.
@property (nonatomic, assign) NSUInteger index;
// Binded element(UIView or its subclass) classname.
@property (nonatomic, strong) NSString *linkElementName;
// Specific ReuseIdentifier
@property (nonatomic, strong) NSString *specificReuseIdentifier;
// Whether disable reuse.
@property (nonatomic, assign) BOOL disableReuse;
// Whether a model for nested card.(For nested card,experiment function)
@property (nonatomic, assign) BOOL innerItemModel;
// The identifier for the outer layout of this nested card.(For nested card,experiment function)
@property (nonatomic, strong) NSString *inLayoutIdentifier;
// Layout identifier(For nested card,experiment function)
@property (nonatomic, strong) NSString *layoutIdentifierForLayoutModel;

@property (nonatomic, assign) CGFloat zIndex;

- (NSArray *)bizKeys;

- (NSArray *)styleKeys;

- (void)setBizValue:(id)value forKey:(NSString *)key;

- (void)setStyleValue:(id)value forKey:(NSString *)key;

// Get a business param
- (id)bizValueForKey:(NSString *)key;
// Get a business param, if not match the desired class type, here will return nil.
- (id)bizValueForKey:(NSString *)key desiredClass:(__unsafe_unretained Class)aClass;
// Get a style param
- (id)styleValueForKey:(NSString *)key;
// Get a style param, if not match the desired class type, here will return nil.
- (id)styleValueForKey:(NSString *)key desiredClass:(__unsafe_unretained Class)aClass;

- (NSDictionary *)privateOriginalDict;

@end

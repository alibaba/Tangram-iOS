//
//  TangramLayoutProtocol.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TangramItemModelProtocol.h"
#import "TangramBus.h"

typedef NS_ENUM(NSInteger,TangramLayoutLoadType)
{
    TangramLayoutLoadTypeNone = 0 , //No Network request
    TangramLayoutLoadTypeLoadOnce = -1, //Request once
    TangramLayoutLoadTypeByPage = 1 //Request By Page
};
typedef NSString TangramLayoutType;


@protocol TangramLayoutProtocol <NSObject>

@required

- (TangramLayoutType *)layoutType;
// Contains itemModels
@property (nonatomic, strong) NSArray *itemModels;
// Weak reference for tangrambus
@property (nonatomic, weak) TangramBus *tangramBus;
// identifier for layout
@property (nonatomic, strong) NSString *identifier;
// Calculate itemModel position
- (void)calculateLayout;
- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model;
@optional

// Margin
- (CGFloat)marginTop;
- (CGFloat)marginRight;
- (CGFloat)marginBottom;
- (CGFloat)marginLeft;
// Position is for Layout like FixLayout to get fixed position
- (NSString *)position;
// loadAPI
- (NSString *)loadAPI;
- (TangramLayoutLoadType)loadType;
- (NSDictionary *)loadParams;

- (void)setSubLayoutIndex:(NSString *)layoutIndex;

- (void)setEnableMarginDeduplication:(BOOL)enableMarginDeduplication;

// Set Background Url
- (void)setBgImgURL:(NSString *)imgURL;

- (void)setHeaderItemModel:(NSObject<TangramItemModelProtocol> *)model;
- (NSObject<TangramItemModelProtocol> *)headerItemModel;
- (void)setFooterItemModel:(NSObject<TangramItemModelProtocol> *)model;
- (NSObject<TangramItemModelProtocol> *)footerItemModel;
- (void)addHeaderView:(UIView *)headerView;
- (void)addFooterView:(UIView *)footerView;
///////////////////////////////For nested cards(Experimental function, only for FlowLayout and PageScrollLayout)
// If a card want to support nested card, must implement these method
// return sub layouts,key is the identifier for some nested card，value is a nested layout(UIView or its subclass)
- (NSDictionary *)subLayoutDict;
- (void)setSubLayoutDict:(NSDictionary *)subLayouts;
// return identifiers of sub layouts.
- (NSArray *)subLayoutIdentifiers;
- (void)setSubLayoutIdentifiers:(NSString *)layoutIdentifier;
// To be layout.layer.zPosition
- (CGFloat)zIndex;
- (BOOL)disableUserInteraction;
- (void)addSubView:(UIView *)view withModel:(NSObject<TangramItemModelProtocol> *)model;
///////////////////////////////For nested cards end

@end



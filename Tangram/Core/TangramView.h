//
//  TangramView.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LazyScroll/TMMuiLazyScrollView.h>

@protocol TangramItemModelProtocol;
@protocol TangramLayoutProtocol;
@class TangramView;
@class TangramBus;


@protocol TangramViewDelegate <TMMuiLazyScrollViewDelegate>

@end

//****************************************************************

/**
 * Tangram get need info from datasource.
 */
@protocol TangramViewDatasource <NSObject>

@required

/**
 * return layout count in scrollView
 *
 * @param   view    TangramView
 * @return  number  Layout count in scrollView
 */
- (NSUInteger)numberOfLayoutsInTangramView:(TangramView *)view;

/**
 * return element(subviews in layout,like UICollectionViewCell) Count in specific card.
 *
 * @param   view    TangramView
 * @param   layout  layout return in element Count
 * @return  number  element in the layout
 */
- (NSUInteger)numberOfItemsInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout;

/**
 * Get a layout by index.
 * Tangram requires this Layout must be a subclass of UIView ，and implement TangramLayoutProtocol
 * Layout is like to Layout in UICollectionView
 *
 * @param   view    TangramView
 * @param   index   Layout index
 * @return  layout  layout
 */
- (UIView<TangramLayoutProtocol> *)layoutInTangramView:(TangramView *)view atIndex:(NSUInteger)index;

/**
 * Get element by index in layout. Element must be a UIView or a subclass of UIView
 * Before init a new element , you can call `dequeueReusableItemWithIdentifier` to get a reuseable view first.
 *
 * @param   view    TangramView
 * @param   layout  layout
 * @param   index   index in Layout
 * @return  item    element
 */
- (UIView *)itemInTangramView:(TangramView *)view withModel:(NSObject<TangramItemModelProtocol> *)model forLayout:(UIView<TangramLayoutProtocol> *)layout  atIndex:(NSUInteger)index;

/**
 * According to the count returned from `numberOfItemsInTangramView`, generate a logical tree of models.
 * Here need return model by index and layout.
 *
 * @param   view    TangramView
 * @param   layout  Layout
 * @param   index   index in layout
 * @return  model   model，used to generate logical tree.
 */
- (NSObject<TangramItemModelProtocol> *)itemModelInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index;

@end

//****************************************************************

@interface TangramView : TMMuiLazyScrollView

// Contains layouts in TangramView. Key ：layout index；value：layout
@property   (nonatomic, strong, readonly) NSMutableDictionary     *layoutDict;
// Extra offset in vertical for StickyLayout and FixLayout
@property   (nonatomic, assign) CGFloat fixExtraOffset;
// Bind TangramBus
@property   (nonatomic, weak)   TangramBus *tangramBus;
// Get FixLayout in TangramView
@property   (nonatomic, strong, readonly) NSMutableArray          *fixLayoutArray;
// Get StickyLayout in TangramView
@property   (nonatomic, strong, readonly) NSMutableArray          *stickyLayoutArray;
// Data source
@property   (nonatomic, weak, readonly)  id<TangramViewDatasource>       clDataSource;
// Enable margin deduplication function.
@property   (nonatomic, assign) BOOL enableMarginDeduplication;


- (void)setDataSource:(id<TangramViewDatasource>)dataSource;
// Refresh view according to datasource.
- (void)reloadData;
// When height of layer is changed and the model is not changed, call this method.
- (void)reLayoutContent;
// When only a specific layout height need to be changed , or models in some layout changed
// You can call this method to refresh a layout.
- (void)reloadLayout:(UIView<TangramLayoutProtocol> *)layout;
// Models in layout not changed but height need to be changed , call this method.
- (void)heightChanged;
// Clean layouts. If cleanElement is YES, here will clean inner element
// If cleanElement is NO, inner elements will be placed on the recycle pool.
- (void)removeLayoutsAndElements:(BOOL)cleanElement;
// Call this method when you need reset times in `mui_didEnterTimes`
- (void)resetLayoutEnterTimes;
// Set vertical offset to layouts below some specific layout
- (void)changeLayoutPositionBelowLayout:(UIView<TangramLayoutProtocol> *)layout offset:(CGFloat)offset;

@end

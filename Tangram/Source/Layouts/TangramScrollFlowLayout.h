//
//  TangramScrollFlowLayout.h
//  Pods
//
//  Created by xiaoxia on 15/12/17.
//
//

#import <UIKit/UIKit.h>
#import "TangramFlowLayout.h"
#import "TangramScrollLayoutProtocol.h"


@protocol TangramListPagingFlowLayoutDelegate <NSObject>

- (CGFloat)pagingListLayoutAbsY;

- (void)pagingListLayoutDidPaging:(NSInteger)pagingIndex;

- (void)pagingListLayoutMovingToNext;

- (void)pagingListLayoutMovingToPre;

@end

@interface TangramScrollFlowLayout : TangramFlowLayout<TangramScrollLayoutProtocol>

@property (nonatomic, weak) id<TangramListPagingFlowLayoutDelegate> pagingDelegate;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) CGFloat offsetToLoadingView;
@property (nonatomic, assign) BOOL disableScroll;

@property (nonatomic, assign) NSInteger pagingIndex;
@property (nonatomic, assign) NSInteger pagingLength;

@property (nonatomic, strong) NSArray *bgColors;


-(void)removeLoadingView;
@end

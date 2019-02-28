//
//  TangramWaterFlowLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramWaterFlowLayout.h"
#import "TangramItemModelProtocol.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import "TMUtils.h"
#import <VirtualView/UIView+VirtualView.h>

@interface TangramWaterFlowLayout()

@property (nonatomic, strong) NSString               *layoutIdentifier;
// 收到reload请求的次数
@property (atomic, assign   ) int                    numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign   ) NSTimeInterval         firstReloadRequestTS;
@property (nonatomic, strong) NSString               *bgImgURL;
@property (nonatomic, strong) UIImageView            *bgImageView;

// 每列对应的最底部的rectModel
@property (nonatomic, strong) NSMutableArray *columnsRectModels;


@end

@implementation TangramWaterFlowLayout

@synthesize itemModels  = _itemModels;
@synthesize cellWidth   = _cellWidth;


- (NSString *)identifier
{
    return self.layoutIdentifier;
}
-(void)setIdentifier:(NSString *)identifier
{
    self.layoutIdentifier = identifier;
}
//基础部分
- (TangramLayoutType *)layoutType
{
    return @"tangram_layout_waterFlow";
}

- (void)setItemModels:(NSArray *)itemModels
{
    NSMutableArray *toBeAddedItemModels = [[NSMutableArray alloc]init];
    NSMutableArray *mutableItemModels = [itemModels mutableCopy];
    for (NSObject<TangramItemModelProtocol> *model in mutableItemModels) {
        if ([model respondsToSelector:@selector(position)] &&  [[model position] isKindOfClass:[NSString class]] &&[model position].length > 0) {
            [toBeAddedItemModels tm_safeAddObject:model];
        }
    }
    for (NSObject<TangramItemModelProtocol> *model in toBeAddedItemModels) {
        [mutableItemModels removeObject:model];
        if ([[model position] integerValue] > mutableItemModels.count) {
            [mutableItemModels tm_safeInsertObject:model atIndex:mutableItemModels.count];
        }
        else{
            [mutableItemModels tm_safeInsertObject:model atIndex:[[model position] integerValue]];
        }
    }
    _itemModels = [mutableItemModels copy];
}
- (NSString *)position
{
    return @"";
}
- (NSArray *)itemModels
{
    return _itemModels;
}
- (NSArray *)margin
{
    if (_margin && 4 == _margin.count) {
        return _margin;
    }
    return @[@0, @0, @0, @0];
}
- (CGFloat)marginTop
{
    return [[self.margin tm_safeObjectAtIndex:0] floatValue];
}

- (CGFloat)marginRight
{
    return [[self.margin tm_safeObjectAtIndex:1] floatValue];
}

- (CGFloat)marginBottom
{
    return [[self.margin tm_safeObjectAtIndex:2] floatValue];
}

- (CGFloat)marginLeft
{
    return [[self.margin tm_safeObjectAtIndex:3] floatValue];
}

- (CGFloat)cellWidth
{
    if (0 == _cellWidth) {
        _cellWidth = ceilf((self.vv_width - [self.padding tm_floatAtIndex:1] - [self.padding tm_floatAtIndex:3] - self.hGap * (self.numberOfColumns - 1)) / self.numberOfColumns);
    }
    return _cellWidth;
}
-(NSUInteger)numberOfColumns
{
    if (_numberOfColumns <= 0) {
        _numberOfColumns = 2;
    }
    return _numberOfColumns;
}
-(UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
    }
    return _bgImageView;
}
//核心·CalculateLayout
-(void)calculateLayout
{
    NSUInteger numberOfColumns = self.numberOfColumns;
    CGFloat itemWidth = self.cellWidth;
    NSUInteger numberOfLine = (NSUInteger)ceil(self.itemModels.count / (numberOfColumns * 1.0));
    
    _columnsRectModels = [NSMutableArray arrayWithCapacity:numberOfColumns];
    
    CGFloat contentY = [self.padding tm_floatAtIndex:0];
    for (NSUInteger line = 0; line < numberOfLine; line++) {
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            NSUInteger index = line * numberOfColumns + j;
            if (index >= self.itemModels.count) {
                break;
            }
            NSObject<TangramItemModelProtocol> *itemModel = [self.itemModels tm_safeObjectAtIndex:index];
            CGFloat x = 0;
            CGFloat paddingTop = [self.padding tm_floatAtIndex: 0];
            CGFloat paddingLeft = [self.padding tm_floatAtIndex: 3];
            
            if (line == 0) {
                x = paddingLeft + (itemWidth + _hGap) * j;
                [itemModel setItemFrame:CGRectMake(x, paddingTop, itemWidth, itemModel.itemFrame.size.height)];
                _columnsRectModels[j] = itemModel;
            } else {
                NSMutableArray *sortArray = [_columnsRectModels mutableCopy];
                [sortArray sortUsingComparator:^NSComparisonResult(NSObject<TangramItemModelProtocol> *obj1, NSObject<TangramItemModelProtocol> *obj2) {
                    return CGRectGetMaxY(obj1.itemFrame) > CGRectGetMaxY(obj2.itemFrame);
                }];
                // 排序找到找到高度最小的一个
                // 接着最小的一个往下排
                NSObject<TangramItemModelProtocol> *minYModel = sortArray.firstObject;
                NSUInteger minYColumns = [_columnsRectModels indexOfObject:minYModel];
                x = paddingLeft + (itemWidth + _hGap) * minYColumns;
                CGFloat y = CGRectGetMaxY(minYModel.itemFrame) + _vGap;
                itemModel.itemFrame = CGRectMake(x, y, itemWidth, itemModel.itemFrame.size.height);
                _columnsRectModels[minYColumns] = itemModel;
            }
            CGFloat itemY = CGRectGetMaxY(itemModel.itemFrame);
            contentY = MAX(contentY, itemY);
        }
    }
    contentY += [self.padding tm_floatAtIndex: 2];
    
    self.vv_height = contentY;
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.vv_width, self.vv_height);
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
    }
    
}
- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
    self.numberOfReloadRequests += 1;
    int currentNumber = self.numberOfReloadRequests;
    if (0 <= self.firstReloadRequestTS) {
        self.firstReloadRequestTS = [[NSDate date] timeIntervalSince1970];
    }
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = wself;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        // 没有新请求，或超过500毫秒了
        if (currentNumber == sself.numberOfReloadRequests
            || 500 > now - sself.firstReloadRequestTS) {
            sself.firstReloadRequestTS = 0;
            [sself calculateLayout];
            if ([sself.superview isKindOfClass:[TangramView class]]) {
                //NSLog(@"relayout invoke time inwaterFlow ： %lf ",[[NSDate date] timeIntervalSince1970]);
                [((TangramView *)sself.superview) performSelector:@selector(reLayoutContent) withObject:nil];
            }
        }
    });
    
}

-(NSString *)layoutLoadAPI
{
    if (nil == _layoutLoadAPI) {
        _layoutLoadAPI = @"";
    }
    return _layoutLoadAPI;
}
-(NSString *)loadAPI
{
    return self.layoutLoadAPI;
}
@end

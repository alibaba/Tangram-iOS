//
//  TangramWaterFlowLayout.m
//  Pods
//
//  Created by xiaoxia on 15/12/12.
//
//

#import "TangramWaterFlowLayout.h"
//#import "NSArrayEX.h"
//#import "UIViewEX.h"
//#import "NSDictionaryEX.h"
#import "TangramSafeMethod.h"
#import "TangramItemModelProtocol.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"

@interface TangramWaterFlowLayout()
@property (nonatomic, assign) CGRect                 minRect;
@property (nonatomic, assign) CGRect                 maxRect;
@property (nonatomic, strong) NSMutableDictionary    *bottomRects;
@property (nonatomic, strong) NSString               *layoutIdentifier;
// 收到reload请求的次数
@property (atomic, assign   ) int                    numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign   ) NSTimeInterval         firstReloadRequestTS;
@property (nonatomic, strong) NSString               *bgImgURL;
@property (nonatomic, strong) UIImageView            *bgImageView;




@end

@implementation TangramWaterFlowLayout

@synthesize itemModels  = _itemModels;
@synthesize cellWidth   = _cellWidth;

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}
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

//- (void)setItemModels:(NSArray *)itemModels
//{
//    NSMutableArray *toBeAddedItemModels = [[NSMutableArray alloc]init];
//    NSMutableArray *mutableItemModels = [itemModels mutableCopy];
//    for (NSObject<TangramItemModelProtocol> *model in mutableItemModels) {
//        if ([model respondsToSelector:@selector(position)] &&  [[model position] isKindOfClass:[NSString class]] &&[model position].length > 0) {
//            [toBeAddedItemModels tgrm_addObjectCheck:model];
//        }
//    }
//    for (NSObject<TangramItemModelProtocol> *model in toBeAddedItemModels) {
//        [mutableItemModels removeObject:model];
//        if ([[model position] integerValue] > mutableItemModels.count) {
//            [mutableItemModels safeInsertObject:model atIndex:mutableItemModels.count];
//        }
//        else{
//            [mutableItemModels safeInsertObject:model atIndex:[[model position] integerValue]];
//        }
//    }
//    _itemModels = [mutableItemModels copy];
//}
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
    return [[self.margin tgrm_objectAtIndexCheck:0] floatValue];
}

- (CGFloat)marginRight
{
    return [[self.margin tgrm_objectAtIndexCheck:1] floatValue];
}

- (CGFloat)marginBottom
{
    return [[self.margin tgrm_objectAtIndexCheck:2] floatValue];
}

- (CGFloat)marginLeft
{
    return [[self.margin tgrm_objectAtIndexCheck:3] floatValue];
}

- (NSMutableDictionary *)bottomRects
{
    if (nil == _bottomRects) {
        _bottomRects = [[NSMutableDictionary alloc] init];
    }
    return _bottomRects;
}

- (CGFloat)cellWidth
{
    if (0 == _cellWidth) {
        _cellWidth = ceilf((self.width - self.marginLeft - self.marginRight - self.hGap * (self.numberOfColumns - 1)) / self.numberOfColumns);
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
    self.minRect = CGRectZero;
    self.maxRect = CGRectZero;
    [self.bottomRects removeAllObjects];
    CGFloat cellX   = self.marginLeft;
    CGFloat cellY   = 0.f;
    for (NSUInteger i = 0; i < self.itemModels.count; i++) {
        NSObject<TangramItemModelProtocol> *itemModel = [self.itemModels tgrm_objectAtIndexCheck:i];
        cellX   = CGRectGetMinX(self.minRect);
        //第一行不会受vGap的影响
        if (i  / self.numberOfColumns == 0) {
            cellY   = CGRectGetMaxY(self.minRect) + [itemModel marginTop];
        }
        else{
            cellY   = CGRectGetMaxY(self.minRect) + [itemModel marginTop] + self.vGap ;
        }
        
        [itemModel setItemFrame:CGRectMake(cellX , cellY, self.cellWidth, itemModel.itemFrame.size.height)];
        CGRect cellFrame = CGRectMake(itemModel.itemFrame.origin.x, itemModel.itemFrame.origin.y, itemModel.itemFrame.size.width, itemModel.itemFrame.size.height + [itemModel marginBottom]);
        // 看看是不是变成最大的了
        if (CGRectGetMaxY(self.maxRect) < CGRectGetMaxY(cellFrame) + [itemModel marginBottom]) {
            self.maxRect = cellFrame;
        }
        // 更新最下边一行的记录字典，用rect.x做key，保证不重复
        [self.bottomRects setObject:[NSValue valueWithCGRect:cellFrame]  forKey:[NSString stringWithFormat:@"%f", CGRectGetMinX(cellFrame)]];
        // 先随便给一个值，然后去最后一行找
        self.minRect = cellFrame;
        // 还没排满的时候
        if (self.numberOfColumns > self.bottomRects.count) {
            self.minRect = CGRectMake(CGRectGetMaxX(self.minRect) + [itemModel marginLeft] + self.hGap , 0.f, 0.f, 0.f);
        }
        for (NSValue *value in self.bottomRects.allValues) {
            CGRect rect = [value CGRectValue];
            if (CGRectGetMaxY(rect) < CGRectGetMaxY(self.minRect)) {
                self.minRect = rect;
            }
        }
    }
    self.height = MAX(CGRectGetMaxY(self.maxRect), CGRectGetMaxY(self.minRect));
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.width, self.height);
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

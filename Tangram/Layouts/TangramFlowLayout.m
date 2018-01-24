//
//  TangramFlowLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramFlowLayout.h"
#import "TangramItemModelProtocol.h"
#import "TangramView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "TangramEvent.h"
#import <VirtualView/UIView+VirtualView.h>
#import "TMUtils.h"

@interface TangramFlowLayout()

@property (nonatomic, strong) NSString              *layoutIdentifier;
// 收到reload请求的次数
@property (atomic, assign   ) int                   numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign   ) NSTimeInterval        firstReloadRequestTS;

@property (nonatomic, strong) NSMutableArray        *firstElementModelInRow;

@property (nonatomic, strong) NSMutableDictionary   *layoutModelDict;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *headerItemModel;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *footerItemModel;

@property (nonatomic, assign) NSUInteger            contentItemModelCount;

@property (nonatomic, strong) NSString  *subLayoutIndex;

@property (nonatomic, strong) NSMutableDictionary  *zIndexItemDict;

@end
@implementation TangramFlowLayout
@synthesize itemModels  = _itemModels;

- (NSMutableDictionary *)layoutModelDict
{
    if (nil == _layoutModelDict) {
        _layoutModelDict = [[NSMutableDictionary alloc]init];
    }
    return _layoutModelDict;
}
- (NSMutableDictionary *)zIndexItemDict
{
    if (nil == _zIndexItemDict) {
        _zIndexItemDict = [[NSMutableDictionary alloc]init];
    }
    return _zIndexItemDict;
}
-(UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}
- (TangramLayoutType *)layoutType
{
    if (self.subLayoutIndex && [self.subLayoutIndex isKindOfClass:[NSString class]] && self.subLayoutIndex.length > 0) {
        return [NSString stringWithFormat:@"%@-%@", @"tangram_layout_flow",self.subLayoutIndex];
    }
    return @"tangram_layout_flow";
}

- (void)setItemModels:(NSArray *)itemModels
{
    NSMutableArray *toBeAddedItemModels = [[NSMutableArray alloc]init];
    NSMutableArray *mutableItemModels = [itemModels mutableCopy];
    //根据Model的position 插入指定位置
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
    self.contentItemModelCount = itemModels.count;
    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
        [mutableItemModels insertObject:self.headerItemModel atIndex:0];
    }
    if (self.footerItemModel && ![self.itemModels containsObject:self.footerItemModel]) {
        [mutableItemModels tm_safeAddObject:self.footerItemModel];
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

- (void)addHeaderView:(UIView *)headerView
{
    [self addSubview:headerView];
}
- (void)addFooterView:(UIView *)footerView
{
    [self addSubview:footerView];
}

- (void)addSubView:(UIView *)view withModel:(NSObject<TangramItemModelProtocol> *)model
{
    if (self.enableInnerZIndexLayout == NO) {
        [self addSubview:view];
        return;
    }
    if ([model respondsToSelector:@selector(zIndex)] && model.zIndex > 0) {
        NSMutableArray *zIndexMutableArray = [self.zIndexItemDict tm_safeObjectForKey:[NSString stringWithFormat:@"%ld",(long)(model.zIndex)] class:[NSMutableArray class]];
        if (zIndexMutableArray == nil) {
            zIndexMutableArray = [[NSMutableArray alloc]init];
           [self.zIndexItemDict  tm_safeSetObject:zIndexMutableArray forKey:[NSString stringWithFormat:@"%ld",(long)(model.zIndex)]];
        }
        [zIndexMutableArray tm_safeAddObject:view];
    }
    else{
        NSMutableArray *zIndexMutableArray = [self.zIndexItemDict tm_safeObjectForKey:@"0" class:[NSMutableArray class]];
        if (zIndexMutableArray == nil) {
            zIndexMutableArray = [[NSMutableArray alloc]init];
            [self.zIndexItemDict  tm_safeSetObject:zIndexMutableArray forKey:@"0"];
        }
        [zIndexMutableArray tm_safeAddObject:view];
    }
    [self addSubview:view];
    [self buildZIndexView];
}

- (void)buildZIndexView
{
    NSArray *zIndexArray  = [[self.zIndexItemDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSInteger firstNumber = [obj1 integerValue];
        NSInteger secondNumber = [obj2 integerValue];
        if (firstNumber > secondNumber) {
            return  NSOrderedDescending;
        }
        else if(firstNumber < secondNumber){
            return NSOrderedAscending ;
        }
        else{
            return NSOrderedSame;
        }
    }];
    for (NSString *zIndex in zIndexArray) {
        NSMutableArray *zIndexMutableArray = [self.zIndexItemDict tm_safeObjectForKey:zIndex class:[NSMutableArray class]];
        for (UIView *item in zIndexMutableArray) {
            [self bringSubviewToFront:item];
        }
    }
    
}
- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[TangramView class]]) {
        self.tangramView = (TangramView *)self.superview;
    }
}
- (void)calculateLayout
{
    //抛出可异步加载的事件,暂时仅FlowLayout支持
    if ((self.loadType == TangramLayoutLoadTypeLoadOnce || self.loadType == TangramLayoutLoadTypeByPage) && self.loadAPI.length > 0) {
        TangramEvent *loadEvent = [[TangramEvent alloc]initWithTopic:@"requestItems" withTangramView:self.tangramView posterIdentifier:@"requestItems" andPoster:self];
        [loadEvent setParam:self.loadAPI forKey:@"loadAPI"];
        [loadEvent setParam:[NSNumber numberWithInteger:self.loadType] forKey:@"loadType"];
        if (self.loadParams.count > 0) {
            [loadEvent setParam:self.loadParams forKey:@"loadParams"];
        }
        [self.tangramBus postEvent:loadEvent];
    }
    //先移除,最后再加上去
    if (self.subLayoutIdentifiers.count > 0) {
         [self removeUnuseSubLayouts];
    }
    //如果说Model的数量为0 直接高度为0返回，不往下计算了
    //如果有header或者footer，但是items里面是空的，也不进行计算了
    if (nil == self.itemModels || 0 == self.contentItemModelCount) {
        self.vv_height = 0.f;
        return;
    }
    
    CGFloat startY = 0.f;
    NSUInteger number = self.itemModels.count;
    NSUInteger numberWithColspan  = 0.f;
    //如果有block，则把block单独拿出来算，一个block算一行
    NSUInteger blockRows = 0.f;
    //    for (NSObject<TangramItemModelProtocol> *itemModel in self.itemModels) {
    //        if ([itemModel.display isEqualToString:@"block"]) {
    //            blockRows ++;
    //        }
    //    }
    NSUInteger itemCountBeforeBlock = 0;
    for (NSUInteger i = 0; i < self.itemModels.count ; i++) {
        NSObject<TangramItemModelProtocol> *itemModel = [self.itemModels tm_safeObjectAtIndex:i];
        //如果是subLayout内部的itemModel，则跳过
        if ([itemModel respondsToSelector:@selector(innerItemModel)] && itemModel.innerItemModel &&
            [itemModel respondsToSelector:@selector(inLayoutIdentifier)] && ![itemModel.inLayoutIdentifier isEqualToString:self.identifier]) {
            continue;
        }
        if ([itemModel respondsToSelector:@selector(colspan)]) {
            numberWithColspan += [itemModel colspan];
        }
        else{
            numberWithColspan ++;
        }
        if ([itemModel.display isEqualToString:@"block"]) {
            //如果出现了一个block
            //如果这一行已经被填满了，那么下一个item直接行数+1即可
            //如果这一行还没有被填满，那么下一个item的行数需要 + 2 （没有被填满的一行 + block这一行）
            if ((i - itemCountBeforeBlock) % self.numberOfColumns == 0) {
                blockRows ++ ;
            }
            else{
                blockRows +=2;
            }
            itemCountBeforeBlock = i + 1;
        }
    }
    NSObject<TangramItemModelProtocol> *lastItemModel = nil;
    NSUInteger maxRows = (numberWithColspan < self.numberOfColumns) ? 1 : ceilf((CGFloat)(numberWithColspan - blockRows)/ self.numberOfColumns);
    
    maxRows += blockRows;
    NSUInteger columns = self.numberOfColumns;
    numberWithColspan = 0.f;
    // 行遍历
    int j = 0;
    int jj = 0;
    if (!_firstElementModelInRow)
    {
        self.firstElementModelInRow = [[NSMutableArray alloc] init];
    }
    else
    {
        [self.firstElementModelInRow removeAllObjects];
    }

    for (int i=0; i<maxRows; i++) {
         BOOL isFirstColumn = YES;
        // 计算组件宽度
        CGFloat totalGap = 0.f;
        NSObject<TangramItemModelProtocol> *lastItemModelInRow = nil;
        // 行内列遍历
        CGFloat baseHeight = 0.f;
        // 每次遍历的maxColums是这一行最后一个item的下标
        NSUInteger maxColumns = j + self.numberOfColumns;
        // 计算当前列的间距和，用于计算组件宽度 ， j 行数，这个循环里面只算GAP
        for (; j<maxColumns; j++) {
            NSObject<TangramItemModelProtocol> *itemModel = nil;
            // 如果这一行组件数不够了,并且打开了自动填充开关
            // 第一行就直接break了，按实际的组件数算
            if (j >= number && self.autoFill && 0 == i) {
                    columns = j;
                    break;
            }
            //第二行之后的j肯定比number要大了
            else {
                itemModel = [self.itemModels tm_safeObjectAtIndex:j];
            }
            if ([itemModel respondsToSelector:@selector(innerItemModel)] && itemModel.innerItemModel &&
                [itemModel respondsToSelector:@selector(inLayoutIdentifier)] && ![itemModel.inLayoutIdentifier isEqualToString:self.identifier]) {
                continue;
            }
            CGFloat itemMarginLeft= 0.f, lastItemMarginRight=0.f;
            if (itemModel) {
                if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                    itemMarginLeft = [itemModel marginLeft];
                }
                if (lastItemModelInRow && [lastItemModelInRow respondsToSelector:@selector(marginRight)]) {
                    lastItemMarginRight = [lastItemModelInRow marginRight];
                }
                if ([itemModel respondsToSelector:@selector(colspan)]) {
                    totalGap -= (itemModel.colspan -1)*self.hGap;
                }
                CGFloat gap =  itemMarginLeft + lastItemMarginRight;
                if (self.enableMarginDeduplication) {
                    gap = MAX(itemMarginLeft,lastItemMarginRight);
                }
                totalGap += gap;
                lastItemModelInRow = itemModel;
                if ([@"block" isEqualToString:itemModel.display]) {
                    // break之后不会自加，需要额外操作
                    j ++;
                    break;
                }
            }
        }
        //算完上面之后加上右边的padding
        if ([self.padding tm_floatAtIndex:3] > 0.f) {
            totalGap += [self.padding tm_floatAtIndex:3];
        }
        //再加上左边的padding
        if ([self.padding tm_floatAtIndex:1] > 0.f) {
            totalGap += [self.padding tm_floatAtIndex:1];
        }
        if (lastItemModelInRow && [lastItemModelInRow respondsToSelector:@selector(marginRight)]) {
            totalGap += lastItemModelInRow.marginRight;
        }
        totalGap += self.hGap *(self.numberOfColumns - 1);
        // 开始计算组件宽度，并给组件Model赋值
        //lastItemModel = nil;
        NSObject<TangramItemModelProtocol> *tmpLastItemModel = lastItemModel;
        // 行内下标
        NSUInteger indexInRow = 0;
        // 排列到此时剩下的内容宽度
        CGFloat contentWidth        = CGRectGetWidth(self.frame) - totalGap;
        CGFloat lastContentWidth    = contentWidth;
        lastItemModelInRow = nil;
        maxColumns = jj + self.numberOfColumns;
        //jj是平铺的列数  i行数
        for (; jj<maxColumns; jj++) {
            
            // 组件不够了
            if (jj >= number) {
                break;
            }
            // 默认：剩下宽度的平分
            CGFloat elementWidth = lastContentWidth / (columns - indexInRow);
            // 如果设置了百分比：整体宽度的百分比
            CGFloat ratio = [[self.cols tm_safeObjectAtIndex:indexInRow] floatValue];
            if (indexInRow < self.cols.count
                && 0 < ratio && 100 >= ratio) {
                elementWidth = contentWidth * ratio / 100;
            }
            
            NSObject<TangramItemModelProtocol> *itemModel = [self.itemModels tm_safeObjectAtIndex:jj];
            if ([itemModel respondsToSelector:@selector(innerItemModel)] && itemModel.innerItemModel &&
                [itemModel respondsToSelector:@selector(inLayoutIdentifier)] && ![itemModel.inLayoutIdentifier isEqualToString:self.identifier]) {
                jj++;
                continue;
            }
            if (isFirstColumn)
            {
                [self.firstElementModelInRow tm_safeAddObject:itemModel];
            }
            // Block，则需要独占1行，特殊处理
            if ([@"block" isEqualToString:itemModel.display]) {
                lastItemModel = tmpLastItemModel;
                // 宽度单独算
                if (itemModel) {
                    CGFloat itemMarginLeft=0.f, itemMarginRight=0.f;
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    if ([itemModel respondsToSelector:@selector(marginRight)]) {
                        itemMarginRight = [itemModel marginRight];
                    }
                    //如果有padding[0]，需要再减去左边的padding
                    if ([self.padding tm_floatAtIndex:3] > 0.f) {
                        itemMarginLeft += [self.padding tm_floatAtIndex:3];
                    }
                    //需要减去右边的padding
                    if ([self.padding tm_floatAtIndex:1] > 0.f) {
                        itemMarginRight += [self.padding tm_floatAtIndex:1];
                    }
                    CGFloat width = CGRectGetWidth(self.frame) - itemMarginLeft - itemMarginRight;
                    [self setItemWidth:width withModel:itemModel];
                }
                // 第一行
                if (0 == i) {
                    CGFloat itemMarginLeft=0.f, itemMarginTop=0.f, lastItemMarginBottom = 0.f;
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    if ([itemModel respondsToSelector:@selector(marginTop)]) {
                        itemMarginTop = [itemModel marginTop];
                    }
                    if (lastItemModel && [lastItemModel respondsToSelector:@selector(marginBottom)]) {
                        lastItemMarginBottom = [lastItemModel marginBottom];
                    }
                    //这里的组件一定是第一行第一列的
                    //因为是第一行，如果有padding[0]，第一行会被加padding
                    if ([self.padding tm_floatAtIndex:0] > 0.f) {
                        itemMarginTop += [self.padding tm_floatAtIndex:0];
                    }
                    //
                    //因为是第一列，如果有padding[3]，第一列会被加padding
                    if ([self.padding tm_floatAtIndex:3] > 0.f) {
                        itemMarginLeft += [self.padding tm_floatAtIndex:3];
                    }
                    if (lastItemModel) {
                        //这种情况是在第一行没有被填满的情况下，插入了一个block
                        //这样子下一个item的行数，比原本的没有block时的行数多了2（没有填满的第一行 + block这一行）
                        //所以需要 行数i 加 1
                        [self setItemTop:itemMarginTop + lastItemMarginBottom + CGRectGetMaxY(lastItemModel.itemFrame) withModel:itemModel];
                        i++;
                    }
                    else{
                        [self setItemTop:itemMarginTop withModel:itemModel];
                    }
                    [self setItemLeft:itemMarginLeft withModel:itemModel];
                }
                // 后边几行
                else {
                    CGFloat itemMarginLeft = 0.f, itemMarginTop = 0.f, lastItemModelBottom = 0.f;
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    if ([itemModel respondsToSelector:@selector(marginTop)]) {
                        itemMarginTop = [itemModel marginTop];
                    }
                    if (lastItemModel && [lastItemModel respondsToSelector:@selector(marginBottom)]) {
                        lastItemModelBottom = [lastItemModel marginBottom];
                    }
                    //这里的组件一定不是第一行的，但是一定是第一列(因为block的行只有一列)
                    //因为是第一列，如果有padding[3]，第一列会被加padding
                    if ([self.padding tm_floatAtIndex:3] > 0.f) {
                        itemMarginLeft += [self.padding tm_floatAtIndex:3];
                    }
                    [self setItemTop:lastItemModelBottom + itemMarginTop +CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    if (self.enableMarginDeduplication) {
                        [self setItemTop:lastItemModelBottom + itemMarginTop +CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    }
                    [self setItemLeft:itemMarginLeft withModel:itemModel];
                }
                tmpLastItemModel = itemModel;
                // break之后不会自加，需要额外操作
                jj ++;
                break;
            }
            
            //这一步，model已经获取了宽
            if (itemModel) {
                if ([itemModel respondsToSelector:@selector(colspan)] &&  [itemModel colspan] <= (columns - indexInRow)) {
                    [self setItemWidth:elementWidth*[itemModel colspan] withModel:itemModel];
                }
                else{
                    [self setItemWidth:elementWidth withModel:itemModel];
                }
            }
            if (self.aspectRatio && self.aspectRatio.length > 0 &&  [self.aspectRatio floatValue] > 0.f) {
                baseHeight = self.vv_width / [self.aspectRatio floatValue];
            }
            // 对齐操作，Base Height是这一行的基准高度，用来磨平误差
            // 对于流式布局，每一行的高度等于当前行的第一个组件高度
            if (isFirstColumn && 0.f >= baseHeight)
            {
                CGFloat itemMarginTop = 0.f, itemMarginBottom=0.f;
                if ([itemModel respondsToSelector:@selector(marginTop)]) {
                    itemMarginTop = [itemModel marginTop];
                }
                if ([itemModel respondsToSelector:@selector(marginBottom)]) {
                    itemMarginBottom = [itemModel marginBottom];
                }
                //如果有padding[0]，第一行会被加padding
                if (i == 0 && [self.padding tm_floatAtIndex:0] > 0.f) {
                    itemMarginTop += [self.padding tm_floatAtIndex:0];
                }
                //如果是最后一行的，加下padding
                if (i == maxRows - 1 && [self.padding tm_floatAtIndex:2] > 0.f) {
                    itemMarginBottom += [self.padding tm_floatAtIndex:2];
                }
                baseHeight = itemMarginTop + CGRectGetHeight(itemModel.itemFrame) + itemMarginBottom;
            }
            //要是有base了,那么就按照直接获取的值来
            else {
                CGFloat itemMarginTop = 0.f, itemMarginBottom=0.f;
                if ([itemModel respondsToSelector:@selector(marginTop)]) {
                    itemMarginTop = [itemModel marginTop];
                }
                if ([itemModel respondsToSelector:@selector(marginBottom)]) {
                    itemMarginBottom = [itemModel marginBottom];
                }
                //如果有padding[0]，第一行会被加padding
                if (i == 0 && [self.padding tm_floatAtIndex:0] > 0.f) {
                    itemMarginTop += [self.padding tm_floatAtIndex:0];
                }
                //如果是最后一行的，加下padding
                if (i == maxRows - 1 && [self.padding tm_floatAtIndex:2] > 0.f) {
                    itemMarginBottom += [self.padding tm_floatAtIndex:2];
                }
                CGRect tempRect = itemModel.itemFrame;
                tempRect.size.height = baseHeight - itemMarginTop - itemMarginBottom;
                [itemModel setItemFrame:tempRect];
            }
            
            // 第一行
            if (0 == i) {
                // 第一列
                if (i == jj) {
                    CGFloat itemMarginTop = 0.f, itemMarginLeft=0.f;
                    if ([itemModel respondsToSelector:@selector(marginTop)]) {
                        itemMarginTop = [itemModel marginTop];
                    }
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    //这里的组件一定是第一行第一列的
                    //如果有padding[0]，第一行会被加padding
                    if ([self.padding tm_floatAtIndex:0] > 0.f) {
                        itemMarginTop += [self.padding tm_floatAtIndex:0];
                    }
                    //如果有padding[3]，第一列会被加padding
                    if ([self.padding tm_floatAtIndex:3] > 0.f) {
                        itemMarginLeft += [self.padding tm_floatAtIndex:3];
                    }
                    [self setItemTop:itemMarginTop + startY withModel:itemModel];
                    [self setItemLeft:itemMarginLeft withModel:itemModel];
                }
                // 后边几列
                else {
                    CGFloat itemMarginLeft = 0.f, lastItemModelRight=0.f,itemMarginTop = 0.f;
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    if ([lastItemModelInRow respondsToSelector:@selector(marginRight)]) {
                        lastItemModelRight = [lastItemModelInRow marginRight];
                    }
                    if ([itemModel respondsToSelector:@selector(marginTop)]) {
                        itemMarginTop = [itemModel marginTop];
                    }
                    //这里的组件一定是不是第一列的，但一定是第一行的
                    //因为是第一行，如果有padding[0]，第一行会被加padding
                    if ([self.padding tm_floatAtIndex:0] > 0.f) {
                        itemMarginTop += [self.padding tm_floatAtIndex:0];
                    }
                    CGFloat gap = (lastItemModelInRow) ? (lastItemModelRight + itemMarginLeft) : itemMarginLeft;
                    if (self.enableMarginDeduplication) {
                        gap = (lastItemModelInRow) ? MAX(lastItemModelRight,itemMarginLeft) : itemMarginLeft;
                    }
                    [self setItemTop:itemMarginTop + startY withModel:itemModel];
                    [self setItemLeft:CGRectGetMaxX(lastItemModelInRow.itemFrame) + gap + self.hGap  withModel:itemModel];
                }
            }
            // 后边几行
            else {
                // 第一列
                CGFloat lastItemModelBottom = 0.f, itemMarginLeft=0.f,itemMarginTop = 0.f;
                if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                    itemMarginLeft = [itemModel marginLeft];
                }
                if ([lastItemModel respondsToSelector:@selector(marginBottom)]) {
                    lastItemModelBottom = [lastItemModel marginBottom];
                }
                if ([itemModel respondsToSelector:@selector(marginTop)]) {
                    itemMarginTop = [itemModel marginTop];
                }
                //第一列
                if (self.numberOfColumns == maxColumns - jj) {
                    //一定是第一列，不是第一行的
                    //所以如果有padding[3]，第一列会被加padding
                    if ([self.padding tm_floatAtIndex:3] > 0.f) {
                        itemMarginLeft += [self.padding tm_floatAtIndex:3];
                    }
                    [self setItemTop:lastItemModelBottom + itemMarginTop + CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    if (self.enableMarginDeduplication) {
                        [self setItemTop:MAX(lastItemModelBottom,itemMarginTop) + CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    }
                    [self setItemLeft:itemMarginLeft withModel:itemModel];
                }
                // 后边几列
                else {
                    //不是第一列也不是第一行的，所以可以无视padding
                    CGFloat lastItemMarginRight = 0.f, lastItemModelBottom = 0.f,itemMarginLeft=0.f,itemMarginTop = 0.f;
                    if ([itemModel respondsToSelector:@selector(marginLeft)]) {
                        itemMarginLeft = [itemModel marginLeft];
                    }
                    if ([lastItemModelInRow respondsToSelector:@selector(marginRight)]) {
                        lastItemMarginRight = [lastItemModelInRow marginRight];
                    }
                    if ([itemModel respondsToSelector:@selector(marginTop)]) {
                        itemMarginTop = [itemModel marginTop];
                    }
                    if ([lastItemModel respondsToSelector:@selector(marginBottom)]) {
                        lastItemModelBottom = [lastItemModel marginBottom];
                    }
                    CGFloat gap = (lastItemModelInRow) ? lastItemMarginRight + itemMarginLeft : itemMarginLeft;
                    if (self.enableMarginDeduplication) {
                        gap = (lastItemModelInRow) ? MAX(lastItemMarginRight,itemMarginLeft) : itemMarginLeft;
                    }
                    [self setItemTop:lastItemModelBottom + itemMarginTop + CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    if (self.enableMarginDeduplication) {
                        [self setItemTop:MAX(lastItemModelBottom,itemMarginTop) + CGRectGetMaxY(lastItemModel.itemFrame)+self.vGap withModel:itemModel];
                    }
                    [self setItemLeft:CGRectGetMaxX(lastItemModelInRow.itemFrame) + gap+self.hGap withModel:itemModel];
                }
            }
            CGFloat itemMarginBottom = 0.f, tmpLastItemMarginBottom = 0.f;
            if ([itemModel respondsToSelector:@selector(marginBottom)]) {
                itemMarginBottom = [itemModel marginBottom];
            }
            if ([tmpLastItemModel respondsToSelector:@selector(marginBottom)]) {
                tmpLastItemMarginBottom = [tmpLastItemModel marginBottom];
            }
            //如果是最后一行，把下面的marginBottom加上
            if (i == maxRows - 1 && [self.padding tm_floatAtIndex:2] > 0.f) {
                itemMarginBottom += [self.padding tm_floatAtIndex:2];
            }
            //lastItemModelInRow 指 当前行 上一个itemModel
            lastItemModelInRow = itemModel;
            //取最高的来计算layout高度
            tmpLastItemModel = (itemMarginBottom + CGRectGetMaxY(itemModel.itemFrame) >
                                tmpLastItemMarginBottom + CGRectGetMaxY(tmpLastItemModel.itemFrame)) ? itemModel : tmpLastItemModel;
            lastContentWidth -= itemModel.itemFrame.size.width;
            
            if ([itemModel respondsToSelector:@selector(colspan)]) {
                numberWithColspan += [itemModel colspan];
                indexInRow += [itemModel colspan];
            }
            else
            {
                numberWithColspan ++;
                indexInRow ++;
            }
            isFirstColumn = NO;
            //如果这个超越了这个行的行数
            if (indexInRow >= self.numberOfColumns) {
                jj++;
                break;
            }
            
        }
        //lastItemModel 指 上一行 最后一个itemModel
        lastItemModel = tmpLastItemModel;
        CGFloat lastItemMarginBottom = 0.f;
        if ([lastItemModel respondsToSelector:@selector(marginBottom)]) {
            lastItemMarginBottom = [lastItemModel marginBottom];
            //如果是最后一行，需要加上 下padding
            if ([self.padding tm_floatAtIndex:2] > 0.f) {
                lastItemMarginBottom += [self.padding tm_floatAtIndex:2];
            }
        }
        self.vv_height =  CGRectGetMaxY(lastItemModel.itemFrame)  + lastItemMarginBottom;
        if (self.bgImgURL && self.bgImgURL.length > 0) {
            self.bgImageView.frame = CGRectMake(0, 0, self.vv_width, self.vv_height);
            [self sendSubviewToBack:self.bgImageView];
            switch (self.bgScaleType) {
                case TangramFlowLayoutBgImageScaleTypeFitStart:
                {
                    [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:self.bgImgURL] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        if (image) {
                            
                            self.bgImageView.image = image;
                            CGFloat height = 0;
                            if (image.size.width > 0) {
                                // 等比例缩放
                                height = (self.vv_width / image.size.width) * image.size.height;
                            }
                            self.bgImageView.vv_height = height;
                            self.clipsToBounds = YES;
                        }
                    }];

                }
                    break;
                case TangramFlowLayoutBgImageScaleTypeFitXY:
                default:
                    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
                    break;
            }
            
        }
    }
    //加入组件化的卡片
    [self addSubLayouts];
}

- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
    //行级组建按照最左边的大小，所以不是第一列中的组件的话，直接return掉
    //如果说是组件化的卡片，不会return
    if (model &&
        !([self.firstElementModelInRow containsObject:model] ||
        (model.layoutIdentifierForLayoutModel && model.layoutIdentifierForLayoutModel.length <= 0)))
    {
        return;
    }
    // TangramView和Flowlayout有同样的逻辑
    // 通过记录第一次刷新请求的时间，延迟执行，执行时加以判断，
    // 合并多次刷新，避免频繁刷新，效率降低
    /** 每次收到relaod请求都延迟100毫秒，在延迟窗口内若没有新请求则执行reload，若有则继续延迟100毫秒，直至延迟上限（500毫秒）**/
    self.numberOfReloadRequests += 1;
    int currentNumber = self.numberOfReloadRequests;
    // 初始化首次请求时间
    if (0 >= self.firstReloadRequestTS) {
        self.firstReloadRequestTS = [[NSDate date] timeIntervalSince1970];
    }
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = wself;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        // 没有新请求，或超过500毫秒了
        // block里用到的currentNumber是copy的
        if (currentNumber == sself.numberOfReloadRequests
            || 500 < now - sself.firstReloadRequestTS) {
            sself.firstReloadRequestTS = 0;
            [sself calculateLayout];
            if (![sself.superview isKindOfClass:[TangramView class]] && [self.superview conformsToProtocol:@protocol(TangramLayoutProtocol)]) {
                //如果是subLayout要撑开，走额外的逻辑
                //Model 暂时取不到，传空
                [(UIView<TangramLayoutProtocol> *)(sself.superview) heightChangedWithElement:self model:nil];
            }
            if ([sself.tangramView isKindOfClass:[TangramView class]]) {
                //NSLog(@"relayout invoke time in flowlayout ： %lf ",[[NSDate date] timeIntervalSince1970]);
                [sself.tangramView reLayoutContent];
            }
        }
    });
}

-(NSString *)loadAPI
{
    return self.layoutLoadAPI;
}

-(NSString *)identifier
{
    return self.layoutIdentifier;
}
- (void)setIdentifier:(NSString *)identifier
{
    self.layoutIdentifier = identifier;
}
#pragma mark - private
- (void)setItemLeft:(CGFloat)left withModel:(NSObject<TangramItemModelProtocol> *)model
{
    if ([model respondsToSelector:@selector(setItemFrame:)]) {
        [model setItemFrame:CGRectMake(left,model.itemFrame.origin.y, model.itemFrame.size.width, model.itemFrame.size.height)];
    }
}
- (void)setItemTop:(CGFloat)top withModel:(NSObject<TangramItemModelProtocol> *)model
{
    if ([model respondsToSelector:@selector(setItemFrame:)]) {
        [model setItemFrame:CGRectMake(model.itemFrame.origin.x,top, model.itemFrame.size.width, model.itemFrame.size.height)];
    }
}
- (void)setItemWidth:(CGFloat)width withModel:(NSObject<TangramItemModelProtocol> *)model
{
    if ([model respondsToSelector:@selector(setItemFrame:)]) {
        [model setItemFrame:CGRectMake(model.itemFrame.origin.x,model.itemFrame.origin.y, width, model.itemFrame.size.height)];
    }
    //触发对subLayout的计算
    //首先让子layout去算自己的布局高度
    if ([model respondsToSelector:@selector(layoutIdentifierForLayoutModel)] && model.layoutIdentifierForLayoutModel.length > 0 && [self.subLayoutIdentifiers containsObject:model.layoutIdentifierForLayoutModel]) {
        [self buildInnerSubLayoutByModel:model];
    }
}

//此方法调用前需要保证itemModel的width是有值的
- (void)buildInnerSubLayoutByModel:(NSObject<TangramItemModelProtocol> *)itemModel
{
    UIView<TangramLayoutProtocol> *layout = [self.subLayoutDict tm_safeObjectForKey:itemModel.layoutIdentifierForLayoutModel];
    if (!layout || 0 == layout.itemModels.count) {
        return;
    }
    layout.vv_width = itemModel.itemFrame.size.width;
    [layout calculateLayout];
    itemModel.itemFrame = CGRectMake(itemModel.itemFrame.origin.x, itemModel.itemFrame.origin.y, itemModel.itemFrame.size.width, layout.vv_height);
    [self.layoutModelDict tm_safeSetObject:itemModel forKey:itemModel.layoutIdentifierForLayoutModel];
}

- (void)addSubLayouts
{
    for (NSString *identifier in self.subLayoutIdentifiers) {
        UIView<TangramItemModelProtocol> *layout = [self.subLayoutDict tm_safeObjectForKey:identifier];
        NSObject<TangramItemModelProtocol> *layoutModel = [self.layoutModelDict tm_safeObjectForKey:identifier];
        layout.frame = layoutModel.itemFrame;
        [self addSubview:layout];
    }
}
//移除不需要的subLayouts
- (void)removeUnuseSubLayouts
{
    //首先需要从自己的itemModels中遍历出来，不需要的Layout的identifier
    NSMutableSet *itemModelsLayoutIdentifiersSet = [[NSMutableSet alloc]init];
    for (NSObject<TangramItemModelProtocol> *itemModel in self.itemModels) {
        if ([itemModel respondsToSelector:@selector(layoutIdentifierForLayoutModel)] && itemModel.layoutIdentifierForLayoutModel.length > 0) {
            [itemModelsLayoutIdentifiersSet addObject:itemModel.layoutIdentifierForLayoutModel];
        }
    }
    NSMutableSet *pastlayoutIdentifiersSet = [[NSMutableSet setWithArray:self.subLayoutIdentifiers] mutableCopy];
    [pastlayoutIdentifiersSet minusSet:itemModelsLayoutIdentifiersSet];
    NSMutableArray *mutableSubLayoutIdentifiers = [self.subLayoutIdentifiers mutableCopy];
    NSMutableDictionary *mutableSubLayoutDict = [self.subLayoutDict mutableCopy];
    for (NSString *innerLayoutIdentifier in pastlayoutIdentifiersSet) {
        [mutableSubLayoutIdentifiers removeObject:innerLayoutIdentifier];
        UIView<TangramLayoutProtocol> *subLayout = [self.subLayoutDict tm_safeObjectForKey:innerLayoutIdentifier];
        [subLayout removeFromSuperview];
        [mutableSubLayoutDict removeObjectForKey:innerLayoutIdentifier];
    }
    self.subLayoutDict = [mutableSubLayoutDict copy];
    self.subLayoutIdentifiers = [mutableSubLayoutIdentifiers copy];
}


@end

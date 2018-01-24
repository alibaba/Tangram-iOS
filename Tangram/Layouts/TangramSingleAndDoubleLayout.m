//
//  TangramSingleAndDoubleLayout.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramSingleAndDoubleLayout.h"
#import "TangramItemModelProtocol.h"
#import "UIImageView+WebCache.h"
#import "TangramView.h"
#import "TMUtils.h"
#import <VirtualView/UIView+VirtualView.h>

@interface TangramSingleAndDoubleLayout()

// 收到reload请求的次数
@property (atomic, assign) int                   numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign) NSTimeInterval        firstReloadRequestTS;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *headerItemModel;

@property (nonatomic, strong) NSObject<TangramItemModelProtocol> *footerItemModel;


@end

@implementation TangramSingleAndDoubleLayout
@synthesize itemModels = _itemModels;
- (NSUInteger)numberOfColumns
{
    return 2;
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
    if (self.headerItemModel && ![self.itemModels containsObject:self.headerItemModel]) {
        [mutableItemModels insertObject:self.headerItemModel atIndex:0];
    }
    if (self.footerItemModel && ![self.itemModels containsObject:self.footerItemModel]) {
        [mutableItemModels tm_safeAddObject:self.footerItemModel];
    }
    _itemModels = [mutableItemModels copy];
}

- (void)calculateLayout
{
    NSUInteger realItemModelStartIndex = 0;
    NSUInteger realItemModelEndIndex = 0;

    if (self.headerItemModel) {
        realItemModelStartIndex = 1;
    }
    if (self.footerItemModel) {
        realItemModelEndIndex = self.itemModels.count - realItemModelStartIndex - 1;
    }
    else{
        realItemModelEndIndex = self.itemModels.count - realItemModelStartIndex;
    }
    NSObject<TangramItemModelProtocol> *first   = [self.itemModels tm_safeObjectAtIndex:realItemModelStartIndex];
    NSObject<TangramItemModelProtocol> *second  =  nil ;
    if (realItemModelEndIndex >= realItemModelStartIndex + 1) {
        second = [self.itemModels tm_safeObjectAtIndex: realItemModelStartIndex + 1];
    }
    NSObject<TangramItemModelProtocol> *third = nil;
    if (realItemModelEndIndex >= realItemModelStartIndex + 2) {
        third = [self.itemModels tm_safeObjectAtIndex:realItemModelStartIndex + 2];
    }
    NSObject<TangramItemModelProtocol> *fourth = nil;
    if (realItemModelEndIndex >= realItemModelStartIndex + 3) {
        fourth = [self.itemModels tm_safeObjectAtIndex:realItemModelStartIndex + 3];
    }
    NSObject<TangramItemModelProtocol> *fifth   = nil ;
    if (realItemModelEndIndex >= realItemModelStartIndex + 4) {
        fifth = [self.itemModels tm_safeObjectAtIndex:realItemModelStartIndex + 4];
    }
    CGFloat contentWidth    = self.vv_width - first.marginLeft - first.marginRight;
    CGFloat bottom          = 0.f;
    BOOL useRows = NO;
    if (self.headerItemModel) {
        contentWidth = self.vv_width - self.headerItemModel.marginLeft  - self.headerItemModel.marginRight -  [self.padding tm_floatAtIndex:1] -  [self.padding tm_floatAtIndex:3];
        self.headerItemModel.itemFrame = CGRectMake(self.headerItemModel.marginLeft + [self.padding tm_floatAtIndex:3] , self.headerItemModel.marginTop + [self.padding tm_floatAtIndex:0], contentWidth, self.headerItemModel.itemFrame.size.height);
    }
    if (self.aspectRatio && self.aspectRatio.length > 0 &&  [self.aspectRatio floatValue] > 0.f) {
        self.vv_height = self.vv_width / [self.aspectRatio floatValue];
    }
    if (second) {
        // 首行纯内容宽度
        contentWidth = self.vv_width - first.marginLeft - second.marginRight - first.marginRight - second.marginLeft -  [self.padding tm_floatAtIndex:1] -  [self.padding tm_floatAtIndex:3];
        // 剩余内容宽度
        CGFloat lastContentWidth = contentWidth;
        CGFloat firstHeight = first.itemFrame.size.height;
        if (self.aspectRatio.length > 0) {
            firstHeight = self.vv_height;
         }
        // 第一个
        CGFloat elementWidth = ceilf(lastContentWidth) / 2;
        CGFloat ratio = [[self.cols tm_safeObjectAtIndex:0] integerValue];
        if (0 < ratio && 100 >= ratio) {
            elementWidth = ceilf(contentWidth * ratio / 100);
        }
        if (self.headerItemModel) {
            [first setItemFrame:CGRectMake(first.marginLeft + [self.padding tm_floatAtIndex:3], first.marginTop + CGRectGetMaxY(self.headerItemModel.itemFrame) +  self.headerItemModel.marginBottom , elementWidth, firstHeight)];
        }
        else{
            [first setItemFrame:CGRectMake(first.marginLeft + [self.padding tm_floatAtIndex:3], first.marginTop + [self.padding tm_floatAtIndex:0] , elementWidth, firstHeight)];
        }
        
        firstHeight = first.itemFrame.size.height;
        bottom = CGRectGetMaxY(first.itemFrame) + first.marginBottom;
        
        // 剩余内容宽度
        // 第一个和第二个是独占的，所以可以直接减
        lastContentWidth = contentWidth - elementWidth;
        CGFloat rightHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
        - second.marginTop - second.marginBottom;
        if (third) {
            // 如果有第二行，则以第三个组件的margin值计算高度，第四个做缩放
            CGFloat ratio = [[self.rows tm_safeObjectAtIndex:0] floatValue];
            // 上下比例
            if (ratio > 0 && ratio <= 100) {
                //和android统一，这里暂时不使用Margin折叠...
                rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                               - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom) * ratio / 100.f;
                useRows = YES;
            }
            else{
                rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                               - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom)/2.f;
            }
        }
        
        // 第二个
        elementWidth = lastContentWidth;
        // 重写高度，保证对齐
        if (self.headerItemModel) {
            [second setItemFrame:CGRectMake(first.marginRight + second.marginLeft + CGRectGetMaxX(first.itemFrame) ,second.marginTop +[self.padding tm_floatAtIndex:0] +  CGRectGetMaxY(self.headerItemModel.itemFrame) + self.headerItemModel.marginBottom, elementWidth, rightHeight)];
        }
        else{
            [second setItemFrame:CGRectMake(first.marginRight + second.marginLeft + CGRectGetMaxX(first.itemFrame) ,second.marginTop + [self.padding tm_floatAtIndex:0], elementWidth, rightHeight)];
        }
        

        bottom = MAX(CGRectGetMaxY(second.itemFrame) + second.marginBottom, bottom);
        //如果有第五个...
        if (fifth) {
            //下一个版本再考虑好好把这里收拾一下吧
            //.....T_T
            contentWidth = self.vv_width - first.marginLeft - first.marginRight- third.marginLeft
            - third.marginRight- fourth.marginLeft - fourth.marginRight - fifth.marginLeft - fifth.marginRight - [self.padding tm_floatAtIndex:3] - [self.padding tm_floatAtIndex:1];
             lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            if(useRows)
            {
                CGFloat ratio = [[self.rows tm_safeObjectAtIndex:1] floatValue];
                // 上下比例
                if (ratio > 0 && ratio <= 100) {
                    rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                                   - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom) * ratio / 100.f;
                }
                else
                {
                    rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                                   - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom) - rightHeight;
                }
            }
            // 第三个
            CGFloat elementWidth = ceilf(lastContentWidth) / 3;
            CGFloat ratio = [[self.cols tm_safeObjectAtIndex:2] integerValue];
            // 整体宽度的百分比
            if ([self.cols tm_safeObjectAtIndex:2] && 0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            [third setItemFrame:CGRectMake(first.marginRight+ third.marginLeft + CGRectGetMaxX(first.itemFrame), third.marginTop+second.marginBottom + CGRectGetMaxY(second.itemFrame),elementWidth, rightHeight)];
            bottom = MAX(CGRectGetMaxY(third.itemFrame) + third.marginBottom, bottom);
            // 第四个
            lastContentWidth = lastContentWidth - elementWidth;
            elementWidth = ceilf(lastContentWidth) / 2;
            ratio = [[self.cols tm_safeObjectAtIndex:3] integerValue];
            // 整体宽度的百分比
            if ([self.cols tm_safeObjectAtIndex:3] && 0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            // 基准高度是由第三个组件的margin算出来的，所以第四个要单独算过
            CGFloat fourthHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
            - second.marginTop - CGRectGetHeight(second.itemFrame) - second.marginBottom - fourth.marginTop - fourth.marginBottom;
            [fourth setItemFrame:CGRectMake(fourth.marginLeft+ third.marginRight + CGRectGetMaxX(third.itemFrame), fourth.marginTop + second.marginBottom+ CGRectGetMaxY(second.itemFrame), elementWidth,fourthHeight)];
            bottom = MAX(CGRectGetMaxY(fourth.itemFrame) + fourth.marginBottom, bottom);
            //第五个
            lastContentWidth = lastContentWidth - elementWidth;
            elementWidth = lastContentWidth;
            ratio = [[self.cols tm_safeObjectAtIndex:4] integerValue];
            // 整体宽度的百分比
            if ([self.cols tm_safeObjectAtIndex:4] && 0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            CGFloat fifthHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
            - second.marginTop - CGRectGetHeight(second.itemFrame) - second.marginBottom - fifth.marginTop - fifth.marginBottom;
            [fifth setItemFrame:CGRectMake(fifth.marginLeft+ fourth.marginRight + CGRectGetMaxX(fourth.itemFrame), fifth.marginTop + second.marginBottom+ CGRectGetMaxY(second.itemFrame), elementWidth,fifthHeight)];
            bottom = MAX(CGRectGetMaxY(fifth.itemFrame) + fifth.marginBottom, bottom);
        }
        //如果就4个...
        else if (fourth) {
            contentWidth = self.vv_width - first.marginLeft - first.marginRight- third.marginLeft
            - third.marginRight- fourth.marginLeft - fourth.marginRight - [self.padding tm_floatAtIndex:3] - [self.padding tm_floatAtIndex:1];
            lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            if(useRows)
            {
                CGFloat ratio = [[self.rows tm_safeObjectAtIndex:1] floatValue];
                // 上下比例
                if (ratio > 0 && ratio <= 100) {
                    rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                                   - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom) * ratio / 100.f;
                }
                else
                {
                    rightHeight = (first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
                                   - second.marginTop - second.marginBottom - third.marginTop - third.marginBottom) - rightHeight;
                }
            }
            // 第三个
            CGFloat elementWidth = ceilf(lastContentWidth) / 2;
            CGFloat ratio = [[self.cols tm_safeObjectAtIndex:2] integerValue];
            // 整体宽度的百分比
            if (0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            [third setItemFrame:CGRectMake(first.marginRight+ third.marginLeft + CGRectGetMaxX(first.itemFrame), third.marginTop+second.marginBottom + CGRectGetMaxY(second.itemFrame),elementWidth, rightHeight)];
            bottom = MAX(CGRectGetMaxY(third.itemFrame) + third.marginBottom, bottom);
            
            // 第四个，最后一个了
            lastContentWidth = lastContentWidth - elementWidth;
            elementWidth = lastContentWidth;
            ratio = [[self.cols tm_safeObjectAtIndex:3] integerValue];
            // 整体宽度的百分比
            if (0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            // 基准高度是由第三个组件的margin算出来的，所以第四个要单独算过
            CGFloat fourthHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
            - second.marginTop - CGRectGetHeight(second.itemFrame) - second.marginBottom - fourth.marginTop - fourth.marginBottom;
            [fourth setItemFrame:CGRectMake(fourth.marginLeft+ third.marginRight + CGRectGetMaxX(third.itemFrame), fourth.marginTop + second.marginBottom+ CGRectGetMaxY(second.itemFrame), elementWidth,fourthHeight)];
            bottom = MAX(CGRectGetMaxY(fourth.itemFrame) + fourth.marginBottom, bottom);
        }
        //如果就3个...
        else if (third) {
            contentWidth = self.vv_width - first.marginLeft - first.marginRight - third.marginLeft - third.marginRight
            - [self.padding tm_floatAtIndex:3] - [self.padding tm_floatAtIndex:1];
            lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            CGFloat elementWidth = lastContentWidth;
            CGFloat ratio = [[self.cols tm_safeObjectAtIndex:2] integerValue];
            // 整体宽度的百分比
            if (0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
             [third setItemFrame:CGRectMake(first.marginRight + third.marginLeft + CGRectGetMaxX(first.itemFrame),
                                            CGRectGetMaxY(second.itemFrame) + second.marginBottom + third.marginTop,elementWidth, rightHeight)];
            bottom = MAX(third.itemFrame.origin.y + third.marginBottom, bottom);
        }
        else {
            // 高度要一致
            [second setItemFrame:CGRectMake(second.itemFrame.origin.x, second.itemFrame.origin.y, second.itemFrame.size.width, first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom - second.marginTop - second.marginBottom)];
        }
    }
    else {
        // 第一个，只有一个
        [first setItemFrame:CGRectMake(first.marginLeft, first.marginTop, contentWidth, first.itemFrame.size.height)];
        bottom = first.itemFrame.origin.y + first.itemFrame.size.height + first.marginBottom;
    }
    if (self.footerItemModel) {
        contentWidth = self.vv_width - self.footerItemModel.marginLeft  - self.footerItemModel.marginRight -  [self.padding tm_floatAtIndex:1] -  [self.padding tm_floatAtIndex:3];
        self.footerItemModel.itemFrame = CGRectMake(self.footerItemModel.marginLeft + [self.padding tm_floatAtIndex:3] , self.footerItemModel.marginTop + bottom, contentWidth, self.footerItemModel.itemFrame.size.height);
        bottom = CGRectGetMaxY(self.footerItemModel.itemFrame) + self.footerItemModel.marginBottom;
    }
    
    if (!(self.aspectRatio && self.aspectRatio.length > 0 &&  [self.aspectRatio floatValue] > 0.f)) {
        self.vv_height = bottom;
    }
    self.vv_height += [self.padding tm_floatAtIndex:2];
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.vv_width, self.vv_height);
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.bgImgURL]];
    }
}

- (void)heightChangedWithElement:(UIView *)element model:(NSObject<TangramItemModelProtocol> *)model
{
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
            if ([sself.superview isKindOfClass:[TangramView class]]) {
                //NSLog(@"relayout invoke time in flowlayout ： %lf ",[[NSDate date] timeIntervalSince1970]);
                [(TangramView *)sself.superview reLayoutContent];
            }
        }
    });

}

@end

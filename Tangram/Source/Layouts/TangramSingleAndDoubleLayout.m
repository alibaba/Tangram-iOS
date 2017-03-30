//
//  TangramSingleAndDoubleLayout.m
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/19.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramSingleAndDoubleLayout.h"
#import "TangramItemModelProtocol.h"
#import "UIImageView+WebCache.h"
#import "TangramView.h"
#import "TangramSafeMethod.h"

@interface TangramSingleAndDoubleLayout()

// 收到reload请求的次数
@property (atomic, assign) int                   numberOfReloadRequests;
// 首次收到reload请求的时间点，毫秒级
@property (atomic, assign) NSTimeInterval        firstReloadRequestTS;

@end

@implementation TangramSingleAndDoubleLayout

- (NSUInteger)numberOfColumns
{
    return 2;
}

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

- (void)calculateLayout
{
    NSObject<TangramItemModelProtocol> *first   = [self.itemModels tgrm_objectAtIndexCheck:0];
    NSObject<TangramItemModelProtocol> *second  = [self.itemModels tgrm_objectAtIndexCheck:1];
    NSObject<TangramItemModelProtocol> *third   = [self.itemModels tgrm_objectAtIndexCheck:2];
    NSObject<TangramItemModelProtocol> *fourth  = [self.itemModels tgrm_objectAtIndexCheck:3];
    NSObject<TangramItemModelProtocol> *fifth   = [self.itemModels tgrm_objectAtIndexCheck:4];
    CGFloat contentWidth    = self.width - first.marginLeft - first.marginRight;
    CGFloat bottom          = 0.f;
    BOOL useRows = NO;
    if (self.aspectRatio && self.aspectRatio.length > 0 &&  [self.aspectRatio floatValue] > 0.f) {
        self.height = self.width / [self.aspectRatio floatValue];
    }
    if (second) {
        // 首行纯内容宽度
        contentWidth = self.width - first.marginLeft - second.marginRight - first.marginRight - second.marginLeft;
        // 剩余内容宽度
        CGFloat lastContentWidth = contentWidth;
        CGFloat firstHeight = first.itemFrame.size.height;
        if (self.aspectRatio.length > 0) {
            firstHeight = self.height;
         }
        // 第一个
        CGFloat elementWidth = ceilf(lastContentWidth) / 2;
        CGFloat ratio = [[self.cols tgrm_objectAtIndexCheck:0] integerValue];
        if (0 < ratio && 100 >= ratio) {
            elementWidth = ceilf(contentWidth * ratio / 100);
        }
        [first setItemFrame:CGRectMake(first.marginTop, first.marginLeft, elementWidth, firstHeight)];
        firstHeight = first.itemFrame.size.height;
        bottom = CGRectGetMaxY(first.itemFrame) + first.marginBottom;
        
        // 剩余内容宽度
        // 第一个和第二个是独占的，所以可以直接减
        lastContentWidth = contentWidth - elementWidth;
        CGFloat rightHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
        - second.marginTop - second.marginBottom;
        if (third) {
            // 如果有第二行，则以第三个组件的margin值计算高度，第四个做缩放
            CGFloat ratio = [[self.rows tgrm_objectAtIndexCheck:0] floatValue];
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
        [second setItemFrame:CGRectMake(first.marginRight + second.marginLeft + CGRectGetMaxX(first.itemFrame),second.marginTop, elementWidth, rightHeight)];

        bottom = MAX(CGRectGetMaxY(second.itemFrame) + second.marginBottom, bottom);
        //如果有第五个...
        if (fifth) {
            contentWidth = self.width - first.marginLeft - first.marginRight- third.marginLeft
            - third.marginRight- fourth.marginLeft - fourth.marginRight - fifth.marginLeft - fifth.marginRight;
             lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            if(useRows)
            {
                CGFloat ratio = [[self.rows tgrm_objectAtIndexCheck:1] floatValue];
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
            CGFloat ratio = [[self.cols tgrm_objectAtIndexCheck:2] integerValue];
            // 整体宽度的百分比
            if ([self.cols tgrm_objectAtIndexCheck:2] && 0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            [third setItemFrame:CGRectMake(first.marginRight+ third.marginLeft + CGRectGetMaxX(first.itemFrame), third.marginTop+second.marginBottom + CGRectGetMaxY(second.itemFrame),elementWidth, rightHeight)];
            bottom = MAX(CGRectGetMaxY(third.itemFrame) + third.marginBottom, bottom);
            // 第四个
            lastContentWidth = lastContentWidth - elementWidth;
            elementWidth = ceilf(lastContentWidth) / 2;
            ratio = [[self.cols tgrm_objectAtIndexCheck:3] integerValue];
            // 整体宽度的百分比
            if ([self.cols tgrm_objectAtIndexCheck:3] && 0 < ratio && 100 >= ratio) {
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
            ratio = [[self.cols tgrm_objectAtIndexCheck:4] integerValue];
            // 整体宽度的百分比
            if ([self.cols tgrm_objectAtIndexCheck:4] && 0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            CGFloat fifthHeight = first.marginTop + CGRectGetHeight(first.itemFrame) + first.marginBottom
            - second.marginTop - CGRectGetHeight(second.itemFrame) - second.marginBottom - fifth.marginTop - fifth.marginBottom;
            [fifth setItemFrame:CGRectMake(fifth.marginLeft+ fourth.marginRight + CGRectGetMaxX(fourth.itemFrame), fifth.marginTop + second.marginBottom+ CGRectGetMaxY(second.itemFrame), elementWidth,fifthHeight)];
            bottom = MAX(CGRectGetMaxY(fifth.itemFrame) + fifth.marginBottom, bottom);
        }
        //如果就4个...
        else if (fourth) {
            contentWidth = self.width - first.marginLeft - first.marginRight- third.marginLeft
            - third.marginRight- fourth.marginLeft - fourth.marginRight;
            lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            if(useRows)
            {
                CGFloat ratio = [[self.rows tgrm_objectAtIndexCheck:1] floatValue];
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
            CGFloat ratio = [[self.cols tgrm_objectAtIndexCheck:2] integerValue];
            // 整体宽度的百分比
            if (0 < ratio && 100 >= ratio) {
                elementWidth = ceilf(contentWidth * ratio / 100);
            }
            [third setItemFrame:CGRectMake(first.marginRight+ third.marginLeft + CGRectGetMaxX(first.itemFrame), third.marginTop+second.marginBottom + CGRectGetMaxY(second.itemFrame),elementWidth, rightHeight)];
            bottom = MAX(CGRectGetMaxY(third.itemFrame) + third.marginBottom, bottom);
            
            // 第四个，最后一个了
            lastContentWidth = lastContentWidth - elementWidth;
            elementWidth = lastContentWidth;
            ratio = [[self.cols tgrm_objectAtIndexCheck:3] integerValue];
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
            contentWidth = self.width - first.marginLeft - first.marginRight - third.marginLeft - third.marginRight;
            lastContentWidth = contentWidth - CGRectGetWidth(first.itemFrame);
            CGFloat elementWidth = lastContentWidth;
            CGFloat ratio = [[self.cols tgrm_objectAtIndexCheck:2] integerValue];
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
    if (!(self.aspectRatio && self.aspectRatio.length > 0 &&  [self.aspectRatio floatValue] > 0.f)) {
        self.height = bottom;
    }
    if (self.bgImgURL && self.bgImgURL.length > 0) {
        self.bgImageView.frame = CGRectMake(0, 0, self.width, self.height);
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

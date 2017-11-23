//
//  TMMuiProgressBar.m
//  TmallClient4iOS-MUI
//
//  Created by xiaoxia on 16/1/12.
//  Copyright © 2016年 Taobao lnc. All rights reserved.
//

#import "TMMuiProgressBar.h"
#import "UIImageView+WebCache.h"
#import <VirtualView/UIView+VirtualView.h>
#import "TMUtils.h"


@interface TMMuiProgressBar()

@property (nonatomic, assign) BOOL shouldAnim;

@property (nonatomic, assign) CGFloat autoHideTime;

@end

@implementation TMMuiProgressBar

-(UIView *)barView
{
    if (_barView == nil) {
        _barView = [[UIView alloc]init];
        _barView.left = 0;
        [self addSubview:_barView];
        [self bringSubviewToFront:_barView];
    }
    return _barView;
}
-(UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
        _bgImageView.left = 0;
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_bgImageView];
        [self sendSubviewToBack:_bgImageView];
    }
    return _bgImageView;
}
-(void)setBarColor:(UIColor *)barColor
{
    _barColor = barColor;
    self.barView.backgroundColor = barColor;
}
-(void)setBarWidth:(CGFloat)barWidth
{
    _barWidth = barWidth;
    self.barView.width = barWidth;
}
-(void)setBarHeight:(CGFloat)barHeight
{
    _barHeight = barHeight;
    self.barView.height = barHeight;
}
-(CGFloat)autoHideTime
{
    return .5f;
}
-(void)setAutoHide:(BOOL)autoHide
{
    _autoHide = autoHide;
    self.alpha = 0.f;
}
-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (self.progressBarType == LinearMUIProgressBar) {
        self.barView.width = self.barWidth + (self.width - self.barWidth) * progress;
        self.barView.left = 0.f;
        if (self.barView.width <=  self.barWidth) {
            self.barView.width = self.barWidth;
        }
    }
    else
    {
        self.alpha = 1.f;
        self.barView.centerX = (self.width - self.barView.width) * progress + self.barView.width / 2;
        if (self.barView.left < 0)
        {
            self.barView.left = 0;
        }
        else if(self.barView.right > self.width)
        {
            self.barView.right = self.width;
        }
        if (self.autoHide && !self.shouldAnim) {
            self.shouldAnim = YES;
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoHideTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = self;
                [UIView animateWithDuration:0.5f animations:^{
                    strongSelf.alpha = 0.f;
                    strongSelf.shouldAnim = NO;
                }];
            });
        }
    }
}
-(void)setBgImgURL:(NSString *)bgImgURL
{
    _bgImgURL = bgImgURL;
    if (bgImgURL.length > 0) {
        __weak typeof(self) weakSelf = self;
        
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:bgImgURL] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!error)
            {
                strongSelf.bgImageView.width = strongSelf.width;
                strongSelf.bgImageView.height = strongSelf.bgImageView.width * image.size.height / strongSelf.bgImageView.width;
                if(strongSelf.bgImageView.height > strongSelf.height)
                {
                    strongSelf.bgImageView.height = strongSelf.height;
                }
                strongSelf.bgImageView.bottom = strongSelf.height;
                strongSelf.bgImageView.image = image;
            }
        }];
    }
}

@end

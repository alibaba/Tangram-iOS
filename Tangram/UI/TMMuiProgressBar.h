//
//  TMMuiProgressBar.h
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,MUIProgressBarType)
{
    LinearMUIProgressBar = 0,
    BlockMUIProgressBar
};


@interface TMMuiProgressBar : UIView

//bar的颜色
@property (nonatomic, strong) UIColor *barColor;
//背景URL 底边和View的bottom对齐
@property (nonatomic, strong) NSString *bgImgURL;
//背景Image
@property (nonatomic, strong) UIImageView *bgImageView;
//bar的高度
@property (nonatomic, assign) CGFloat barHeight;
//bar的宽度
@property (nonatomic, assign) CGFloat barWidth;
//设置进度
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) MUIProgressBarType progressBarType;

@property (nonatomic, assign) BOOL autoHide;

@property (nonatomic, strong) UIView *barView;


@end

//
//  TangramSingleImageElement.m
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/26.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramSingleImageElement.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TangramSingleImageElement()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation TangramSingleImageElement

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        self.backgroundColor = [UIColor grayColor];
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor redColor];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}
-(void)setImgUrl:(NSString *)imgUrl
{
    if (imgUrl.length > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (frame.size.width > 0 && frame.size.height > 0) {
        [self mui_afterGetView];
    }
}

- (void)mui_afterGetView
{
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.titleLabel.text = [NSString stringWithFormat:@"%ld",[self.number longValue]];
    [self.titleLabel sizeToFit];
}


+ (CGFloat)heightByModel:(TangramDefaultItemModel *)itemModel;
{
    return 100.f;
}
@end

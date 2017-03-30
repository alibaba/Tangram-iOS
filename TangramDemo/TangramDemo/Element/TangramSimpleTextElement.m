//
//  TangramSimpleTextElement.m
//  TangramDemo
//
//  Created by xiaoxia on 2017/3/7.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "TangramSimpleTextElement.h"

@interface TangramSimpleTextElement()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TangramSimpleTextElement

- (UILabel *)label
{
    if (nil == _label) {
        _label = [[UILabel alloc]init];
        [self addSubview:_label];
    }
    return _label;
}

- (void)mui_afterGetView
{
    self.label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.label.text = self.text;
}

+ (CGFloat)heightByModel:(TangramDefaultItemModel *)itemModel
{
    return 60.f;
}
@end

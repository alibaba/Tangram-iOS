//
//  TangramSimpleTextElement.m
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramSimpleTextElement.h"
#import "TangramDefaultItemModel.h"

@interface TangramSimpleTextElement()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TangramSimpleTextElement

- (UILabel *)label
{
    if (nil == _label) {
        _label = [[UILabel alloc]init];
        [self addSubview:_label];
        _label.font = [UIFont systemFontOfSize:14.f];
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
    return 30.f;
}
@end

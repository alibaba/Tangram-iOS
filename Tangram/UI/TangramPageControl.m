//
//  TangramPageControl.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "TangramPageControl.h"
#import "TMUtils.h"
#define ELEMENT_WIDTH       4
#define ELEMENT_HEIGHT      4
#define ELEMENT_SPACING     10

@interface TangramPageControl()
{
    NSMutableArray *_norDots;
}
@end

@implementation TangramPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _pageWidth = ELEMENT_WIDTH;
        _pageHeight = ELEMENT_HEIGHT;
        _pageSpacing = ELEMENT_SPACING;
        
        _norDots = [[NSMutableArray alloc] init];
        
        _selectedFillColor = [UIColor clearColor];
        _normalFillColor = [UIColor clearColor];
    }
    
    return self;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat width = (pageCount * _pageWidth) + ((pageCount-1) * _pageSpacing);
    return CGSizeMake(width, _pageHeight);
}

-(void)createDotIndicators
{
    [_norDots makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_norDots removeAllObjects];
    
    for (int i=0; i<_numberOfPages; i++) {
        
        switch (_style)
        {
            case TangramPageControlStyleDefault:
            {
                CAShapeLayer *layer = [CAShapeLayer layer];
                UIBezierPath *ellipse = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, _pageWidth, _pageHeight)];
                layer.path = [ellipse CGPath];
                
                layer.fillColor = i==_currentPage? _selectedFillColor.CGColor:_normalFillColor.CGColor;
                [self.layer addSublayer:layer];
                
                [_norDots addObject:layer];
                break;
            }
                
            case TangramPageControlStyleImage:
            {
                CALayer *layer = [CALayer layer];
                layer.contents=(__bridge id)(i==_currentPage?_selectedImage.CGImage:_normalImage.CGImage);
                layer.contentsScale = [UIScreen mainScreen].scale;
                [self.layer addSublayer:layer];
                
                [_norDots addObject:layer];
                break;
            }
        }
        
    }
    
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (_numberOfPages <= 1 && _hidesForSinglePage) {
        return;
    }
    
    CGSize size = self.bounds.size;
    CGSize dotSize = [self sizeForNumberOfPages:_numberOfPages];
    __block CGRect frame = CGRectMake((size.width-dotSize.width)/2.0,
                              (size.height-dotSize.height)/2.0,
                              _pageWidth,
                              _pageHeight);
    
    [_norDots enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        switch (self->_style)
        {
            case TangramPageControlStyleDefault:
            {
                if ([layer isKindOfClass:[CAShapeLayer class]]) {
                    CAShapeLayer *shapeLayer = (CAShapeLayer*)layer;
                    shapeLayer.frame = frame;
                    
                    UIBezierPath *ellipse = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self->_pageWidth, self->_pageHeight)];
                    shapeLayer.path = [ellipse CGPath];
                    
                    shapeLayer.fillColor = idx==self->_currentPage? self->_selectedFillColor.CGColor:self->_normalFillColor.CGColor;

                }
                break;
            }
            case TangramPageControlStyleImage:
            {
                layer.frame = frame;
                layer.contents=(__bridge id)(idx==self->_currentPage?self->_selectedImage.CGImage:self->_normalImage.CGImage);
                break;
            }
        }
        frame.origin.x += (self->_pageWidth + self->_pageSpacing);
    }];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize dotSize = [self sizeForNumberOfPages:_numberOfPages];
    return CGSizeMake(MAX(dotSize.width, self.bounds.size.width), MAX(dotSize.height, self.bounds.size.height));
}

//static int index_clamp(int index,int arraylength)
//{
//    return index - floorf((float)index / arraylength) * arraylength;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    
//    if (point.x < self.width/2) {
//        self.currentPage = index_clamp(_currentPage-1, _numberOfPages);
//    } else {
//        self.currentPage = index_clamp(_currentPage+1, _numberOfPages);
//    }
//}

#pragma mark getter & setter
- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage == currentPage || 0 > currentPage) {
        return;
    }
    
    //swap dots
    NSInteger prepage = _currentPage;
    _currentPage = currentPage;
    
    switch (_style)
    {
        case TangramPageControlStyleDefault:
        {
            CAShapeLayer *cur = (CAShapeLayer*)[_norDots tm_safeObjectAtIndex:_currentPage];
            cur.fillColor =  _selectedFillColor.CGColor;

            CAShapeLayer *prev = (CAShapeLayer*)[_norDots tm_safeObjectAtIndex:prepage];
            prev.fillColor = _normalFillColor.CGColor;
            break;
        }
            
        case TangramPageControlStyleImage:
        {
            CALayer *cur = (CALayer*)[_norDots tm_safeObjectAtIndex:_currentPage];
            cur.contents =  (id)_selectedImage.CGImage;
            
            CALayer *prev = (CALayer*)[_norDots tm_safeObjectAtIndex:prepage];
            prev.contents = (id)_normalImage.CGImage;
            break;
        }
    }
}

- (void)setStyle:(TangramPageControlStyle)style
{
    _style = style;
    if (_norDots.count) {
        [self setNeedsLayout];
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    if (_norDots.count) {
        [self setNeedsLayout];
    }
}

- (void)setNormalImage:(UIImage *)normalImage
{
    _normalImage = normalImage;
    
    if (_norDots.count) {
        [self setNeedsLayout];
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages == _numberOfPages) {
        return;
    }
    _numberOfPages = numberOfPages;
    
    [self createDotIndicators];
    
    if (_currentPage >= numberOfPages) {
        self.currentPage = 0;
    }
    
    [self setNeedsLayout];
}

@end

# Tangram-iOS Getting-Started Guide

All Code can be found in `TangramDemo`

For QuickStart, we Use default helper and parser

Use Default helper can significantly reduce the workload.

Default Helper can easily map attribute to element(using KVC).

## Build an element

Generate a element as a subclass of UIView , and implement `TangramElementHeightProtocol` and `TMMuiLazyScrollViewCellProtocol`
, then state propreties you need.

### implement TangramElementHeightProtocol

`TangramHeightProtocol` is used to return a height for Element. 

In Tangram, the width of element is set by layout, height returned from element class method. Unless set height or width in the style of element.

Element should implement the class method following:

`+ (CGFloat)heightByModel:(TangramDefaultItemModel *)itemModel;`

In this method, the properties of the param `itemModel` is set.So you can get width by `itemModel.itemFrame.size.width`

### implement TMMuiLazyScrollViewCellProtocol

Tangram is based on LazyScrollView. You can do something in the life cycle of element by LazyScrollView API.

`- (void)mui_afterGetView;`

This method will be executed when the element will enter visible area. So we can finish internal layout in this method.

### State properties

Default Helper will map attribute from a dictionary to the element.You don't need to parse param again. The way to do this is using KVC.

Finally we make a element like this. It's a element contains a singleImage.

**TangramSingleImageElement.h**

```objc
#import <UIkit/UIkit.h>
#import "TangramElementHeightProtocol.h"
#import "TMMuiLazyScrollView.h"

@interface TangramSingleImageElement : UIView<TangramElementHeightProtocol,TMMuiLazyScrollViewCellProtocol>

@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSNumber *number;

@end
```

**TangramSingleImageElement.m**

```objc
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
```

##  Set TangramView

### Regist element to default factory

If you want to regist type 1 to `TangramSingleImageElement`

do like this.

```objc
[TangramDefaultItemModelFactory registElementType:@"1" className:@"TangramSingleImageElement"];
```


### Parse JSON Data to layout instance

Use `TangramDefaultDataSourceHelper` to parse JSON to a layout array.

```objc
 NSString *mockDataPath = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TangramMock" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
 NSDictionary *dict = [mockDataPath objectFromJSONString];
 self.layoutModelArray = [[dict objectForKey:@"data"] objectForKey:@"cards"];
 self.layoutArray = [TangramDefaultDataSourceHelper layoutsWithArray:self.layoutModelArray];
```
 
 About `TangramMock.json` , you can find it in TangramDemo

### implement TangramViewDatasource

`- (NSUInteger)numberOfLayoutsInTangramView:(TangramView *)view;`

return layout count.

eg: 

```objc
- (NSUInteger)numberOfLayoutsInTangramView:(TangramView *)view
{
    return self.layoutModelArray.count;
}
```


`- (UIView<TangramLayoutProtocol> *)layoutInTangramView:(TangramView *)view atIndex:(NSUInteger)index;`

Return the layout instance depend on index

eg: 

```objc
    - (UIView<TangramLayoutProtocol> *)layoutInTangramView:(TangramView *)view atIndex:(NSUInteger)index
{
    return [self.layoutArray objectAtIndex:index];
}
```

`- (NSUInteger)numberOfItemsInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout`

Return itemModel count by a layout.


eg:

```objc
- (NSUInteger)numberOfItemsInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout
{
    return layout.itemModels.count;
}
```


`- (NSObject<TangramItemModelProtocol> *)itemModelInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index;`

Return itemModel by a itemModel index in layout .

eg:

```objc
- (NSObject<TangramItemModelProtocol> *)itemModelInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    return [layout.itemModels objectAtIndex:index];;
}
```

`- (UIView *)itemInTangramView:(TangramView *)view withModel:(NSObject<TangramItemModelProtocol> *)model forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index;`

Return element(view) in the layout by index.

Recommend get reuseable view first by `[view dequeueReusableItemWithIdentifier:model.reuseIdentifier]`;

eg:

```objc
- (UIView *)itemInTangramView:(TangramView *)view withModel:(NSObject<TangramItemModelProtocol> *)model forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    UIView *reuseableView = [view dequeueReusableItemWithIdentifier:model.reuseIdentifier];
    
    if (reuseableView) {
        reuseableView =  [TangramDefaultDataSourceHelper refreshElement:reuseableView byModel:model];
    }
    else
    {
        reuseableView =  [TangramDefaultDataSourceHelper elementByModel:model];
    }
    return reuseableView;
}
```

### Create a TangramView

Create a TangramView like this...

```objc
_tangramView = [[TangramView alloc]init];
_tangramView.frame = self.view.bounds;
[_tangramView setDataSource:self];
_tangramView.backgroundColor = [UIColor whiteColor];
[self.view addSubview:_tangramView];
```
 
### Finally, reload 
 
```objc
[self.tangramView reloadData];
```

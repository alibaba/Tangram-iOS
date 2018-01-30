//
//  ViewController.m
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//
#define TESTLAYOUT_NUMBER 20
#define TESTCOLUMN 3
#define TESTROW 4

#import "ViewController.h"
#import "TangramView.h"
#import "TangramLayoutProtocol.h"
#import "TangramSingleAndDoubleLayout.h"
#import "TangramFlowLayout.h"
#import "TangramFixLayout.h"
#import "TangramStickyLayout.h"
#import "TangramFixTopLayout.h"
#import "TangramWaterFlowLayout.h"
#import "TangramDragableLayout.h"

@interface DemoItemModel : NSObject<TangramItemModelProtocol>

@property   (nonatomic, assign) CGRect          itemModelFrame;
@property   (nonatomic, assign) BOOL            isBlock;
@property   (nonatomic, assign) NSUInteger      indexInLayout;

@end

@interface DemoItem : UIView

@property   (nonatomic, strong) DemoItemModel   *itemModel;

@end

@interface DemoLayout : TangramFlowLayout

@property   (nonatomic, assign) NSUInteger      index;

@end

@implementation DemoItemModel

- (void)setItemFrame:(CGRect)itemFrame
{
    _itemModelFrame = itemFrame;
}
- (CGRect)itemFrame
{
    //return _itemModelFrame;
    return CGRectMake(_itemModelFrame.origin.x,_itemModelFrame.origin.y, _itemModelFrame.size.width, _itemModelFrame.size.height);
}

- (NSString *)display
{
    //    if (self.isBlock) {
    //        return @"block";
    //    }
    return @"inline";
}

- (TangramItemType *)itemType
{
    return @"demo";
}

- (NSString *)reuseIdentifier
{
    return @"demo_model_reuse_identifier";
}
- (CGFloat)marginTop
{
    return 5.f;
}
- (CGFloat)marginRight
{
    return 5.f;
}
- (CGFloat)marginBottom
{
    return 5.f;
}
- (CGFloat)marginLeft
{
    return 5.f;
}
@end

@implementation DemoItem

- (NSObject<TangramItemModelProtocol> *)model
{
    return _itemModel;
}
@end

@implementation DemoLayout


- (TangramLayoutType *)layoutType
{
    return [NSString stringWithFormat:@"xxxxx_%lu", self.index];
}




@end
//普通布局测试区结束
//Fix 布局测试区


@interface DemoFixModel : NSObject<TangramItemModelProtocol>

@property   (nonatomic, assign) NSUInteger      index;
@property   (nonatomic, assign) CGRect          itemModelFrame;

@end


@implementation DemoFixModel

- (CGFloat)marginTop
{
    return 0.f;
}
- (CGFloat)marginLeft
{
    return 0.f;
}
- (CGFloat)marginRight
{
    return 0.f;
}
- (CGFloat)marginBottom
{
    return 0.f;
}
- (NSString *)display
{
    return @"inline";
}
- (void)setItemFrame:(CGRect)itemFrame
{
    _itemModelFrame = itemFrame;
}
- (CGRect)itemFrame
{
    return CGRectMake(0,0, 100, 30);
}
- (TangramItemType *)itemType
{
    return @"demo";
}

- (NSString *)reuseIdentifier
{
    return @"";
}


@end

//Fix 固定布局测试区 结束
@interface ViewController ()<TangramViewDatasource,TangramViewDelegate>

@property (nonatomic, assign) NSUInteger totalIndex;

@end

@implementation ViewController


#pragma mark - TangramViewDatasource
- (UIView *)itemInTangramView:(TangramView *)view withModel:(NSObject<TangramItemModelProtocol> *)model forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    
    //首先查找是否有可以复用的Item,是否可以复用是根据它的reuseIdentifier决定的
    //layout不复用，复用的是item
    DemoItem *item = (DemoItem *)[view dequeueReusableItemWithIdentifier:model.reuseIdentifier];
    if (nil == item) {
        item = [[DemoItem alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 0.f) reuseIdentifier:model.reuseIdentifier];
    }
    item.backgroundColor = [self randomColor];
//    if ([layout isKindOfClass:[TangramFixLayout class]] || [layout isKindOfClass:[TangramStickyLayout class]] || [layout isKindOfClass:[TangramSingleAndDoubleLayout class]] || [layout isKindOfClass:[TangramWaterFlowLayout class]] || [layout isKindOfClass:[TangramDragableLayout class]]) {
//        return item;
//    }
    UILabel *testLabel = [item viewWithTag:1001];
    if (!testLabel) {
        testLabel = [[UILabel alloc]init];
        testLabel.frame =CGRectMake(2, 2, 30,30);
        testLabel.textColor = [UIColor whiteColor];
        testLabel.tag = 1001;
        [item addSubview:testLabel];
    }
    testLabel.text = [NSString stringWithFormat:@"%ld",index];
    item.clipsToBounds = YES;
    return item;
}
//Layout不做复用，复用的是Item
- (UIView<TangramLayoutProtocol> *)layoutInTangramView:(TangramView *)view atIndex:(NSUInteger)index
{
    if (index == 0) {
        //固定布局
        TangramDragableLayout *fixLayout = [[TangramDragableLayout alloc]init];
        //fixLayout.margin = @[@100,@0,@0,@0];
        fixLayout.alignType = TopRight;
        fixLayout.offsetX = 100;
        fixLayout.offsetY = 100;
        return fixLayout;
    }
    if (index == 1) {
        //一拖N布局
        TangramSingleAndDoubleLayout *layout = [[TangramSingleAndDoubleLayout alloc]init];
        layout.rows = @[@40,@60];
        return layout;
    }
    if (index == 3) {
        //吸顶布局
        TangramStickyLayout *floatLayout = [[TangramStickyLayout alloc]init];
        return floatLayout;
    }
    if (index == 6){
        TangramWaterFlowLayout *waterFlowLayout = [[TangramWaterFlowLayout alloc]init];
        return waterFlowLayout;
    }
    //普通流式布局
    DemoLayout *layout = [[DemoLayout alloc] init];
    layout.margin = @[@10,@20,@20,@20];
    //layout.aspectRatio = @"5";
    //控制列数，行数根据Item个数自己算
    //在Tangram的FlowLayout里面，行数默认是1
    layout.numberOfColumns = index % 5 + 1;
    layout.hGap = 3;
    layout.vGap = 5;
    layout.index = index;
    layout.backgroundColor = [self randomColor];
    return layout;
}

- (NSObject<TangramItemModelProtocol> *)itemModelInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    if ([layout isKindOfClass:[TangramDragableLayout class]] || [layout isKindOfClass:[TangramStickyLayout class]]) {
        DemoFixModel *fixModel = [[DemoFixModel alloc]init];
        return fixModel;
    }
    DemoItemModel *model = [[DemoItemModel alloc] init];
    model.indexInLayout = index;
    [model setItemFrame:CGRectMake(model.itemFrame.origin.x,model.itemFrame.origin.y, model.itemFrame.size.width, 150)];
    if ([layout isKindOfClass:[TangramWaterFlowLayout class]]) {
        [model setItemFrame:CGRectMake(model.itemFrame.origin.x,model.itemFrame.origin.y, model.itemFrame.size.width, (arc4random() % 120) + 30)];
    }
    return model;
}

- (NSUInteger)numberOfLayoutsInTangramView:(TangramView *)view
{
    return TESTLAYOUT_NUMBER;
}

- (NSUInteger)numberOfItemsInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout
{
    if ([layout isKindOfClass:[TangramFixLayout class]]) {
        return 1;
    }
    if ([layout isKindOfClass:[TangramSingleAndDoubleLayout class]]) {
        return 4;
    }
    if ([layout isKindOfClass:[TangramWaterFlowLayout class]]) {
        return 10;
    }
    if ([layout isKindOfClass:[TangramStickyLayout class]]) {
        return 1;
    }
    return 4;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalIndex = 0;
    TangramView *tangramView = [[TangramView alloc] initWithFrame:self.view.bounds];
    tangramView.dataSource  = self;
    tangramView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:tangramView];
    tangramView.fixExtraOffset = 64.f;
    [tangramView setDelegate:self];
    [tangramView reloadData];
}

#pragma mark - Private

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end

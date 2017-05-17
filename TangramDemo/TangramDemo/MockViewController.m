//
//  MockViewController.m
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/12/31.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MockViewController.h"
#import <Tangram/TangramView.h>
#import <Tangram/TangramDefaultDataSourceHelper.h>
#import <Tangram/TangramDefaultItemModelFactory.h>
#import <Tangram/TangramContext.h>
#import <Tangram/TangramEvent.h>
#import <Tangram/TangramSafeMethod.h>


@interface MockViewController ()<TangramViewDatasource>

@property (nonatomic, strong) NSMutableArray *layoutModelArray;

@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, strong) TangramView    *tangramView;

@property (nonatomic, strong) NSArray *layoutArray;

@property  (nonatomic, strong) TangramBus *tangramBus;


@end

@implementation MockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadMockContent];
    [self registEvent];
    [self.tangramView reloadData];
    // Do any additional setup after loading the view.
}

- (TangramBus *)tangramBus
{
    if (nil == _tangramBus) {
        _tangramBus = [[TangramBus alloc]init];
    }
    return _tangramBus;
}
-(NSMutableArray *)modelArray
{
    if (nil == _modelArray) {
        _modelArray = [[NSMutableArray alloc]init];
    }
    return _modelArray;
}

-(TangramView *)tangramView
{
    if (nil == _tangramView) {
        _tangramView = [[TangramView alloc]init];
        _tangramView.frame = self.view.bounds;
        [_tangramView setDataSource:self];
        _tangramView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_tangramView];
    }
    return _tangramView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadMockContent
{
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TangramMock" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
    self.layoutModelArray = [[dict objectForKey:@"data"] objectForKey:@"cards"];
    [TangramDefaultItemModelFactory registElementType:@"1" className:@"TangramSingleImageElement"];
    [TangramDefaultItemModelFactory registElementType:@"2" className:@"TangramSimpleTextElement"];
//    [TangramDefaultItemModelFactory registElementType:@"110" className:@"TangramSingleImageElement"];
//    [TangramDefaultItemModelFactory registElementType:@"202" className:@"TangramSingleImageElement"];
//    [TangramDefaultItemModelFactory registElementType:@"203" className:@"TangramSingleImageElement"];
//    [TangramDefaultItemModelFactory registElementType:@"204" className:@"TangramSingleImageElement"];
    self.layoutArray = [TangramDefaultDataSourceHelper layoutsWithArray:self.layoutModelArray tangramBus:self.tangramBus];
}

- (void)registEvent
{
    [self.tangramBus registerAction:@"responseToClickEvent:" ofExecuter:self onEventTopic:@"jumpAction"];
}

- (void)responseToClickEvent:(TangramContext *)context
{
    NSString *action = [context.event.params tgrm_stringForKey:@"action"];
    NSLog(@"Click Action: %@",action);
}
- (NSUInteger)numberOfLayoutsInTangramView:(TangramView *)view
{
    return self.layoutModelArray.count;
}

- (UIView<TangramLayoutProtocol> *)layoutInTangramView:(TangramView *)view atIndex:(NSUInteger)index
{
    return [self.layoutArray objectAtIndex:index];
}
- (NSUInteger)numberOfItemsInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout
{
    return layout.itemModels.count;
}

- (NSObject<TangramItemModelProtocol> *)itemModelInTangramView:(TangramView *)view forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    return [layout.itemModels objectAtIndex:index];;
}

- (UIView *)itemInTangramView:(TangramView *)view withModel:(NSObject<TangramItemModelProtocol> *)model forLayout:(UIView<TangramLayoutProtocol> *)layout atIndex:(NSUInteger)index
{
    UIView *reuseableView = [view dequeueReusableItemWithIdentifier:model.reuseIdentifier ];
    
    if (reuseableView) {
        reuseableView =  [TangramDefaultDataSourceHelper refreshElement:reuseableView byModel:model layout:layout tangramBus:self.tangramBus];
    }
    else
    {
        reuseableView =  [TangramDefaultDataSourceHelper elementByModel:model layout:layout tangramBus:self.tangramBus];
    }
    return reuseableView;
}
@end

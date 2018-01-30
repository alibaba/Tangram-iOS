//
//  EntryTableViewController.m
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "EntryTableViewController.h"
#import "ViewController.h"
#import "MockViewController.h"

@interface EntryTableViewController ()
@property (nonatomic, strong) NSArray *testArray;
@end

@implementation EntryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray *)testArray
{
    return @[
             @{@"name":@"自定义布局-色块Demo(不使用Helper)", @"entry":@"ViewController"},
             @{@"name":@"JSON数据Demo(使用Helper)", @"entry":@"MockViewController"}
             ];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TEST"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TEST"];
    }
    // Configure the cell...
    NSDictionary *dict = [self.testArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     //NSDictionary *dict = [self.testArray objectAtIndex:indexPath.row];
    //NSString *controllerName = [dict objectForKey:@"entry"];
    if (indexPath.row == 0) {
          [self.navigationController pushViewController:[[ViewController alloc]init] animated:YES];
    }
    if (indexPath.row == 1) {
        [self.navigationController pushViewController:[[MockViewController alloc]init] animated:YES];
    }
    //[self performSelector:NSSelectorFromString(method) withObject:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end

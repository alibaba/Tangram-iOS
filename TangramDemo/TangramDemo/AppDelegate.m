//
//  AppDelegate.m
//  TangramDemo
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "AppDelegate.h"
#import "EntryTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[EntryTableViewController new]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

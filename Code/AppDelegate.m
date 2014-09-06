//
//  AppDelegate.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AppDelegate.h"
#import "GitHubClient.h"
#import "IssueList.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    //[GitHubClient clearCredentials];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[IssueList new]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

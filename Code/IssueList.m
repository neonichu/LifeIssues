//
//  IssueList.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <OctoKit/OctoKit.h>

#import "GitHubClient.h"
#import "IssueCell.h"
#import "IssueList.h"
#import "LoginViewController.h"

@interface IssueList ()

@property (nonatomic) NSArray* issues;

@end

#pragma mark -

@implementation IssueList

-(instancetype)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Issues", nil);

        [self.tableView registerClass:IssueCell.class
               forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return self;
}

-(void)refresh {
    [[GitHubClient sharedClient] fetchIssuesForRepositoryWithName:@"life"
                                                completionHandler:^(NSArray *issues) {
                                                    self.issues = issues;

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView reloadData];
                                                    });
                                                }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([GitHubClient sharedClient].accessToken) {
        [self refresh];
    } else {
        LoginViewController* loginViewController = [LoginViewController new];
        [self presentViewController:loginViewController animated:animated completion:nil];

        loginViewController.loginSuccessHandler = ^{
            [self refresh];
        };
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IssueCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)
                                                      forIndexPath:indexPath];

    OCTIssue* issue = self.issues[indexPath.row];

    cell.checked = NO;
    cell.textLabel.text = issue.title;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.issues.count;
}

@end

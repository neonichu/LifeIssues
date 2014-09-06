//
//  LoginViewController.h
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoginSuccessHandler)();

@interface LoginViewController : UITableViewController

@property (nonatomic, copy) LoginSuccessHandler loginSuccessHandler;

@end

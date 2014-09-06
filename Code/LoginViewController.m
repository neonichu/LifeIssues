//
//  LoginViewController.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GitHubClient.h"
#import "LoginViewController.h"
#import "TextFieldCell.h"
#import "UIView+Geometry.h"

@interface LoginViewController ()

@property (nonatomic, weak) UIButton* loginButton;
@property (nonatomic, weak) UITextField* passwordTextField;
@property (nonatomic) BOOL showsOneTimePasswordField;
@property (nonatomic, weak) UITextField* twoFactorAuthCodeTextField;
@property (nonatomic, weak) UITextField* usernameTextField;

@end

#pragma mark -

@implementation LoginViewController

-(instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView registerClass:TextFieldCell.class
               forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return self;
}

-(void)showOneTimePasswordField {
    if (self.showsOneTimePasswordField) {
        return;
    }

    self.showsOneTimePasswordField = YES;

    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationBottom];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSParameterAssert(self.loginButton);
    NSParameterAssert(self.passwordTextField);
    NSParameterAssert(self.usernameTextField);

    RACSignal* validPasswordSignal = [self.passwordTextField.rac_textSignal
                                      map:^id(NSString* text) {
                                          return @(text.length > 0);
                                      }];

    RACSignal* validUsernameSignal = [self.usernameTextField.rac_textSignal
                                      map:^id(NSString *text) {
                                          return @(text.length > 0);
                                      }];

    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
                          return @([usernameValid boolValue] && [passwordValid boolValue]);
                      }];

    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
        self.loginButton.enabled = [signupActive boolValue];
    }];
}

#pragma mark - Actions

-(void)loginTapped {
    NSString *oneTimePassword;

    if (self.twoFactorAuthCodeTextField) {
        oneTimePassword = self.twoFactorAuthCodeTextField.text;
    } else {
        oneTimePassword = nil;
    }

    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;

    OCTUser* user = [OCTUser userWithRawLogin:username server:OCTServer.dotComServer];

    [[[OCTClient
       signInAsUser:user password:password oneTimePassword:oneTimePassword scopes:OCTClientAuthorizationScopesUser]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTClient *client) {
         [[GitHubClient sharedClient] storeCredentialsFromClient:client];

         dispatch_async(dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES
                                      completion:^{
                                          if (self.loginSuccessHandler) {
                                              self.loginSuccessHandler();
                                          }
                                      }];
         });
     } error:^(NSError *error) {
         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
             [self showOneTimePasswordField];
         } else {
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
             [alert show];
         }
     }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)
                                                          forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Username", nil);
            self.usernameTextField = cell.textField;
            break;

        case 1:
            cell.textLabel.text = NSLocalizedString(@"Password", nil);
            self.passwordTextField = cell.textField;
            self.passwordTextField.secureTextEntry = YES;
            break;

        case 2:
            cell.textLabel.text = NSLocalizedString(@"2FA Code", nil);
            self.twoFactorAuthCodeTextField = cell.textField;
            break;
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showsOneTimePasswordField ? 3 : 2;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell* cell = (TextFieldCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 100.0)];

    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.enabled = NO;
    self.loginButton.size = CGSizeMake(200.0, 44.0);
    self.loginButton.x = (footerView.width - self.loginButton.width) / 2;
    self.loginButton.y = (footerView.height - self.loginButton.height) / 2;
    [self.loginButton addTarget:self
                         action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [footerView addSubview:self.loginButton];

    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 100.0)];

    UILabel* hintLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.frame, 10.0, 0.0)];
    hintLabel.numberOfLines = 0;
    hintLabel.text = NSLocalizedString(@"Please login with your GitHub account to access your issues.",
                                       nil);
    [headerView addSubview:hintLabel];

    return headerView;
}

@end

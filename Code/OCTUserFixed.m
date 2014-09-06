//
//  OCTUserFixed.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "OCTUserFixed.h"

@implementation OCTUserFixed

-(NSString *)login {
    return super.login ?: self.rawLogin;
}

@end

//
//  OCTClient+Issues.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "OCTClient+Issues.h"

@implementation OCTClient (Issues)

- (RACSignal *)fetchIssuesForRepository:(OCTRepository*)repo {
    NSParameterAssert(repo);

    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repo.ownerLogin, repo.name];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];

    return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

@end

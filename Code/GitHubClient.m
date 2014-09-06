//
//  GitHubClient.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>

#import "GitHubClient.h"
#import "OCTClient+Issues.h"

static NSString* const GHAPIClientId        = @"GHAPIClientId";
static NSString* const GHAPIClientSecret    = @"GHAPIClientSecret";
static NSString* const GHServiceKey         = @"GHServiceKey";

@implementation GitHubClient

+(void)clearCredentials {
    for (NSDictionary* account in [SSKeychain accountsForService:GHServiceKey]) {
        [SSKeychain deletePasswordForService:GHServiceKey account:account[kSSKeychainAccountKey]];
    }
}

+(instancetype)sharedClient {
    static GitHubClient* sharedClient = nil;

    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        [OCTClient setClientID:GHAPIClientId clientSecret:GHAPIClientSecret];

        sharedClient = [GitHubClient new];
    });

    return sharedClient;
}

#pragma mark -

-(NSString *)accessToken {
    if (!self.username) {
        return nil;
    }

    return [SSKeychain passwordForService:GHServiceKey account:self.username];
}

-(void)fetchIssuesForRepositoryWithName:(NSString*)repoName
                      completionHandler:(void(^)(NSArray* issues))completionHandler {
    OCTUser *user = [OCTUser userWithRawLogin:self.username server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:self.accessToken];

    RACSignal *request = [client fetchRepositoryWithName:repoName owner:self.username];
    [[request flattenMap:^RACStream *(OCTRepository* repo) {
        return [[client fetchIssuesForRepository:repo] collect];
    }] subscribeNext:completionHandler];
}

-(void)storeCredentialsFromClient:(OCTClient *)client {
    [SSKeychain setPassword:client.token forService:GHServiceKey account:client.user.rawLogin];
}

-(NSString *)username {
    NSArray* accounts = [SSKeychain accountsForService:GHServiceKey];

    if (accounts.count == 0) {
        return nil;
    }

    return accounts[0][kSSKeychainAccountKey];
}

@end

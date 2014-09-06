//
//  GitHubClient.h
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit/OctoKit.h>

@interface GitHubClient : NSObject

@property (nonatomic, readonly) NSString* accessToken;
@property (nonatomic, readonly) NSString* username;

+(void)clearCredentials;
+(instancetype)sharedClient;

-(void)fetchIssuesForRepositoryWithName:(NSString*)repoName
                      completionHandler:(void(^)(NSArray* issues))completionHandler;
-(void)storeCredentialsFromClient:(OCTClient*)client;

@end

//
//  SQNetworkController.m
//  SynqUploader
//
//  Created by Kjartan Vestvik on 17.01.2017.
//  Copyright © 2017 Kjartan. All rights reserved.
//

#import "SQNetworkController.h"
#import <SynqHttpLib/SHLHttpClient.h>

#define TEST_USER_NAME      @"user123"
#define TEST_USER_PASSWORD  @"testuserpassword"

@interface SQNetworkController () {
    SHLHttpClient *client;
}
@end


@implementation SQNetworkController


- (id) init
{
    if (self = [super init]) {
        client = [[SHLHttpClient alloc] init];
    }
    return self;
}


#pragma mark - User methods


- (void) createUser
{
    [client createUserWithName:TEST_USER_NAME
                      password:TEST_USER_PASSWORD
                  successBlock:^(NSDictionary *jsonResponse) {
                      NSLog(@"User create ok, response: %@", jsonResponse);
                      
                      // If user create ok, login user:
                      [self loginUser];
                  }
              httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                  NSLog(@"User create error: %@", error);
              }];
}


- (void) loginUser
{
    [client loginUserWithName:TEST_USER_NAME
                     password:TEST_USER_PASSWORD
                 successBlock:^(NSDictionary *jsonResponse) {
                     NSLog(@"User login ok, response: %@", jsonResponse);
                 }
             httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                 NSLog(@"User login error: %@", error);
                 
                 // If login error, try creating user first:
                 [self createUser];
             }];
}


#pragma mark - Video methods


- (void) getUserVideos
{
    [client getUserVideosSuccessBlk:^(NSDictionary *jsonResponse) {
        NSLog(@"User videos ok, response: %@", jsonResponse);
    }
                   httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                       NSLog(@"User videos error: %@", error);
                   }];
}


- (void) createVideoWithSuccessBlock:(void (^)(NSDictionary *))successBlock
                    httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock
{
    [client createVideoAndGetParamsWithSuccess:^(NSDictionary *jsonResponse) {
        NSLog(@"Create video ok, params: %@", jsonResponse);
        
        // Call success block and pass params dictionary
        successBlock(jsonResponse);
    }
                              httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                                  NSLog(@"User videos error: %@", error);
                                  
                                  // Call failure block
                                  httpFailureBlock(task, error);
                              }];
}




@end

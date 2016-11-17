//
//  SynqAPI.m
//  SynqUploader
//
//  Created by Kjartan Vestvik on 17.11.2016.
//  Copyright © 2016 Kjartan. All rights reserved.
//

#import "SynqAPI.h"

#define BASE_URL    @"https://api.synq.fm/v1/"
#define API_KEY     @"" // WARNING: the api key should never be inserted into client code in a real-life app!


@interface SynqAPI () {
    AFHTTPSessionManager *manager;
}

@end


@implementation SynqAPI


+ (SynqAPI *) sharedInstance
{
    static dispatch_once_t once;
    static SynqAPI *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id) init
{
    if (self = [super init]) {
        // Setup the request operation manager and
        // set baseURL for the manager to be used in subsequent requests
        NSURL *baseURL = [NSURL URLWithString:BASE_URL];
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    }
    return self;
}



#pragma mark - SYNQ Video API methods


- (void) createVideo:(SQVideoUpload *)sqVideo
{
    NSDictionary *paramsDict = @{
                                 @"api_key" : API_KEY
                                 };
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"video/create"
       parameters:paramsDict
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSDictionary *jsonResponse = (NSDictionary *)responseObject;
              
              NSLog(@"Success, response: %@", jsonResponse);
              
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error: %@", error);
          }];
    
    /*
    [manager POST:@"/agents__create_human"
       parameters:paramsDict
          success:^(NSURLSessionDataTask *task, id responseObject) {
              
              NSArray *arrayOfDictionaries = (NSArray *)responseObject;
              
              if (arrayOfDictionaries) {
                  successBlock(arrayOfDictionaries);
              }
              else {
                  NSString *errorString = @"Something went wrong parsing the JSON response";
                  parseFailureBlock(errorString);
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              httpFailureBlock(task, error);
          }];
     */
}

@end

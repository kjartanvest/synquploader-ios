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
        successBlock:(void (^)(NSDictionary *))successBlock
    httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock
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
              
              successBlock(jsonResponse);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              httpFailureBlock(task, error);
          }];
}


- (void) getUploadParameters:(SQVideoUpload *)sqVideo
                successBlock:(void (^)(NSDictionary *))successBlock
            httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock
{
    NSDictionary *paramsDict = @{
                                 @"api_key"     : API_KEY,
                                 @"video_id"    : sqVideo.videoId
                                 };
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"video/upload"
       parameters:paramsDict
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSDictionary *jsonResponse = (NSDictionary *)responseObject;
              
              successBlock(jsonResponse);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              httpFailureBlock(task, error);
          }];
}

@end

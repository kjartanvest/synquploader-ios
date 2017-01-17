//
//  SQNetworkController.h
//  SynqUploader
//
//  Created by Kjartan Vestvik on 17.01.2017.
//  Copyright © 2017 Kjartan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQNetworkController : NSObject

- (void) createUser;
- (void) loginUser;

- (void) getUserVideos;
- (void) createVideoWithSuccessBlock:(void (^)(NSDictionary *))successBlock
                    httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock;

@end

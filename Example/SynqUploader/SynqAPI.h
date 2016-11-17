//
//  SynqAPI.h
//  SynqUploader
//
//  Created by Kjartan Vestvik on 17.11.2016.
//  Copyright © 2016 Kjartan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <SynqUploader/SynqUploader.h>


@interface SynqAPI : NSObject


+ (SynqAPI *) sharedInstance;

- (void) createVideo:(SQVideoUpload *)sqVideo
        successBlock:(void (^)(NSDictionary *))successBlock
    httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock;


- (void) getUploadParameters:(SQVideoUpload *)sqVideo
                successBlock:(void (^)(NSDictionary *))successBlock
            httpFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))httpFailureBlock;

@end

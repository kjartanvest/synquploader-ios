//
//  SQVideoHandler.h
//  SynqUploader
//
//  Created by Kjartan Vestvik on 15.11.2016.
//  Copyright © 2016 Kjartan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SQVideoHandler : NSObject

+ (SQVideoHandler *) sharedInstance;

@property (nonatomic, strong) NSMutableArray *deviceVideos;

//- (void) fetchDeviceVideos;

// Test method:
- (void)testCopySampleVideoToLibraryWithCompletion:(void (^)(NSError *))completionBlock;

@end

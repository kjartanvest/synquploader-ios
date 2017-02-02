//
//  SQVideoHandler.m
//  SynqUploader
//
//  Created by Kjartan Vestvik on 15.11.2016.
//  Copyright © 2016 Kjartan. All rights reserved.
//

#import "SQVideoHandler.h"
@import Photos;
#import <SynqUploader/SynqUploader.h>


@interface SQVideoHandler () {
    // Fetch result for PHAssets on iOS 8
    PHFetchResult *videoFetchResult;
    
    void (^testCompletionBlock)(NSError *);
}
@end


@implementation SQVideoHandler


+ (SQVideoHandler *) sharedInstance
{
    static dispatch_once_t once;
    static SQVideoHandler *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id) init
{
    if (self = [super init]) {
        [self fetchDeviceVideos];
    }
    return self;
}


- (void) fetchDeviceVideos
{
    // Initialize array
    self.deviceVideos = [NSMutableArray array];
    
    // Fetch video assets
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES],];
    videoFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    
    // Create SQVideoUpload object for each video on the device
    // and add them to the deviceVideos array
    for (PHAsset *asset in videoFetchResult) {
        
        SQVideoUpload *video = [[SQVideoUpload alloc] initWithPHAsset:asset];
        
        [self.deviceVideos addObject:video];
    }
}


- (void)testCopySampleVideoToLibraryWithCompletion:(void (^)(NSError *))completionBlock
{
    NSLog(@"testCopySampleVid");
    testCompletionBlock = completionBlock;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_1633" ofType:@"MOV"];
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)               video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    NSLog(@"Video saved, error: %@", error);
    testCompletionBlock(error);
}

@end

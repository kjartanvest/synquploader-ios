//
//  SQViewController.m
//  SynqUploader
//
//  Created by Kjartan on 11/15/2016.
//  Copyright (c) 2016 Kjartan. All rights reserved.
//

#import "SQViewController.h"
#import <SynqUploader/SynqUploader.h>


@interface SQViewController () <SQVideoUploadDelegate>

@end


@implementation SQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup SynqLib: set this class as delegate
    [[SynqUploader sharedInstance] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  This is an example of how to call the upload function
 */
- (void) uploadVideo
{
    // Create SQVideoUpload objects for each video to upload,
    // add PHAsset for the videos
    SQVideoUpload *video1 = [[SQVideoUpload alloc] initWithPHAsset:nil];
    SQVideoUpload *video2 = [[SQVideoUpload alloc] initWithPHAsset:nil];
    
    // Add upload parameters for each video, as a dictionary
    // This would be the parameters returned from Synq API function video/upload, and must contain the following keys:
    // "acl"
    // "key"
    // "Policy"
    // "action"
    // "Signature"
    // "Content-Type"
    // "AWSAccessKeyId"
    NSDictionary *uploadParams1;
    NSDictionary *uploadParams2;
    [video1 setUploadParameters:uploadParams1];
    [video2 setUploadParameters:uploadParams2];
    
    // Finally, add all SQVideoUpload objects to an array
    NSArray *assetsArray = [NSArray arrayWithObjects:video1, video2, nil];
    
    // Use the singleton instance to initiate an upload for the video array
    [[SynqUploader sharedInstance] uploadVideoArray:assetsArray
                           uploadProgressBlock:^(double progress) {
                               
                               NSLog(@"Upload progress: %f", progress);
                               // Report progress to UI
                               
                           } uploadSuccess:^(NSURLResponse *response) {
                               
                               NSLog(@"Upload success: %@", response);
                               // Handle upload success
                               
                           } uploadError:^(NSError *error){
                               
                               NSLog(@"Upload error: %@", error);
                               // Handle upload error
                               
                           }];
}



#pragma mark - SQVideoUploadDelegate methods


- (void) allVideosUploadedSuccessfully
{
    // Handle video upload complete
}

- (void) videoUploadCompleteForVideo:(SQVideoUpload *)video
{
    // Handle upload complete for the video (for instance, update database of uploaded videos)
}

- (void) videoUploadFailedForVideo:(SQVideoUpload *)video
{
    // Handle error
}


@end

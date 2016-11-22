//
//  SQViewController.m
//  SynqUploader
//
//  Created by Kjartan on 11/15/2016.
//  Copyright (c) 2016 Kjartan. All rights reserved.
//

#import "SQViewController.h"
#import "SQVideoHandler.h"
#import "SQCollectionViewCell.h"
#import "SynqAPI.h"
#import <SynqUploader/SynqUploader.h>


@interface SQViewController () <SQVideoUploadDelegate> {
    PHCachingImageManager *cachingImageManager;
    CGSize cellSize;
    NSIndexPath *selectedIndexPath;     // The index path of a selected video
    NSMutableArray *selectedVideos;     // Array of selected videos for uploading
}
@property (nonatomic, strong) NSMutableArray *videos;

@end


@implementation SQViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup SynqLib: set this class as delegate
    [[SynqUploader sharedInstance] setDelegate:self];
    
    // If videos should be fetched from iCloud, set enableDownloadFromICloud to YES (default NO)
    [[SynqUploader sharedInstance] setEnableDownloadFromICloud:YES];
    
    [_collectionView setAllowsMultipleSelection:YES];
    
    // Init caching manager for video thumbnails
    cachingImageManager = [[PHCachingImageManager alloc] init];
    
    selectedVideos = [NSMutableArray array];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set collectionView cell size depending on screen size
    int screenWidth = self.view.frame.size.width;
    double cellWidth = (screenWidth - 6) / 3.0;  // 3 cells per row, 3 points margin between each cell
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    cellSize = CGSizeMake(cellWidth, cellWidth);
    layout.itemSize = cellSize;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check Photos authorization
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            
            // Get device videos
            self.videos = [[SQVideoHandler sharedInstance] deviceVideos];
            
            // Reload collection view data, on main thread!
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }];
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
                                exportProgressBlock:^(double exportProgress) {
                                  
                                    NSLog(@"Export progress: %f", exportProgress);
                                    // Report progress to UI
                                  
                                }
                                uploadProgressBlock:^(double uploadProgress) {
                               
                                    NSLog(@"Upload progress: %f", uploadProgress);
                                    // Report progress to UI
                               
                                }];
}



#pragma mark - Button methods


- (IBAction)uploadButtonPushed:(id)sender {
    
    NSLog(@"Upload %lu videos", (unsigned long)selectedVideos.count);
    
    if (selectedVideos.count == 0) {
        return;
    }
    
    SQVideoUpload *video = [selectedVideos objectAtIndex:0];
    // Test: only one video:
    [self createVideoObjectForVideo:video];
}


#pragma mark - SQVideoUploadDelegate methods


- (void) allVideosUploadedSuccessfully
{
    // Handle video upload complete
    NSLog(@"All videos uploaded successfully");
}

- (void) videoUploadCompleteForVideo:(SQVideoUpload *)video
{
    // Handle upload complete for the video (for instance, update database of uploaded videos)
    NSLog(@"Upload complete for video with id %@", video.videoId);
}

- (void) videoUploadFailedForVideo:(SQVideoUpload *)video
{
    // Handle error
    NSLog(@"Upload failed for video with id %@", video.videoId);
}


#pragma mark - Video methods calling SynqAPI


- (void) createVideoObjectForVideo:(SQVideoUpload *)sqVideo
{
    [[SynqAPI sharedInstance] createVideo:sqVideo
                             successBlock:^(NSDictionary *jsonResponse) {
                                 NSString *videoID = [jsonResponse objectForKey:@"video_id"];
                                 NSLog(@"SynqAPI: create video success, video_id %@", videoID);
                                 
                                 // Set video_id in SQVideoUpload object
                                 [sqVideo setVideoId:videoID];
                                 
                                 // Get upload parameters
                                 [self getUploadParametersForVideo:sqVideo];
                             }
                         httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                             NSLog(@"MV: video create error: %@", error);
                         }];
}


- (void) getUploadParametersForVideo:(SQVideoUpload *)sqVideo
{
    [[SynqAPI sharedInstance] getUploadParameters:sqVideo
                                     successBlock:^(NSDictionary *jsonResponse) {
                                         
                                         //NSLog(@"SynqAPI: get upload params success, params: %@", jsonResponse);
                                         
                                         // Set uploadParameters in SQVideoUpload object
                                         [sqVideo setUploadParameters:jsonResponse];
                                         
                                         // Initiate the upload
                                         [self uploadVideo:sqVideo];
                                     }
                                 httpFailureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                                     NSLog(@"MV: get upload params error: %@", error);
                                 }];
}


- (void) uploadVideo:(SQVideoUpload *)sqVideo
{
    // Create an array of videos to upload (in this case only one video)
    NSArray *videosArray = [NSArray arrayWithObjects:sqVideo, nil];
    
    // Use SynqUploader to initiate exporting and uploading the videos in the array
    [[SynqUploader sharedInstance] uploadVideoArray:videosArray
                                exportProgressBlock:^(double exportProgress) {
                                  
                                    NSLog(@"Export progress: %f", exportProgress);
                                    // Report progress to UI
                                  
                                }
                                uploadProgressBlock:^(double uploadProgress) {
                                    
                                    NSLog(@"Upload progress: %f", uploadProgress);
                                    
                                    // We need progress between 0 and 1, so must divide percent by 100
                                    double progressBelowOne = uploadProgress / 100.0;
                                    // Report progress to UI
                                    [self.progressView setProgress:progressBelowOne];
                                    
                                }];
}


#pragma mark - UICollectionView delegate


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // Add video to selectedVideos array
    SQVideoUpload *video = [self.videos objectAtIndex:indexPath.row];
    [selectedVideos addObject:video];
    
    
    // Call video object functions (video/create and video/upload)
    //[self createVideoObjectForVideo:selectedVideo];
}
    
- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove video from selectedVideos array
    SQVideoUpload *video = [self.videos objectAtIndex:indexPath.row];
    [selectedVideos removeObject:video];
    
}


#pragma mark - UICollectionView datasource


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.videos count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"SQCell";
    
    SQCollectionViewCell *cell = (SQCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell.tag) {
        [cachingImageManager cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    SQVideoUpload *video = [self.videos objectAtIndex:indexPath.row];
    PHAsset *asset = [video phAsset];
    
    cell.tag = [cachingImageManager requestImageForAsset:asset
                                              targetSize:cellSize
                                             contentMode:PHImageContentModeAspectFill
                                                 options:nil
                                           resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                               cell.videoImageView.image = result;
                                           }];
    
    return cell;
}


@end

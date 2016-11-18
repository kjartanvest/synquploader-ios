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
    NSIndexPath *selectedIndexPath;     // THe index path of a selected video
    SQVideoUpload *selectedVideo;
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
    
    // Init caching manager for video thumbnails
    cachingImageManager = [[PHCachingImageManager alloc] init];
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
            NSLog(@"Number of videos: %lu", (unsigned long)self.videos.count);
            
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
                           uploadProgressBlock:^(double progress) {
                               
                               NSLog(@"Upload progress: %f", progress);
                               // Report progress to UI
                               
                           }];
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
                                uploadProgressBlock:^(double progress) {
                                    
                                    NSLog(@"Upload progress: %f", progress);
                                    // Report progress to UI
                                    
                                }];
}


#pragma mark - UICollectionView delegate


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // If a selection has already been made, do nothing
    if (selectedIndexPath) {
        return;
    }
    
    selectedVideo = [self.videos objectAtIndex:indexPath.row];
    selectedIndexPath = indexPath;
    
    SQCollectionViewCell *cell = (SQCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.videoOverlay setHidden:NO];
    
    // Call video object functions (video/create and video/upload)
    [self createVideoObjectForVideo:selectedVideo];
    
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
    
    SQVideoUpload *video = [self.videos objectAtIndex:indexPath.row];
    
    if (cell.tag) {
        [cachingImageManager cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    if (indexPath != selectedIndexPath) {
        [cell.videoOverlay setHidden:YES];
    }
    else {
        [cell.videoOverlay setHidden:NO];
    }
    
    
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

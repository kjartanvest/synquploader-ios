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
#import <SynqUploader/SynqUploader.h>


@interface SQViewController () <SQVideoUploadDelegate> {
    PHCachingImageManager *cachingImageManager;
    CGSize cellSize;
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
            NSLog(@"Number of videos: %lu", self.videos.count);
            
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

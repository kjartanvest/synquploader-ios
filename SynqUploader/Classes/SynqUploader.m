//
//  SynqUploader.m
//  Pods
//
//  Created by Kjartan Vestvik on 15.11.2016.
//
//

#import "SynqUploader.h"
#import "SQHttpClient.h"
#import "SQAssetExporter.h"


@interface SynqUploader () <SQAssetExporterDelegate>

@property (nonatomic) SQHttpClient *client;
@property (nonatomic) SQAssetExporter *exporter;
@property (nonatomic, strong) NSArray *videosToUpload;      // Array of SQVideoUpload objects
@property (strong) NSNumber *numVideosToUpload;
@property (strong) NSNumber *numVideosExported;
@property (strong) NSNumber *numVideosUploaded;
@property PHAsset *assetToUpload;

@property (nonatomic, copy) void (^uploadProgress)(double progress);
@property (nonatomic, copy) void (^uploadSuccess)(NSURLResponse *response);
@property (nonatomic, copy) void (^uploadError)(NSError *error);

@property UIBackgroundTaskIdentifier bgTask;    // identifier for the background task, used while exporting
@property NSTimer *uploadProgressTimer;         // timer for calculating upload progress during uploading

@end


@implementation SynqUploader


+ (SynqUploader *) sharedInstance
{
    static dispatch_once_t once;
    static SynqUploader *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id) init
{
    if (self = [super init]) {
        // Initialize the http client
        self.client = [[SQHttpClient alloc] init];
        
        // Initialize asset exporter
        self.exporter = [[SQAssetExporter alloc] init];
        [self.exporter setDelegate:self];
    }
    return self;
}


#pragma mark - Public upload methods


/**
 *  Upload an array of SQVideoUpload objects (with upload parameters set) to Amazon servers
 *  The upload process will also export the assets to temporary files, and delete the temporary files
 *  before calling uploadSuccess or uploadError
 *
 *  @param videos        An array of SQVideoUpload objects
 *  @param progressBlock This block will be called with upload progress updates. Use this to update the UI (the block is executed on the main thread)
 *  @param successBlock  A block called when all assets are successfully uploaded
 *  @param errorBlock    A block called on upload error, containing error data
 */
- (void) uploadVideoArray:(NSArray *)videos
      uploadProgressBlock:(void (^)(double))progressBlock
            uploadSuccess:(void (^)(NSURLResponse *))successBlock
              uploadError:(void (^)(NSError *))errorBlock
{
    if (!videos || videos.count == 0) {
        return;
    }
    
    // Set videos array and blocks
    self.videosToUpload = videos;
    self.uploadProgress = progressBlock;
    self.uploadSuccess = successBlock;
    self.uploadError = errorBlock;
    
    // Start exporting assets
    [self exportVideos];
}




#pragma mark - Private methods

#pragma mark - PHAsset exporting


/**
 *  Export each PHAsset in the videosToUpload array to files for uploading.
 *  The export process is started in a background task so that the task will
 *  continue even if the app is put to the background.
 */
- (void) exportVideos
{
    // Set counters
    self.numVideosToUpload = [NSNumber numberWithInt:0];
    self.numVideosExported = [NSNumber numberWithInt:0];
    self.numVideosUploaded = [NSNumber numberWithInt:0];
    
    // Begin background task to be able to complete export if app is put to the background
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // End the background task
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    
    for (SQVideoUpload *video in self.videosToUpload) {
        
        // If no PHAsset set for this video, skip it
        if (!video.phAsset) {
            continue;
        }
        
        // Increase numVideosToUpload counter
        int currentNum = [self.numVideosToUpload intValue];
        self.numVideosToUpload = [NSNumber numberWithInt:currentNum + 1];
        
        // Start exporting
        [self.exporter exportVideo:video];
    }
}


#pragma mark - Video uploading


/**
 *  Start uploading all videos in the videosToUpload array
 *  Also start a timer for periodically calulating upload progress
 *  When a video is done uploading, and the SQVideoUploadDelegate is set,
 *  call the delegate method videoUploadCompleteForVideo
 *
 */
- (void) uploadVideos
{
    // Start upload progress timer
    dispatch_async(dispatch_get_main_queue(), ^{
        self.uploadProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                                    target:self
                                                                  selector:@selector(calculateUploadProgress:)
                                                                  userInfo:nil
                                                                   repeats:YES];
    });
    
    
    for (SQVideoUpload *video in self.videosToUpload) {
        
        [self.client uploadVideo:video
                   uploadSuccess:^(NSURLResponse *response) {
                       
                       NSLog(@"SynqUploader: Upload success");
                       // Handle upload success
                       
                       // Increase numVideosUploaded
                       self.numVideosUploaded = [NSNumber numberWithInt:[self.numVideosUploaded intValue] + 1];
                       
                       // Notify delegate videoUploadComplete - NB: optional delegate method
                       if (self.delegate && [self.delegate respondsToSelector:@selector(videoUploadCompleteForVideo:)]) {
                           [self.delegate videoUploadCompleteForVideo:video];
                       }
                       
                       
                       if ([self.numVideosUploaded isEqualToNumber:self.numVideosToUpload]) {
                           NSLog(@"All videos done uploading :)");
                           
                           // Invalidate timer
                           [self.uploadProgressTimer performSelectorOnMainThread:@selector(invalidate)
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
                           
                           // Call delegate allVideosUploadCompleted
                           if (self.delegate && [self.delegate respondsToSelector:@selector(allVideosUploadedSuccessfully)]) {
                               [self.delegate allVideosUploadedSuccessfully];
                           }
                       }
                       
                       // Delete temp file
                       [self.exporter deleteExportedFileForVideo:video];
                       
                   }
                     uploadError:^(NSError *error) {
                         NSLog(@"Upload error: %@", error);
                         
                         // Notify delegate videoUploadFailed - NB: optional delegate method
                         if (self.delegate && [self.delegate respondsToSelector:@selector(videoUploadFailedForVideo:)]) {
                             [self.delegate videoUploadFailedForVideo:video];
                         }
                     }];
    }
}



#pragma mark - SQAssetExporterDelegate methods

/**
 *  This delegate method is called when a video is finished exporting,
 *  and is ready for upload.
 *  Wait for all videos to be done exporting, then end the background task
 *  and start uploading.
 *
 *  @param exporter The SQAssetExporter instance that issued the call
 *  @param video    The video that is finished exporting
 */
- (void) assetExporter:(SQAssetExporter *)exporter finishedExportingVideo:(SQVideoUpload *)video
{
    NSLog(@"Finished exporting video");
    
    // Handle result, check if all videos are done exporting
    // Increase number of exported videos
    self.numVideosExported = [NSNumber numberWithInt:[self.numVideosExported intValue] + 1];
    if ([self.numVideosExported isEqualToNumber:self.numVideosToUpload]) {
        NSLog(@"All videos exported");
        
        // End background task
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        
        // Start uploading
        [self uploadVideos];
    }
    
}


#pragma mark - NSTimer method

/**
 *  Calculate total upload progress in percentage
 *
 *  @param timer The timer calling this method periodically
 */
- (void) calculateUploadProgress:(NSTimer *)timer
{
    double sumProgress = 0.0;
    for (SQVideoUpload *upload in self.videosToUpload) {
        double progress = [upload uploadProgress];
        sumProgress = progress + sumProgress;
    }
    double totalProgress = sumProgress / [self.numVideosToUpload intValue] * 100.0;
    //NSLog(@"Tot progress %f", totalProgress);
    
    // Call uploadProgress block to report progress to caller
    self.uploadProgress(totalProgress);
}

@end

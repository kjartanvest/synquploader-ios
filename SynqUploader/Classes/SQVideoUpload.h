//
//  SQVideoUpload.h
//  Pods
//
//  Created by Kjartan Vestvik on 15.11.2016.
//
//  This class represents a video object to upload
//  It must be configured with a PHAsset, the path to the exported
//  video file for the asset, and parameters used when posting to Amazon servers
//  When uploading, the parameter uploadProgress will reflect the current upload
//  progress in percentage.
//

#import <Foundation/Foundation.h>
@import Photos;


@interface SQVideoUpload : NSObject

@property (nonatomic) PHAsset *phAsset;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSDictionary *uploadParameters;
@property (nonatomic) double uploadProgress;
@property (nonatomic) BOOL exportComplete;

- (id) initWithPHAsset:(PHAsset *)asset;

@end

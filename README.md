# SynqUploader

[![Build Status](https://www.bitrise.io/app/2992b5baa9e05abe.svg?token=tykRLgOJllc9l42YkuB4LQ)](https://www.bitrise.io/app/2992b5baa9e05abe)
[![Version](https://img.shields.io/cocoapods/v/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![License](https://img.shields.io/cocoapods/l/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![Platform](https://img.shields.io/cocoapods/p/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)

SynqUploader is a simple Objective-C library that enables upload of videos to the [SYNQ Video API](https://www.synq.fm).

The library uses [AFNetworking 3](https://github.com/AFNetworking/AFNetworking) for communicating with the server. It utilizes a background configured NSURLSession to manage video uploads. This makes the upload continue regardless of whether the app is in the foreground or background.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The example app will show a collection view with thumbnails of all the videos on the device. Upload the videos of your choice by selecting them and then pressing the Upload button.

Important note: SynqUploader is dependant on a server to authorize users and to make function calls to the SYNQ Video API in order to create video objects and fetch needed upload parameters. The example project uses the SynqHttpLib library for making these calls towards an example server. The example server is a simple NodeJS server that can be configured easily on your local machine. The repo and needed instructions can be found here: https://github.com/SYNQfm/synq-node-server In addition, you will need to get an API key from the SYNQ admin panel.
In a real world scenario, this should be handled by your own backend. The backend should then give your app the upload parameters.

For more info, please read the [projects and api keys](https://docs.synq.fm/#projects-and-api-keys) section in the docs.


## Installation

SynqUploader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SynqUploader'
```

## Getting started

### Import the SynqUploader header

```objective-c
#import <SynqUploader/SynqUploader.h>
```

### Create an upload

```objective-c
// Create SQVideoUpload objects for each video to upload,
// add PHAsset for the videos
SQVideoUpload *video1 = [[SQVideoUpload alloc] initWithPHAsset:nil];
SQVideoUpload *video2 = [[SQVideoUpload alloc] initWithPHAsset:nil];

// When you have successfully created a video object through the video/create function in the SYNQ Video API,
// add the returned video_id parameter to the video
NSString *returnedVideoId1, *returnedVideoId2;
[video1 setVideoId:returnedVideoId1];
[video2 setVideoId:returnedVideoId2];

// Add upload parameters for each video, as a dictionary
// This would be the parameters returned from SYNQ API function video/upload, and must contain the following keys:
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
```

### Handle upload complete

The outcome of each upload is reported through the SQVideoUploadDelegate methods. These are the methods that are available, and how they should be used:

```objective-c
- (void) videoUploadCompleteForVideo:(SQVideoUpload *)video;
```
This method gets called when a SQVideoUpload is successfully uploaded.

```objective-c
- (void) videoUploadFailedForVideo:(SQVideoUpload *)video;
```
This method gets called when there was an error uploading a SQVideoUpload.

```objective-c
- (void) allVideosUploadedSuccessfully;
```
This method gets called when all SQVideoUpload objects were successfully uploaded.



## Requirements

This library requires iOS 8 or above

## Author

Kjartan Vestvik, kjartan@synq.fm

## License

SynqUploader is available under the MIT license. See the LICENSE file for more info.

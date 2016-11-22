# SynqUploader

[![CI Status](http://img.shields.io/travis/Kjartan/SynqUploader.svg?style=flat)](https://travis-ci.org/Kjartan/SynqUploader)
[![Version](https://img.shields.io/cocoapods/v/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![License](https://img.shields.io/cocoapods/l/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![Platform](https://img.shields.io/cocoapods/p/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)

SynqUploader is a simple Objective-C library that enables upload of videos to the [SYNQ platform](https://www.synq.fm).

The library uses [AFNetworking 3](https://github.com/AFNetworking/AFNetworking) for communicating with the server. It utilizes a background configured NSURLSession to manage video uploads. This makes the upload continue regardless of whether the app is in the foreground or background.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The example app will show a collection view with thumbnails of all the videos on the device. Clicking on a thumbnail will call the upload function and upload the video. 

Important note: The example project is dependant on access to the SYNQ API to be able to create a video object and to fetch the upload parameters needed when calling the upload function. You will need to get an API key from the SYNQ admin panel, and insert the key into the SynqAPI class. **Caution: this is not the proper way of doing this, and your api key might get exposed to others!** 
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
[[SynqLib sharedInstance] uploadVideoArray:assetsArray
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

Kjartan, kjartan@synq.fm

## License

SynqLib is available under the MIT license. See the LICENSE file for more info.

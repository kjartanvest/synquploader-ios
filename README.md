# SynqUploader

[![CI Status](http://img.shields.io/travis/Kjartan/SynqUploader.svg?style=flat)](https://travis-ci.org/Kjartan/SynqUploader)
[![Version](https://img.shields.io/cocoapods/v/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![License](https://img.shields.io/cocoapods/l/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)
[![Platform](https://img.shields.io/cocoapods/p/SynqUploader.svg?style=flat)](http://cocoapods.org/pods/SynqUploader)

SynqLib is a simple Objective-C library that enables upload of videos to the [SYNQ platform](https://www.synq.fm).

The library uses [AFNetworking 3](https://github.com/AFNetworking/AFNetworking) for communicating with the server. It utilizes a background configured NSURLSession to manage video uploads. This makes the upload continue regardless of whether the app is in the foreground or background.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SynqLib is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SynqLib"
```

## Getting started

### Import the SynqLib header

```objective-c
#import <SynqLib/SynqLib.h>
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
```

## Requirements

This library requires iOS 8 or above

## Author

Kjartan, kjartan@synq.fm

## License

SynqLib is available under the MIT license. See the LICENSE file for more info.

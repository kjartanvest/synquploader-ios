//
//  SynqUploader_ExampleUITests.m
//  SynqUploader_ExampleUITests
//
//  Created by Kjartan Vestvik on 30.01.2017.
//  Copyright © 2017 Kjartan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQVideoHandler.h"
//#import <SynqUploader/SQVideoUpload.h>


@interface SynqUploader_ExampleUITests : XCTestCase

@property BOOL videoCopied;

@end

@implementation SynqUploader_ExampleUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    id systemAlertMonitor = [self addUIInterruptionMonitorWithDescription:@"Photos dialog" handler:^BOOL(XCUIElement * _Nonnull interruptingElement)
    {
        
        if (interruptingElement.staticTexts[@"<Alert text example>"].exists &&
            interruptingElement.buttons[@"OK"].exists)
        {
            //Dismiss the alert (e.g., by calling -click on the target button of interruptingElement)
            
            [interruptingElement.buttons[@"OK"] tap];
            
            //Return YES if you handled the alert
            return YES;
        }
        
        //... or NO otherwise
        return NO;
    }];
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
}


// Copy a sample video to the camera roll of the device (or the simulator)
// This should only be run once!
- (void)testCopySampleVideo
{
    
    
    
    /*
    XCTestExpectation *expectation = [self expectationWithDescription:@"Video copy timed out."];
    
    [[SQVideoHandler sharedInstance] testCopySampleVideoToLibraryWithCompletion:^(NSError *error){
        
        XCTAssertNil(error, "Error when copying sample video");
        [expectation fulfill];
    }];
                     
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
    }];
    */
    
    NSString *aTest = @"Text";
    XCTAssertNotNil(aTest, @"Text should not be nil");
    
}



@end

//
//  SQViewController.h
//  SynqUploader
//
//  Created by Kjartan on 11/15/2016.
//  Copyright (c) 2016 Kjartan. All rights reserved.
//

@import UIKit;

@interface SQViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
    
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)uploadButtonPushed:(id)sender;

    
@end

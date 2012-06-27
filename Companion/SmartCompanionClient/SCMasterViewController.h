//
//  SCMasterViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCMasterViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *selectedImage;
}

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *loadImageButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *translateButton;

#pragma mark - Action Handlers
- (IBAction)handleLoadImageButton:(id)sender;
- (IBAction)handleSnapshotButton:(id)sender;

@end

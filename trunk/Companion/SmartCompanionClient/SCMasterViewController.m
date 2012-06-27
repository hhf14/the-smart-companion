//
//  SCMasterViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCMasterViewController.h"
#import "SCEditViewController.h"

@interface SCMasterViewController ()

@end

@implementation SCMasterViewController
@synthesize snapshotButton;
@synthesize loadImageButton;
@synthesize historyButton;
@synthesize translateButton;

#pragma mark -
#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backImage = [[UIImage imageNamed:@"BlackButtonStretchable44ptHigh@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [snapshotButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [loadImageButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [translateButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [historyButton setBackgroundImage:backImage forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [self setSnapshotButton:nil];
    [self setLoadImageButton:nil];
    [self setHistoryButton:nil];
    [self setTranslateButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Handlers

- (IBAction)handleLoadImageButton:(id)sender 
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imgPicker animated:YES completion:nil];
    } else {
        // Not supported
    }
}

- (IBAction)handleSnapshotButton:(id)sender 
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Simulator doesn't support camera!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditSegue"]) {
        SCEditViewController *editVC = (SCEditViewController *)segue.destinationViewController;
        [editVC setImage:selectedImage];
    }
}

#pragma mark - ImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissModalViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"EditSegue" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

@end

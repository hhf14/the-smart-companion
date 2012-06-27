//
//  SCPublishPhotoViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import <MapKit/MKFoundation.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "Facebook.h"
#import "SCAppDelegate.h"
#import "SCGraphics.h"

@interface SCPublishPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, MKMapViewDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {
    
    BOOL getAvatarPending;
    BOOL pulishPhotoPending;
    BOOL photoPublishing;
}


@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *photoContent;
@property (strong, nonatomic) UIAlertView *waitingAlert;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

- (IBAction)handleRightBarButton:(id)sender;

@end

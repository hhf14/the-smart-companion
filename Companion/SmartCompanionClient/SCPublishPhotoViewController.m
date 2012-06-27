//
//  SCPublishPhotoViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kFBAppID @"138904049580234"
#define kFBAppSecret @"b349ceeb49142dc4e6d13734bd7d7238"

#import "SCPublishPhotoViewController.h"

@interface SCPublishPhotoViewController ()

- (void)loadAvatarForUser:(NSString *)accessToken;
- (void)avatarDidLoad:(UIImage *)avatar;
- (void)showMapView:(BOOL)isShown;
- (void)publishToFacebook;

@end

@implementation SCPublishPhotoViewController
@synthesize image;
@synthesize photoContent;
@synthesize waitingAlert;
@synthesize avatarImageView;
@synthesize commentTextView;
@synthesize locationTextField;
@synthesize photoImageView;
@synthesize mapView;
@synthesize coverView;
@synthesize rightBarButton;

#pragma mark - Instance methods

- (void)loadAvatarForUser:(NSString *)accessToken
{
    // Get user's facebook avatar        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?access_token=%@", accessToken]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *profilePic = [[UIImage alloc] initWithData:data];
    
    [self performSelectorOnMainThread:@selector(avatarDidLoad:) withObject:profilePic waitUntilDone:NO];
}

- (void)avatarDidLoad:(UIImage *)avatar
{
    if (avatar) {
        [self.avatarImageView setImage:avatar];
    }    
}

- (void)showMapView:(BOOL)isShown
{
    [UIView animateWithDuration:0.5 
                     animations:^(void) 
     {
         if (isShown) {
             self.coverView.frame = CGRectMake(self.coverView.frame.origin.x, 
                                               self.coverView.frame.origin.y, 
                                               self.coverView.frame.size.width, 
                                               416);
             self.photoImageView.frame = CGRectMake(self.photoImageView.frame.origin.x, 
                                                    429, 
                                                    self.photoImageView.frame.size.width, 
                                                    self.photoImageView.frame.size.height);
             self.mapView.frame = CGRectMake(self.mapView.frame.origin.x, 
                                             self.mapView.frame.origin.y, 
                                             self.mapView.frame.size.width, 
                                             204);
             
             
         } else {
             self.coverView.frame = CGRectMake(self.coverView.frame.origin.x, 
                                               self.coverView.frame.origin.y, 
                                               self.coverView.frame.size.width, 
                                               193);
             self.photoImageView.frame = CGRectMake(self.photoImageView.frame.origin.x, 
                                                    206, 
                                                    self.photoImageView.frame.size.width, 
                                                    self.photoImageView.frame.size.height);
             self.mapView.frame = CGRectMake(self.mapView.frame.origin.x, 
                                             self.mapView.frame.origin.y, 
                                             self.mapView.frame.size.width, 
                                             0);
         }     
     } completion:^(BOOL finished) {
         (void)finished;
     }
     ];
    
    CGSize contentSize = CGSizeMake(self.photoImageView.frame.size.width, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + 30);
    [(UIScrollView *)self.view setContentSize:contentSize];
    
    if (isShown) {
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 140) animated:YES];
    } else {
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0) animated:YES];        
    }
}

- (void)publishToFacebook
{
    // Show waiting alert
    waitingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PublishPhoto", nil) message:NSLocalizedString(@"PublishPhotoMsg", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicator.center = CGPointMake(142, 130);
    [waitingAlert addSubview:loadingIndicator];
    [waitingAlert show];
    [loadingIndicator startAnimating];  
    
    photoPublishing = TRUE;
    
    Facebook *facebook = ((SCAppDelegate *)[UIApplication sharedApplication].delegate).facebook;
    
    NSMutableString *messageContent = [NSMutableString stringWithString:self.commentTextView.text];
    if ([self.locationTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [messageContent appendFormat:@" - at %@.", self.locationTextField.text];
    }
    
    UIImage *normalizedImage = [SCGraphics normalizeImage:self.image];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   normalizedImage, @"picture", 
                                   (NSString *)messageContent, @"message",
                                   nil];
    [facebook requestWithGraphPath:@"me/photos"
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:self];
}

#pragma mark - View Lifecycle

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
	// Do any additional setup after loading the view.
    
    [self.photoImageView setImage:self.image];
    if ([self.photoContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [self.commentTextView setText:[NSString stringWithFormat:@"\n\n\"%@\"", self.photoContent]];
    }
    
    [self showMapView:FALSE];
    
    // Facebook region - START
    SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.facebook) {
        appDelegate.facebook = [[Facebook alloc] initWithAppId:kFBAppID andDelegate:self];        
    } else {
        appDelegate.facebook.sessionDelegate = self;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        appDelegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        appDelegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (appDelegate.facebook.isSessionValid) {
        if (appDelegate.facebook.shouldExtendAccessToken) {
            getAvatarPending = TRUE;
            [appDelegate.facebook extendAccessToken];
        } else {
            // Get user's facebook avatar
            [NSThread detachNewThreadSelector:@selector(loadAvatarForUser:) toTarget:self withObject:appDelegate.facebook.accessToken];
        }
    }
    // Facebook region - END
}

- (void)viewDidUnload
{
    [self setAvatarImageView:nil];
    [self setCommentTextView:nil];
    [self setLocationTextField:nil];
    [self setPhotoImageView:nil];
    [self setMapView:nil];
    [self setCoverView:nil];
    [self setRightBarButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showMapView:TRUE];
    [self setTitle:@"Select Location"];
    [self.rightBarButton setTitle:@"Select"];
    
    if (textField.text.length == 0 && self.mapView.userLocation) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {            
            if (!error){
                if(placemarks && placemarks.count > 0)
                {
                    //do something
                    CLPlacemark *topResult = [placemarks objectAtIndex:0];
                    
                    NSString *addressTxt = [NSString stringWithFormat:@"%@ %@, %@", 
                                            [topResult locality], [topResult administrativeArea], [topResult country]];
                    [textField setText:addressTxt];
                }
            }
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self showMapView:FALSE];
    [self setTitle:@"Publish Photo"];
    [self.rightBarButton setTitle:@"Post"];
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setTitle:@"Comment"];
    [self.rightBarButton setTitle:@"Done"];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self setTitle:@"Publish Photo"];
    [self.rightBarButton setTitle:@"Post"];
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}

#pragma mark - Anction handlers

- (IBAction)handleRightBarButton:(id)sender {
    if ([[self.rightBarButton title] isEqualToString:@"Select"]) {
        [self.locationTextField resignFirstResponder];
    } else if ([[self.rightBarButton title] isEqualToString:@"Done"]) {
        [self.commentTextView resignFirstResponder];
    } else {
        // Facebook setup region - START            
        SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
        if (![appDelegate.facebook isSessionValid]) {
            pulishPhotoPending = TRUE;
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"publish_stream", 
                                    nil];
            [appDelegate.facebook authorize:permissions];
        } else {
            [self publishToFacebook];
        }
        // Facebook setup region - END
    }
}

#pragma mark - FBSessionDelegate methods

/**
 * Your application should implement this delegate to receive session callbacks.
 */
- (void)fbDidLogin {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Facebook *facebook = ((SCAppDelegate *)[UIApplication sharedApplication].delegate).facebook;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // Get user's facebook avatar if needed
    [NSThread detachNewThreadSelector:@selector(loadAvatarForUser:) toTarget:self withObject:facebook.accessToken];
    
    if (pulishPhotoPending) {
        pulishPhotoPending = FALSE;
        [self publishToFacebook];
    }
}

/**
 * Your application should implement this delegate to receive session callbacks.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if (getAvatarPending) {
        getAvatarPending = FALSE;
        [NSThread detachNewThreadSelector:@selector(loadAvatarForUser:) toTarget:self withObject:accessToken];
    }
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - FBDialogDelegate methods

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - FBRequestDelegate methods

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), request.url);
}

/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@", NSStringFromSelector(_cmd));   
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    if (photoPublishing) {
        photoPublishing = FALSE;
        [waitingAlert dismissWithClickedButtonIndex:0 animated:NO];
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
                                                             message:error.localizedDescription 
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                                   otherButtonTitles:nil, nil];
        [errorAlert show];
    }
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"%@", NSStringFromSelector(_cmd));   
    if (photoPublishing) {
        photoPublishing = FALSE;
        [waitingAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@%@", NSStringFromSelector(_cmd), response);    
}

@end

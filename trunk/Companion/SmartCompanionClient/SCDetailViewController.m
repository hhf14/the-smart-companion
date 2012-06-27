//
//  SCDetailViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCDetailViewController.h"
#import "SCMicrosoftTranslator.h"
#import "SCServerCommunication.h"
#import "SCAppDelegate.h"
#import "SCGraphics.h"
#import "SCPublishPhotoViewController.h"
#import <Twitter/Twitter.h>

#define kSCFromLang 0
#define kSCToLang 1

#define kSCImageViewNormalFrame CGRectMake(20, 20, 118, 118)

@interface SCDetailViewController ()

- (void)resizeImageView;
- (void)tweetPhoto;

@end

@implementation SCDetailViewController
@synthesize viewBeingDisapeared;
@synthesize image;
@synthesize waitingAlert;
@synthesize noteTextView;
@synthesize doneButton;
@synthesize imageView;
@synthesize fromButton;
@synthesize toButton;
@synthesize switchButton;
@synthesize fromTextView;
@synthesize toTextView;
@synthesize translateButton;
@synthesize translateLoadingIndicator;
@synthesize facebookButton;

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewBeingDisapeared = TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *masterView = (UIScrollView *)self.view;
    [masterView setFrame:CGRectMake(masterView.frame.origin.x, 
                                    masterView.frame.origin.y + 44, 
                                    masterView.frame.size.width, 
                                    masterView.frame.size.height - 44)];
    [masterView setContentSize:CGSizeMake(masterView.frame.size.width, masterView.frame.size.height)];
    masterView.delegate = self;
        
	// Do any additional setup after loading the view.
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"MSLang.plist"];
    languageCode = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    languageList = [NSArray arrayWithArray:[languageCode allKeys]];
    languageList = [languageList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
    // Setup Gesture Recognizers for the ImageView
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    [self.imageView addGestureRecognizer:pinchGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapRecognizer:)];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
    
    // Start extracting text from image
    if (self.image) {
        [self.imageView setImage:self.image];
        
        // Show waiting alert
        waitingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PleaseWaitMsg", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingIndicator.center = CGPointMake(142, 66.5);
        [waitingAlert addSubview:loadingIndicator];
        [waitingAlert show];
        [loadingIndicator startAnimating];
        
        // Start detect module
        NSDictionary *paramsObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.image, @"Image",
                                   @"Tesseract", @"Module", 
                                   @"eng", @"LangCode", nil];
        [NSThread detachNewThreadSelector:@selector(startExtractJob:) toTarget:self withObject:paramsObj];
    }
}

- (void)viewDidUnload
{
    // Facebook region - START
    SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.facebook) {
        appDelegate.facebook.sessionDelegate = nil;
    }
    
    [self setFromButton:nil];
    [self setToButton:nil];
    [self setFromTextView:nil];
    [self setToTextView:nil];
    [self setTranslateButton:nil];
    [self setImageView:nil];
    [self setImage:nil];
    [self setWaitingAlert:nil];
    [self setDoneButton:nil];
    [self setNoteTextView:nil];
    [self setSwitchButton:nil];
    [self setTranslateLoadingIndicator:nil];
    [self setFacebookButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"ChooseLanguage"]) {
        SCLanguageViewController *langScreen = (SCLanguageViewController *)segue.destinationViewController;
        langScreen.delegate = self;
        langScreen.view.tag = sender == self.fromButton ? kSCFromLang : kSCToLang;
    } else if ([segue.identifier isEqualToString:@"PublishPhoto"]) {
        SCPublishPhotoViewController *publishScreen = (SCPublishPhotoViewController *)segue.destinationViewController;
        [publishScreen setImage:self.image];
        [publishScreen setPhotoContent:self.toTextView.text];
    }
}

#pragma mark - Instance Methods
- (void)startExtractJob:(id)object
{
#if FALSE
    NSDictionary *dic = (NSDictionary *)object;
    NSError *error = nil;
    NSString *detectedText = [SCServerCommunication detectWithImage:[dic valueForKey:@"Image"] 
                                                             module:[dic valueForKey:@"Module"] 
                                                               lang:[dic valueForKey:@"LangCode"] 
                                                              error:&error];
#else
    NSError *error = nil;
    NSString *detectedText = nil;
#endif
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mDic setValue:error forKey:@"Error"];
    [mDic setValue:detectedText forKey:@"DetectedText"];
    
    [self performSelectorOnMainThread:@selector(extractJobDidFinish:) withObject:mDic waitUntilDone:NO];
}

- (void)extractJobDidFinish:(id)object
{
    if (waitingAlert) {
        [waitingAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    NSMutableDictionary *dic = (NSMutableDictionary *)object;
    NSError *error = [dic valueForKey:@"Error"];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
                                                        message:[error localizedDescription] 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self.fromTextView setText:@""];
    } else {
        NSString *detectedText = [dic valueForKey:@"DetectedText"];
        if (detectedText) {
            [self.fromTextView setText:detectedText];
            self.translateButton.enabled = TRUE;
        }
    }
}

- (void)startTranslationJob:(id)object 
{
    NSDictionary *dic = (NSDictionary *)object;
    NSError *error = nil;
    NSString *translatedText = [SCMicrosoftTranslator translateWithText:[dic valueForKey:@"Text"] 
                                                          inputLanguage:[dic valueForKey:@"From"] 
                                                         outputLanguage:[dic valueForKey:@"To"]
                                                                  error:&error];
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mDic setValue:error forKey:@"Error"];
    [mDic setValue:translatedText forKey:@"TranslatedText"];
    
    [self performSelectorOnMainThread:@selector(translationJobDidFinished:) withObject:mDic waitUntilDone:NO];
}

- (void)translationJobDidFinished:(id)object
{
    NSMutableDictionary *dic = (NSMutableDictionary *)object;
    NSError *error = [dic valueForKey:@"Error"];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
                                                        message:[error localizedDescription] 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self.toTextView setText:@""];
    } else {
        NSString *translatedText = [dic valueForKey:@"TranslatedText"];
        [self.toTextView setText:translatedText];
    }
    
    [self.translateButton setEnabled:YES];
    [self.translateLoadingIndicator stopAnimating];
}

- (void)resizeImageView
{
    CGRect newFrame = CGRectZero;
    if (CGRectEqualToRect(self.imageView.frame, kSCImageViewNormalFrame))
    {
        newFrame = CGRectMake(0, 0, 320, 372);
    }
    else
    {
        newFrame = kSCImageViewNormalFrame;
    }
    
    [UIView animateWithDuration:0.5 
                     animations:^(void) 
     {
         self.imageView.frame = newFrame;
     } 
                     completion:^(BOOL finished) 
     {
         (void)finished;
     }
     ];
}

- (void)tweetPhoto
{
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    if ([self.toTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [twitter setInitialText:[NSString stringWithFormat:@"\n\n\"%@\"", self.toTextView.text]];//optional
    }
    [twitter addImage:self.image];

    if([TWTweetComposeViewController canSendTweet]){
        [self presentViewController:twitter animated:YES completion:nil]; 
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TweetError", nil)
                                                            message:NSLocalizedString(@"TweetErrorMsg", nil)
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        if (res == TWTweetComposeViewControllerResultDone) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tweeted", nil)
                                                                message:NSLocalizedString(@"TweetedMsg", nil)
                                                               delegate:self 
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        } else if (res == TWTweetComposeViewControllerResultCancelled) {
            /*
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ooops..."
                                                                message:@"Something went wrong, try again later"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
             */
        }
        [self dismissModalViewControllerAnimated:YES];
    };
}

#pragma mark - Action Handlers
- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)sender {
    // Pinch for displayImageView
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (sender.velocity >= 0.0f)
        {   // expanding pinch
            if (CGRectEqualToRect(self.imageView.frame, kSCImageViewNormalFrame))
            {
                [self resizeImageView];
            }
        }
        else
        {   // contracting pinch
            if (!CGRectEqualToRect(self.imageView.frame, kSCImageViewNormalFrame))
            {
                [self resizeImageView];
            }
        }
    }
}

- (void)handleSingleTapRecognizer:(id)sender {
    [self resizeImageView];
}

- (IBAction)handleDoneButton:(id)sender {
    if (self.fromTextView.isFirstResponder) {
        [self.fromTextView resignFirstResponder];
    } else if (self.toTextView.isFirstResponder) {
        [self.toTextView resignFirstResponder];
    } else if (self.noteTextView.isFirstResponder) {
        [self.noteTextView resignFirstResponder];
    }
    
//    [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)handleTranslateButton:(id)sender {
    
    [self.translateButton setEnabled:FALSE];
    [self.translateLoadingIndicator setHidden:NO];
    [self.translateLoadingIndicator startAnimating];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.fromTextView.text, @"Text", 
                         [languageCode valueForKey:self.fromButton.titleLabel.text], @"From",
                         [languageCode valueForKey:self.toButton.titleLabel.text], @"To", nil];
        
    [NSThread detachNewThreadSelector:@selector(startTranslationJob:) toTarget:self withObject:dic];    
}

- (IBAction)handleFromButton:(id)sender {
    // Disables keyboard if needed
    if (self.doneButton.enabled) {
        [self handleDoneButton:self.doneButton];
    }
}

- (IBAction)handleToButton:(id)sender {
    // Disables keyboard if needed
    if (self.doneButton.enabled) {
        [self handleDoneButton:self.doneButton];
    }
}

- (IBAction)handleSwitchButton:(id)sender {
    NSString *tempString = fromButton.titleLabel.text;
    [fromButton setTitle:toButton.titleLabel.text forState:UIControlStateNormal];
    [toButton setTitle:tempString forState:UIControlStateNormal];
}

- (IBAction)handleFacebookButton:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"PublishThePhoto", nil), NSLocalizedString(@"TweetThePhoto", nil), nil];
    [actionSheet setTag:113];
    [actionSheet showFromBarButtonItem:self.facebookButton animated:YES];

}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.doneButton setEnabled:YES];
    
    if (textView == self.fromTextView) {
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 70) animated:YES];
    } else if (textView == self.toTextView) {
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 162) animated:YES];
    } 
    
    if (textView == self.noteTextView) {
        UIFont *standardFont = [UIFont systemFontOfSize:14];
        if (![textView.font.description isEqual:standardFont.description]) {
            textView.textColor = [UIColor blackColor];
            textView.font = standardFont;
            textView.text = @"";
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!self.viewBeingDisapeared) {
        [self.doneButton setEnabled:NO];
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    if (textView == self.noteTextView) {
        if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            textView.textColor = [UIColor lightGrayColor];
            textView.font = [UIFont italicSystemFontOfSize:14];
            textView.text = NSLocalizedString(@"CommentPlaceholderStr", nil);
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.fromTextView == textView) {
        // enable the translate button only when the fromTextView contains a text string
        NSString *currentText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.translateButton.enabled = [currentText length] > 0;
    }
}

#pragma mark - SCLanguageViewController Methods

- (void)languageViewController:(SCLanguageViewController *)controller didChooseLanguage:(NSString *)language {
    if (controller.view.tag == kSCFromLang) {
        [fromButton setTitle:language forState:UIControlStateNormal];
    } else {
        [toButton setTitle:language forState:UIControlStateNormal];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 113) {
        if (buttonIndex == 0) { // Publish the Photo
            [self performSegueWithIdentifier:@"PublishPhoto" sender:self];
        } else if (buttonIndex == 1) { // Publish the Photo
            [self tweetPhoto];
        } else { // Close
        }
    }
}

@end

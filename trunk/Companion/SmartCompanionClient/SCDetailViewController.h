//
//  SCDetailViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLanguageViewController.h"
#import "Facebook.h"

@interface SCDetailViewController : UIViewController <UIScrollViewDelegate, SCLanguageViewDelegate, UIActionSheetDelegate>
{
    NSArray *languageList;
    NSInteger selectedFromLanguageIndex;
    NSInteger selectedToLanguageIndex;
    NSDictionary *languageCode;
        
    UIImage *image;    
}

@property (nonatomic) BOOL viewBeingDisapeared;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIAlertView *waitingAlert;

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;
@property (weak, nonatomic) IBOutlet UITextView *toTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *translateButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *translateLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *facebookButton;

- (IBAction)handleDoneButton:(id)sender;
- (IBAction)handleTranslateButton:(id)sender;
- (IBAction)handleFromButton:(id)sender;
- (IBAction)handleToButton:(id)sender;
- (IBAction)handleSwitchButton:(id)sender;
- (IBAction)handleFacebookButton:(id)sender;

@end

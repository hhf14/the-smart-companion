//
//  SCTranslateViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCMicrosoftTranslator.h"
#import "SCLanguageViewController.h"

@interface SCTranslateViewController : UIViewController <SCLanguageViewDelegate>
{
    NSArray *languageList;
    NSInteger selectedFromLanguageIndex;
    NSInteger selectedToLanguageIndex;
    NSDictionary *languageCode;    
}

@property (nonatomic) BOOL viewBeingDisapeared;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;
@property (weak, nonatomic) IBOutlet UITextView *toTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *translateButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *translatorWaitingIndicator;

- (IBAction)handleDoneButton:(id)sender;
- (IBAction)handleToButton:(id)sender;
- (IBAction)handleFromButton:(id)sender;
- (IBAction)handleSwitchButton:(id)sender;
- (IBAction)handleTranslateButton: (id)sender;

@end

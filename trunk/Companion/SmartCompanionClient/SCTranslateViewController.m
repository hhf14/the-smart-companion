//
//  SCTranslateViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCTranslateViewController.h"

#define kSCFromLang 0
#define kSCToLang 1

@interface SCTranslateViewController ()

@end

@implementation SCTranslateViewController
@synthesize viewBeingDisapeared;
@synthesize doneButton;
@synthesize toButton;
@synthesize fromButton;
@synthesize switchButton;
@synthesize fromTextView;
@synthesize translateButton;
@synthesize toTextView;
@synthesize translatorWaitingIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *masterView = (UIScrollView *)self.view;
    [masterView setFrame:CGRectMake(masterView.frame.origin.x, 
                                    masterView.frame.origin.y + 44, 
                                    masterView.frame.size.width, 
                                    masterView.frame.size.height - 44)];
    [masterView setContentSize:CGSizeMake(masterView.frame.size.width, masterView.frame.size.height + 1)];
    
	// Do any additional setup after loading the view.
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"MSLang.plist"];
    languageCode = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    languageList = [NSArray arrayWithArray:[languageCode allKeys]];
    languageList = [languageList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)viewDidUnload
{
    [self setToButton:nil];
    [self setFromButton:nil];
    [self setFromTextView:nil];
    [self setToTextView:nil];
    [self setTranslateButton:nil];
    [self setTranslatorWaitingIndicator:nil];
    [self setDoneButton:nil];
    [self setTranslateButton:nil];
    [self setSwitchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewBeingDisapeared = TRUE;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Instance Methods

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
    
    [self performSelectorOnMainThread:@selector(translationJobDidFinish:) withObject:mDic waitUntilDone:YES];
}

- (void)translationJobDidFinish:(id)object
{
    NSMutableDictionary *mDic = (NSMutableDictionary *)object;
    NSError *error = [mDic valueForKey:@"Error"];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:[error localizedDescription] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self.toTextView setText:@""];
    } else {
        NSString *translatedText = (NSString *)[mDic valueForKey:@"TranslatedText"];
        [self.toTextView setText:translatedText];
    }
    
    [self.translateButton setEnabled:YES];
    [self.translatorWaitingIndicator stopAnimating];
}

#pragma mark - Action Handlers

- (IBAction)handleDoneButton:(id)sender {
    if (self.fromTextView.isFirstResponder) {
        [self.fromTextView resignFirstResponder];
    } else if (self.toTextView.isFirstResponder) {
        [self.toTextView resignFirstResponder];
    }
}

- (IBAction)handleToButton:(id)sender {   
    
    // Disables keyboard if needed
    if (self.doneButton.enabled) {
        [self handleDoneButton:self.doneButton];
    }
}

- (IBAction)handleFromButton:(id)sender {
    
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

- (IBAction)handleTranslateButton: (id)sender{
    
    [self.translateButton setEnabled:FALSE];
    [self.translatorWaitingIndicator setHidden:NO];
    [self.translatorWaitingIndicator startAnimating];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.fromTextView.text, @"Text", 
                         [languageCode valueForKey:self.fromButton.titleLabel.text], @"From",
                         [languageCode valueForKey:self.toButton.titleLabel.text], @"To", nil];
        
    [NSThread detachNewThreadSelector:@selector(startTranslationJob:) toTarget:self withObject:dic];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"ChooseLanguage"]) {
        SCLanguageViewController *langScreen = (SCLanguageViewController *)segue.destinationViewController;
        langScreen.delegate = self;
        langScreen.view.tag = sender == self.fromButton ? kSCFromLang : kSCToLang;
    }
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.doneButton setEnabled:YES];
    if (textView == self.fromTextView) {
        //[(UIScrollView *)self.view setContentOffset:CGPointMake(0, 60) animated:YES];
    } else if (textView == self.toTextView) {
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 165) animated:YES];
    } 
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!self.viewBeingDisapeared) {
        [self.doneButton setEnabled:NO];
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0) animated:YES];
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

@end

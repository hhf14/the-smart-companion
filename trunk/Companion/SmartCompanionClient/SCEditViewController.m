//
//  SCEditViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCEditViewController.h"
#import "SCDetailViewController.h"
#import "SCGraphics.h"

@interface SCEditViewController ()

- (void)hideControlBars:(BOOL)hidden;
- (void)updateHistoryButtonState;
- (void)updateHistoryData:(SCHistoryStep *)aStep;

@end

@implementation SCHistoryStep
@synthesize actionType, image;

@end

@implementation SCEditViewController
@synthesize cropButton;
@synthesize undoButton;
@synthesize redoButton;
@synthesize actionButton;
@synthesize drawButton;
@synthesize infoButton;
@synthesize scrollView;
@synthesize toolbar;
@synthesize imageView, image;
@synthesize historyData, historyStep;

#pragma mark - Action handlers

-(IBAction)handleRightBarButton:(id)sender{
    if (actionType == kSCDefault) {
        [self performSegueWithIdentifier:@"EditToDetails" sender:self];
    }
    else if(actionType==kSCCropping){
        //get scale factor of real image size to image in image view
        float scaleFactor = [self getScaleFactorOfImage:imageView.image inImageView:imageView];
        
        //Origin of scaled image in image view
        CGPoint imageOrigin = CGPointMake(CGRectGetMidX(drawView.frame)-imageView.image.size.width/(2*scaleFactor),
                                          CGRectGetMidY(drawView.frame)-imageView.image.size.height/(2*scaleFactor));
        
        //Real crop rectangle
        CGRect cropRect = CGRectMake((drawView.cropRect.origin.x-imageOrigin.x)*scaleFactor, 
                                     (drawView.cropRect.origin.y-imageOrigin.y)*scaleFactor, 
                                     drawView.cropRect.size.width*scaleFactor, 
                                     drawView.cropRect.size.height*scaleFactor);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([imageView.image CGImage], cropRect);
        UIImage *cropImage = [UIImage imageWithCGImage:imageRef];        
        [imageView setImage:cropImage];
        
        [[self.view.subviews lastObject] removeFromSuperview];
        drawView = nil;
        [self.imageView setNeedsDisplay];
        
        //Set right bar button to default
        actionType = kSCDefault;
        [self.navigationItem.rightBarButtonItem setTitle:@"Send"];
        
        // Update history data
        SCHistoryStep *aStep = [[SCHistoryStep alloc] init];
        aStep.actionType = kSCRotating;
        aStep.image = cropImage;
        [self updateHistoryData:aStep];
    }else if(actionType == kSCDrawing){
        [[self.view.subviews lastObject] removeFromSuperview];
        drawView = nil;
        [self.imageView setNeedsDisplay];
    }
}

- (void)handleRotateGesture:(UIRotationGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    //    [self hideControlBars:!self.navigationController.navigationBarHidden];
    //NSLog(@"origin: %f; %f",self.imageView.frame.origin.x,self.imageView.frame.origin.y);
    //NSLog(@"size: %f; %f",self.imageView.frame.size.width,self.imageView.frame.size.height);    
}

- (void)handleTribleTap:(UITapGestureRecognizer *)sender
{
    // Binarize the image
    UIImage *binaryImage = [SCGraphics binarizeImageUsingOtsuMethod:self.imageView.image];
    [self.imageView setImage:binaryImage];
    
    // Update history data
    SCHistoryStep *aStep = [[SCHistoryStep alloc] init];
    aStep.actionType = kSCBinarizing;
    aStep.image = binaryImage;
    [self updateHistoryData:aStep];
}


- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
#if FALSE
    // Binarize the image
    UIImage *binaryImage = [SCGraphics binarizeImageUsingLocalAdaptiveThresholding:self.imageView.image];
    [self.imageView setImage:binaryImage];
    
    // Update history data
    SCHistoryStep *aStep = [[SCHistoryStep alloc] init];
    aStep.actionType = kSCBinarizing;
    aStep.image = binaryImage;
    [self updateHistoryData:aStep];
#else
//    NSMutableArray *blobList = [SCGraphics detectBlobsWithImage:self.image];
//    for (SCBlob *blob in blobList) {
//        NSLog(@"%@", [blob toString]);
//    }
    UIImage *binarizedImg = [SCGraphics binarizeImageUsingOtsuMethod:self.imageView.image];
    UIImage *classifiedImg = [SCGraphics removeNoisesForBinaryImage:binarizedImg];
    [self.imageView setImage:classifiedImg];
#endif
}

- (IBAction)handleCropButton:(id)sender {
    actionType = kSCCropping;
    if (drawView==nil) {        
        drawView = [[SCDrawView alloc]initWithFrame:(self.imageView.frame)];
        //set action identify as Cropping
        drawView.SCActionIdentify = 0;
        float scaleFactor = [self getScaleFactorOfImage:imageView.image inImageView:imageView];        
        float imageOriginX = CGRectGetMidX(imageView.frame)-imageView.image.size.width/(2*scaleFactor);
        float imageOriginY = CGRectGetMidY(imageView.frame)-imageView.image.size.height/(2*scaleFactor);
        CGRect bounds = CGRectMake(imageOriginX, imageOriginY, imageView.image.size.width/scaleFactor, imageView.image.size.height/scaleFactor);       
        
        //phai round up imageBounds & crop rect
        drawView.imageBounds = bounds;
        drawView.cropRect = CGRectMake(bounds.origin.x+30, bounds.origin.y+30, bounds.size.width-60, bounds.size.height-60);  
        //drawView.cropRect = CGRectMake(110,130, 100, 100); 
        [self.navigationItem.rightBarButtonItem setTitle:@"Crop"];
        [self.view addSubview: drawView];
    }    
}

- (IBAction)handleDrawButton:(id)sender {
    actionType = kSCDrawing;
    if (drawView==nil) {        
        drawView = [[SCDrawView alloc]initWithFrame:(self.imageView.frame)];
       
        //set action identify as Drawing
        drawView.SCActionIdentify = 1;
        [self.navigationItem.rightBarButtonItem setTitle:@"Apply"];
        [self.view addSubview: drawView];
    }    
}

- (IBAction)handleInfoButton:(id)sender {
    [self performSegueWithIdentifier:@"ImageInfo" sender:self];
}


- (IBAction)handleUndoButton:(id)sender {
    self.historyStep -= 1;
    SCHistoryStep *aStep = [self.historyData objectAtIndex:self.historyStep];
    if (aStep) {
        [self.imageView setImage:aStep.image];
    }
    
    [self updateHistoryButtonState];
}

- (IBAction)handleRedoButton:(id)sender {
    self.historyStep += 1;
    SCHistoryStep *aStep = [self.historyData objectAtIndex:self.historyStep];
    if (aStep) {
        [self.imageView setImage:aStep.image];
    }
    
    [self updateHistoryButtonState];
}

- (IBAction)handleActionButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:@"Save to Photos", nil];
    [actionSheet setTag:113];
    [actionSheet showFromBarButtonItem:self.actionButton animated:YES];
}

#pragma mark - Instance methods

//Rotate image base on EXIF value
- (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient
{
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGAffineTransform   transform = CGAffineTransformIdentity;
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
    CGFloat             boundHeight;
    
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

//Bounds of image in image view
- (CGRect)getBoundsOfimage:(UIImage*)anImage inImageView:(UIImageView*)anImageView{
    float scaleFactor = [self getScaleFactorOfImage:anImage inImageView:anImageView];
    
    //Origin of scaled image in image view
    float imageOriginX = CGRectGetMidX(anImageView.frame)-anImage.size.width/(2*scaleFactor);
    float imageOriginY = CGRectGetMidY(anImageView.frame)-anImage.size.height/(2*scaleFactor);
    return CGRectMake(imageOriginX, imageOriginY, anImage.size.width/scaleFactor, anImage.size.height/scaleFactor);
}

//get scale factor of real image to image view.
-(float)getScaleFactorOfImage:(UIImage*)anImage inImageView:(UIImageView*)anImageView{    
    float scaleFactorWidth = anImage.size.width/anImageView.frame.size.width;
    float scaleFactorHeight = anImage.size.height/anImageView.frame.size.height;    
    return scaleFactorWidth>scaleFactorHeight ? scaleFactorWidth:scaleFactorHeight;
}

- (void)hideControlBars:(BOOL)hidden
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
    [self.navigationController setNavigationBarHidden:hidden];
    [self.toolbar setHidden:hidden];
	
	[UIView commitAnimations];
}

- (void)updateHistoryButtonState
{
    if (self.historyData.count == 0) {
        [self.undoButton setEnabled:NO];
        [self.redoButton setEnabled:NO];
    } else {
        [self.undoButton setEnabled:(self.historyStep > 0)];
        [self.redoButton setEnabled:(self.historyStep < self.historyData.count - 1)];
    }
}

- (void)updateHistoryData:(SCHistoryStep *)aStep
{
    while (self.historyData.count > 0 && self.historyStep < self.historyData.count - 1) {
        [self.historyData removeLastObject];
    }
    
    [self.historyData addObject:aStep];
    self.historyStep = self.historyData.count - 1;
    
    [self updateHistoryButtonState];
}

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Rotate image base on EXIF
    //image = [self rotateImage:image byOrientationFlag:image.imageOrientation];
    
    [self.imageView setImage:image];    
    [self.navigationItem.leftBarButtonItem setTitle:@"Retake"];
    //[self.navigationController.navigationBar setTranslucent:TRUE];
    
    actionType=kSCDefault;
    
    
    //Image rotation recognizer
    UIRotationGestureRecognizer *recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [self.imageView addGestureRecognizer:recognizer];
    
    // Trible taps for binarizing the image using Otsu's method
    UITapGestureRecognizer *tribleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTribleTap:)];
    [tribleTapRecognizer setNumberOfTapsRequired:3];
    [self.imageView addGestureRecognizer:tribleTapRecognizer];
    
    // Double taps for binarizing the image using local adaptive thresholdings
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [doubleTapRecognizer requireGestureRecognizerToFail:tribleTapRecognizer];
    [self.imageView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [singleTapRecognizer requireGestureRecognizerToFail:tribleTapRecognizer];
    [self.imageView addGestureRecognizer:singleTapRecognizer];
    
    // Setup initial history data - START
    self.historyData = [[NSMutableArray alloc] initWithCapacity:0];
    
    SCHistoryStep *originalStep = [[SCHistoryStep alloc] init];
    originalStep.actionType = kSCDefault;
    originalStep.image = self.imageView.image;
    
    [self.historyData addObject:originalStep];
    self.historyStep = 0;
    
    [self updateHistoryButtonState];
    // Setup initial history data - END
    
    
    // Setup Zoom in/out - START
    scrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = 0.75;
    scrollView.clipsToBounds = YES;
    scrollView.delegate = self;    
    // Setup Zoom in/out - END
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //    [self hideControlBars:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [self hideControlBars:NO];
}

- (void)viewDidUnload
{
    //    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self setImageView:nil];
    [self setToolbar:nil];
    [self setUndoButton:nil];
    [self setRedoButton:nil];
    [self setActionButton:nil];
    [self setCropButton:nil];
    [self setScrollView:nil];
    [self setDrawButton:nil];
    [self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditToDetails"]&&actionType==kSCDefault) {
        SCDetailViewController *detailsVC = (SCDetailViewController *)segue.destinationViewController;
        detailsVC.rootImage = self.imageView.image;
    }
}

#pragma mark - Delegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 113) { // action button
        if (buttonIndex == 0) { // save photo to album
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, NULL);
        }
    }
}

@end

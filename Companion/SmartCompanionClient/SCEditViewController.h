//
//  SCEditViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDrawView.h"

typedef enum {
    
    kSCDefault = -1,
    kSCBinarizing = 0,
    kSCRotating,
    kSCCropping,
    kSCDrawing,
    kSCErasing
        
} SCActionType;

typedef enum {
    
    kSCUpdate = 0,
    kSCUndo,
    kSCRedo
    
} SCHistoryUpdateType;

@interface SCHistoryStep : NSObject

@property (nonatomic) SCActionType actionType;
@property (strong, nonatomic) UIImage *image;

@end

@interface SCEditViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate>
{
    UIImage *image;
    SCDrawView *drawView;
    SCActionType actionType;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cropButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;

@property (strong, nonatomic) NSMutableArray *historyData;
@property (nonatomic) NSInteger historyStep;

- (IBAction)handleCropButton:(id)sender;
- (IBAction)handleUndoButton:(id)sender;
- (IBAction)handleRedoButton:(id)sender;
- (IBAction)handleActionButton:(id)sender;
- (IBAction)handleRightBarButton:(id)sender;
- (IBAction)handleDrawButton:(id)sender;
- (IBAction)handleInfoButton:(id)sender;

@end

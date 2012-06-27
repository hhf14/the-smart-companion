//
//  SCDrawView.h
//  SmartCompanionClient
//
//  Created by Tran Van Nam on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCDrawView;

@protocol SCDrawViewDelegate

- (void)didSingleTap:(SCDrawView *)view;

@end

@interface SCDrawView : UIView

{
    //BOOL viewInitialized;
    
    //Crop function att - START
    
    //Move or resize crop rectangle
    BOOL isMoving, isResizing;    
    //Change of orgin of crop rectangle or not
    BOOL isChangeOriginX, isChangeOriginY;      
    //Space between touch point and crop rectangle conners
    CGPoint offset;    
    //First point of begin touch event
    CGPoint beginTouchPoint;    
    //Original size crop rectangle (before resizing)
    float oWidth, oHeight;
    
    //Crop function att - END
    
    
    //Pen function att - START
    
    CGPoint previousPoint;
    CGPoint lastPoint;
    CGMutablePathRef path;
    
    //Pen function att - END
}

//Crop/Pen mode
@property (nonatomic) int SCActionIdentify;

//Crop function property - START

@property (nonatomic) CGRect cropRect;

//Bounds of scaled image in image view
@property (nonatomic) CGRect imageBounds;

//Crop function property - END

//Pen function att - START
@property (nonatomic) float lineWidth;
@property (nonatomic) UIColor *penColor;
@property (nonatomic) UIImage *drawImage;
//Pen function att - END

@end

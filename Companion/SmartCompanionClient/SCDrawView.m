//
//  SCDrawView.m
//  SmartCompanionClient
//
//  Created by Tran Van Nam on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// action identify
#define kSCCropping 0
#define kSCDrawing 1
// default value for penColour and LineWidth
#define kSClineWidth 5.0f

//Radius from conners of crop rectangle
#define kSCRadius 8.0f

//kSCPadding must be > kSCRadius
#define kSCPadding 10.0f 

//the smallest size of crop rectangle
#define kSCLimitSize 40.0f

#import "SCDrawView.h"

@implementation SCDrawView
@synthesize cropRect, imageBounds, SCActionIdentify, lineWidth, penColor, drawImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        // init for drawing
        lineWidth = kSClineWidth;
        penColor = [UIColor redColor];        
        path = CGPathCreateMutable();
        
    }
    return self;
}
/*- (void)initialize
 {
 // Initialization code
 }
 */

- (void)drawRect:(CGRect)rect
{
    /*if (!viewInitialized) {
     [self initialize];
     }*/
    
    CGContextRef context = UIGraphicsGetCurrentContext();    
    
    if (SCActionIdentify == kSCCropping){ 
        CGContextSetLineWidth(context, 3.0);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextAddRect(context, cropRect);
        CGContextStrokePath(context);
        
        [self fillOutsideRect:cropRect 
               withCGColorRef:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]CGColor] 
               currentContext:context];    
        [self fillCirclesAtConnersOfRect:self.cropRect withRadius:kSCRadius andCGColorRef:[[UIColor whiteColor] CGColor] currentContext:context];    
    }
    
    if (SCActionIdentify == kSCDrawing){
        
        CGPathMoveToPoint(path, NULL, previousPoint.x, previousPoint.y);
        CGPathAddLineToPoint(path, NULL, lastPoint.x, lastPoint.y);
        CGContextAddPath(context, path);
        CGContextSetLineWidth(context, lineWidth);
        [penColor setStroke];
        CGContextDrawPath(context, kCGPathFillStroke);
         
    }
}

- (void)fillCirclesAtConnersOfRect:(CGRect)rect withRadius:(float)radius andCGColorRef:(CGColorRef)colorRef currentContext:(CGContextRef)context{
    
    CGRect topLeft = CGRectMake(rect.origin.x-radius, rect.origin.y-radius, radius*2, radius*2);
    CGRect topRight = CGRectMake(rect.origin.x+rect.size.width-radius, rect.origin.y-radius, radius*2, radius*2);
    CGRect bottomLeft = CGRectMake(rect.origin.x-radius, rect.origin.y+rect.size.height-radius, radius*2, radius*2);
    CGRect bottomRight = CGRectMake(rect.origin.x+rect.size.width-radius, rect.origin.y+rect.size.height-radius, radius*2, radius*2);
    
    CGContextSetFillColorWithColor(context, colorRef); 
    CGContextFillEllipseInRect(context, topLeft);
    CGContextFillEllipseInRect(context, topRight);
    CGContextFillEllipseInRect(context, bottomLeft);
    CGContextFillEllipseInRect(context, bottomRight);
    
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddEllipseInRect(context, topLeft);
    CGContextAddEllipseInRect(context, topRight);
    CGContextAddEllipseInRect(context, bottomLeft);
    CGContextAddEllipseInRect(context, bottomRight);
    CGContextStrokePath(context);
}

- (void)fillOutsideRect:(CGRect)rect withCGColorRef:(CGColorRef)colorRef currentContext:(CGContextRef)context{
    CGContextSetFillColorWithColor(context, colorRef);
    
    //fill upper rect
    CGContextFillRect(context, CGRectMake(self.frame.origin.x, self.frame.origin.y, 
                                          self.frame.size.width, rect.origin.y));
    //fill botton rect
    CGContextFillRect(context, CGRectMake(self.frame.origin.x, 
                                          rect.origin.y+rect.size.height, 
                                          self.frame.size.width, 
                                          self.frame.size.height-rect.origin.y-rect.size.height));
    //fill left rect
    CGContextFillRect(context, CGRectMake(self.frame.origin.x, rect.origin.y, 
                                          rect.origin.x, rect.size.height));
    //fill right rect
    CGContextFillRect(context, CGRectMake(rect.origin.x+rect.size.width, 
                                          rect.origin.y, 
                                          self.frame.size.width-rect.origin.x-rect.size.width, 
                                          rect.size.height));
}

//Check touch point near one of other point or not
- (BOOL)isTouchPoint:(CGPoint)tPoint inRangeOfPoint:(CGPoint)rPoint withRadius:(float)radius{
    return (tPoint.x-rPoint.x)*(tPoint.x-rPoint.x) + (tPoint.y-rPoint.y)*(tPoint.y-rPoint.y) <= radius*radius;
}

//Check touch point near conners of crop rectangle or not
- (BOOL)isRectangleResizable:(CGPoint)point rect:(CGRect)rect{
    
    return ([self isTouchPoint:point inRangeOfPoint:rect.origin withRadius:kSCRadius]||
            [self isTouchPoint:point inRangeOfPoint:CGPointMake(rect.origin.x, rect.origin.y+rect.size.height) withRadius:kSCRadius]||
            [self isTouchPoint:point inRangeOfPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y) withRadius:kSCRadius]||
            [self isTouchPoint:point inRangeOfPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height) withRadius:kSCRadius]);
}

//Check a rect inside a bounds
- (BOOL)isRect:(CGRect)aRect insideBounds:(CGRect)bounds{
    return !(aRect.origin.x<bounds.origin.x||aRect.origin.y<bounds.origin.y
             ||aRect.origin.x+aRect.size.width>bounds.origin.x+bounds.size.width
             ||aRect.origin.y+aRect.size.height>bounds.origin.y+bounds.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        
        UITouch *touchPoint = [[touches allObjects] objectAtIndex:0];
        CGPoint cgTouchPoint = [touchPoint locationInView:self];
        
        if (SCActionIdentify == kSCCropping){
            //Touch to move area
            CGRect touchToMoveArea = CGRectMake(self.cropRect.origin.x+kSCPadding, self.cropRect.origin.y+kSCPadding, 
                                                self.cropRect.size.width-2*kSCPadding, self.cropRect.size.height-2*kSCPadding);
            
            //Check touch point inside crop rect's area
            if (CGRectContainsPoint(touchToMoveArea, cgTouchPoint)) {
                isMoving = TRUE;
                offset = CGPointMake(cgTouchPoint.x - self.cropRect.origin.x, cgTouchPoint.y - self.cropRect.origin.y);
            }
            
            //Check touch point near crop rect's peaks or not
            else if([self isRectangleResizable:cgTouchPoint rect:cropRect]){
                isResizing = TRUE;
                offset = CGPointMake(cgTouchPoint.x - self.cropRect.origin.x, cgTouchPoint.y - self.cropRect.origin.y);            
                beginTouchPoint = CGPointMake(cgTouchPoint.x, cgTouchPoint.y);
                oWidth = cropRect.size.width;
                oHeight = cropRect.size.height;    
                
                if(cgTouchPoint.x >= cropRect.origin.x-kSCRadius && cgTouchPoint.x <= cropRect.origin.x+kSCRadius){
                    isChangeOriginX = TRUE;                
                }
                if(cgTouchPoint.y >= cropRect.origin.y-kSCRadius && cgTouchPoint.y <= cropRect.origin.y+kSCRadius){
                    isChangeOriginY = TRUE;                 
                }
            }
        }
        
        else if (SCActionIdentify == kSCDrawing){
            if([touchPoint tapCount]>1){
                path = CGPathCreateMutable();
                previousPoint = lastPoint;
            }
            
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if ([touches count] == 1) {
        
        UITouch *touchPoint = [[touches allObjects] objectAtIndex:0];
        CGPoint cgTouchPoint = [touchPoint locationInView:self];
        
        if (SCActionIdentify == kSCCropping){
            float width,height,originX,originY;
            
            if (isMoving) {
                originX = cgTouchPoint.x-offset.x;
                originY = cgTouchPoint.y-offset.y;
                
                if(originX<imageBounds.origin.x){
                    originX = imageBounds.origin.x;
                }else if(originX+cropRect.size.width>imageBounds.origin.x+imageBounds.size.width) {
                    originX = imageBounds.origin.x+imageBounds.size.width-cropRect.size.width;
                }
                if(originY<imageBounds.origin.y){
                    originY = imageBounds.origin.y;
                }else if(originY+cropRect.size.height>imageBounds.origin.y+imageBounds.size.height){
                    originY = imageBounds.origin.y+imageBounds.size.height-cropRect.size.height;
                }
                cropRect.origin = CGPointMake(originX,originY);
                [self setNeedsDisplay];
            } 
            else if (isResizing) {
                originX = cropRect.origin.x;
                originY = cropRect.origin.y;
                
                //bottom lef conner
                if(isChangeOriginX&&!isChangeOriginY){
                    originX =  cgTouchPoint.x-offset.x;
                    width = oWidth - (cgTouchPoint.x - beginTouchPoint.x);
                    height = oHeight + (cgTouchPoint.y - beginTouchPoint.y);
                    if(originX<imageBounds.origin.x){
                        originX = imageBounds.origin.x;
                        width = oWidth + beginTouchPoint.x - offset.x - imageBounds.origin.x;
                    }
                    if(cropRect.origin.y + height>imageBounds.origin.y+imageBounds.size.height){
                        height = imageBounds.origin.y+imageBounds.size.height-cropRect.origin.y;
                    }                   
                }
                //top right conner
                else if(!isChangeOriginX&&isChangeOriginY){
                    originY = cgTouchPoint.y-offset.y;
                    width = oWidth + (cgTouchPoint.x - beginTouchPoint.x);
                    height = oHeight - (cgTouchPoint.y - beginTouchPoint.y);
                    
                    if(originY<imageBounds.origin.y){
                        originY = imageBounds.origin.y;
                        height = oHeight + beginTouchPoint.y - offset.y - imageBounds.origin.y;
                    }
                    if(cropRect.origin.x + width>imageBounds.origin.x+imageBounds.size.width){
                        width = imageBounds.origin.x+imageBounds.size.width-cropRect.origin.x;
                    }
                }
                //top left conner
                else if(isChangeOriginX&&isChangeOriginY){
                    originX =  cgTouchPoint.x-offset.x;
                    originY = cgTouchPoint.y-offset.y;
                    width = oWidth-(cgTouchPoint.x-beginTouchPoint.x);
                    height = oHeight-(cgTouchPoint.y-beginTouchPoint.y);
                    
                    if(originX<imageBounds.origin.x){
                        originX = imageBounds.origin.x;
                        width = oWidth + beginTouchPoint.x - offset.x - imageBounds.origin.x;
                    }
                    if(originY<imageBounds.origin.y){
                        originY = imageBounds.origin.y;
                        height = oHeight + beginTouchPoint.y - offset.y - imageBounds.origin.y;
                    }
                }
                //bottom right conner  
                else {
                    width = oWidth + (cgTouchPoint.x - beginTouchPoint.x);
                    height = oHeight + (cgTouchPoint.y - beginTouchPoint.y);
                    
                    if(cropRect.origin.x + width>imageBounds.origin.x+imageBounds.size.width){
                        width = imageBounds.origin.x+imageBounds.size.width-cropRect.origin.x;
                    }
                    if(cropRect.origin.y + height>imageBounds.origin.y+imageBounds.size.height){
                        height = imageBounds.origin.y+imageBounds.size.height-cropRect.origin.y;
                    }      
                }
                if(width>kSCLimitSize&&height>kSCLimitSize){
                    cropRect.origin.x = originX;
                    cropRect.origin.y = originY;
                    cropRect.size.width = width;
                    cropRect.size.height = height;
                }
                [self setNeedsDisplay];
            }
            
        } 
        
        else if (SCActionIdentify == kSCDrawing){            
            lastPoint = [[touches anyObject] locationInView:self];
            previousPoint = [[touches anyObject] previousLocationInView:self];            
            [self setNeedsDisplay];
        }
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (SCActionIdentify == kSCCropping){
        if (isResizing) {
            isResizing = FALSE;
            isChangeOriginX = FALSE;
            isChangeOriginY = FALSE;
            [self setNeedsDisplay];
        }
        if(isMoving){
            isMoving = FALSE;
            [self setNeedsDisplay];
        }
    } 
}

@end

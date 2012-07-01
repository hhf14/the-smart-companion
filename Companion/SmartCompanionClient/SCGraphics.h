//
//  SCGraphics.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCGraphics : NSObject
{
    
}

+ (UIImage *)normalizeImage:(UIImage *)anImage;
+ (UIImage *)convertImageToGrayScale:(UIImage *)anImage;
+ (UIImage *)binarizeImageUsingOtsuMethod:(UIImage *)inputImage;
+ (UIImage *)binarizeImageUsingLocalAdaptiveThresholding:(UIImage *)inputImage;
+ (UIImage *)removeNoisesForBinaryImage:(UIImage *)inputImage;

@end

@interface SCBlob : NSObject

@property (nonatomic) int xMin;
@property (nonatomic) int xMax;
@property (nonatomic) int yMin;
@property (nonatomic) int yMax;
@property (nonatomic) int mass;

- (id)initWithXMax:(int)xMax xMin:(int)xMin yMax:(int)yMax yMin:(int)yMin mass:(int)mass;
- (NSString *)toString;

@end

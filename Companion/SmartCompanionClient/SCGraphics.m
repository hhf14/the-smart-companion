//
//  SCGraphics.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCGraphics.h"

//static int _inputData[3][4];

@interface SCGraphics ()

+ (int)calcuateIntegralSumAtX:(int)x Y:(int)Y currentData:(int **)currentData inputData:(int **)inputData;

@end

@implementation SCGraphics

+ (UIImage *)setContrast:(NSInteger)nContrast forImage:(UIImage *)anImage
{
    nContrast = MAX(MIN(nContrast, 100), -100);
    double contrast = (100.0 + nContrast) / 100.0;
    contrast *= contrast;
    
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(anImage.CGImage)); 
    UInt8 *imageData = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    int length = CFDataGetLength(imageDataRef); 
    
    for (int i = 0; i < length; i++) {        
        double pixel = imageData[i] / 255.0;
        pixel -= 0.5;
        pixel *= contrast;
        pixel += 0.5;
        pixel *= 255;
        if (pixel < 0) pixel = 0;
        if (pixel > 255) pixel = 255;
        imageData[i] = (UInt8)pixel;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(imageData, 
                                             CGImageGetWidth(anImage.CGImage), 
                                             CGImageGetHeight(anImage.CGImage), 
                                             8,
                                             CGImageGetBytesPerRow(anImage.CGImage), 
                                             CGImageGetColorSpace(anImage.CGImage), 
                                             kCGImageAlphaPremultipliedLast); 
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGContextRelease(ctx); 
    
    return rawImage;   
}

+ (UIImage *)normalizeImage:(UIImage *)anImage 
{
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = anImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = anImage.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy; 
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)anImage 
{
    anImage = [self normalizeImage:anImage]; //THIS IS WHERE REPAIR THE ROTATION PROBLEM

    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, anImage.size.width, anImage.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, 
                                                 anImage.size.width, 
                                                 anImage.size.height, 
                                                 8, 
                                                 anImage.size.width, 
                                                 colorSpace, 
                                                 kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [anImage CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object  
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);

    // Return the new grayscale image
    return newImage; 
}

+ (UIImage *)binarizeImageUsingOtsuMethod:(UIImage *)inputImage
{    
    // Convert to grayscale image
    UIImage *grayscaleImage = [SCGraphics convertImageToGrayScale:inputImage];
    
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(grayscaleImage.CGImage)); 
    UInt8 *imageData = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    int length = CFDataGetLength(imageDataRef); 
    
    // Calculate histogram
    int histData[256];
    int ptr = 0;
    memset(histData, 0, sizeof(histData));
    while (ptr < length) {
        int h = 0xFF & imageData[ptr];
        histData[h]++;
        ptr++;
    }
    
    // Total number of pixels    
    float sum = 0;
    for (int t = 0; t < 256; t++) sum += t * histData[t];
    
    float sumB = 0;
    int wB = 0;
    int wF = 0;
    
    float varMax = 0;
    float threshold = 0;
    
    for (int t=0 ; t<256 ; t++) {
        wB += histData[t];               // Weight Background
        if (wB == 0) continue;
        
        wF = length - wB;                 // Weight Foreground
        if (wF == 0) break;
        
        sumB += (float) (t * histData[t]);
        
        float mB = sumB / wB;            // Mean Background
        float mF = (sum - sumB) / wF;    // Mean Foreground
        
        // Calculate Between Class Variance
        float varBetween = (float)wB * (float)wF * (mB - mF) * (mB - mF);
        
        // Check if new maximum found
        if (varBetween > varMax) {
            varMax = varBetween;
            threshold = t;
        }
    }

    for (int i = 0; i < length; i ++) 
    { 
        if (imageData[i] < threshold) {
            imageData[i] = 0;
        } else {
            imageData[i] = 255;
        }
    } 
    
    CGContextRef ctx = CGBitmapContextCreate(imageData, 
                                CGImageGetWidth(grayscaleImage.CGImage), 
                                CGImageGetHeight(grayscaleImage.CGImage), 
                                8,
                                CGImageGetBytesPerRow(grayscaleImage.CGImage), 
                                CGImageGetColorSpace(grayscaleImage.CGImage), 
                                kCGImageAlphaNone); 
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGContextRelease(ctx); 
    
    return rawImage;    
}

+ (int)calcuateIntegralSumAtX:(int)x Y:(int)y currentData:(int **)currentData inputData:(int **)inputData
{
    if (x == 0 && y == 0) {
        return inputData[x][y];
    } else if (x == 0) {
        return inputData[x][y] + currentData[x][y-1];
    } else if (y == 0) {
        return inputData[x][y] + currentData[x-1][y];
    } else {
        return inputData[x][y] + currentData[x-1][y] + currentData[x][y-1] - currentData[x-1][y-1];
    }
}

+ (UIImage *)binarizeImageUsingLocalAdaptiveThresholding:(UIImage *)inputImage
{
    int const WINDOW_SIZE = 33;
    float const ADAPTATION_CONSTANT = 0.00001;
    
    // Convert the color image into grayscale
    UIImage *grayscaleImage = [SCGraphics convertImageToGrayScale:inputImage];
    
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(grayscaleImage.CGImage)); 
    UInt8 *dataPtr = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    int length = CFDataGetLength(imageDataRef); 
    
    int imageWidth = CGImageGetWidth(grayscaleImage.CGImage);
    int imageHeight = CGImageGetHeight(grayscaleImage.CGImage);
    
    int **inputData = NULL, **integralSum = NULL;
    inputData = (int **)malloc(imageHeight * sizeof(int));
    integralSum = (int **)malloc(imageHeight * sizeof(int));
        
    // Calculate integral sum image
    for (int i = 0; i < imageHeight; i++) {
        
        inputData[i] = (int *)malloc(imageWidth * sizeof(int));
        integralSum[i] = (int *)malloc(imageWidth * sizeof(int));
        
        for (int j = 0; j < imageWidth; j++) {
            inputData[i][j] = dataPtr[i * imageWidth + j];
            integralSum[i][j] = [SCGraphics calcuateIntegralSumAtX:i Y:j currentData:integralSum inputData:inputData];
        }
    }

    // Calculate local thresholds
    float thresholds[length];
    int d = WINDOW_SIZE / 2 + 1;
    for (int x = 0; x < imageHeight; x++) {
        for (int y = 0; y < imageWidth; y++) {
            
            int i1 = x + d - 1 > imageHeight - 1 ? imageHeight - 1 : x + d - 1;
            int i2 = y + d - 1 > imageWidth - 1 ? imageWidth - 1 :y + d - 1;
            int i3 = x - d > 0 ? x - d : 0;
            int i4 = y - d > 0 ? y - d : 0;
                    
            float localSum = integralSum[i1][i2] + integralSum[i3][i4] - integralSum[i3][i2] - integralSum[i1][i4];
            float localMean = localSum / (WINDOW_SIZE * WINDOW_SIZE);
            float localMeanDeviation = inputData[x][y] - localMean;
            float localThreshold = localMean * (1 + ADAPTATION_CONSTANT * (localMeanDeviation / (1 - localMeanDeviation) - 1));
            
            thresholds[x * imageWidth + y] = localThreshold;
        }
    }
        
    // Binarize the image using local threshold values
    for (int i = 0; i < length; i ++) 
    { 
        if (dataPtr[i] < thresholds[i]) {
            dataPtr[i] = 0;
        } else {
            dataPtr[i] = 255;
        }        
    } 
    
    CGContextRef ctx = CGBitmapContextCreate(dataPtr, 
                                             CGImageGetWidth(grayscaleImage.CGImage), 
                                             CGImageGetHeight(grayscaleImage.CGImage), 
                                             8,
                                             CGImageGetBytesPerRow(grayscaleImage.CGImage), 
                                             CGImageGetColorSpace(grayscaleImage.CGImage), 
                                             kCGImageAlphaNone); 
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGContextRelease(ctx); 
    
    return rawImage; 
}

+ (UIImage *)removeNoisesForBinaryImage:(UIImage *)binarizedImage
{
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(binarizedImage.CGImage)); 
    UInt8 *srcData = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    CFIndex imgLength = CFDataGetLength(imageDataRef);
    
    int width = CGImageGetWidth(binarizedImage.CGImage);
    int height = CGImageGetHeight(binarizedImage.CGImage);
    
    if (imgLength != width * height) {
        NSLog(@"The input image is not a binarized image!");
        return nil;
    }
        
    int matchVal = 0, minBlobMass = 0, maxBlobMass = -1;
    int tableSize = width * height / 4;
    
    int *labelBuffer = (int *)calloc(width * height, sizeof(int));
    int *labelTable = (int *)calloc(tableSize, sizeof(int));
    
    int *xMinTable = (int *)calloc(tableSize, sizeof(int));
    int *xMaxTable = (int *)calloc(tableSize, sizeof(int));
    int *yMinTable = (int *)calloc(tableSize, sizeof(int));
    int *yMaxTable = (int *)calloc(tableSize, sizeof(int));
    int *massTable = (int *)calloc(tableSize, sizeof(int));
    
    // This is the neighbouring pixel pattern. For position X, A, B, C & D are checked
    // A B C
    // D X
    
    int srcPtr = 0;
    int aPtr = -width - 1;
    int bPtr = -width;
    int cPtr = -width + 1;
    int dPtr = -1;
    
    int label = 1;
    
    // Iterate through pixels looking for connected regions. Assigning labels
    for (int y=0 ; y<height ; y++)
    {
        for (int x=0 ; x<width ; x++)
        {
            labelBuffer[srcPtr] = 0;
            
            // Check if on foreground pixel
            if (srcData[srcPtr] == matchVal)
            {
                // Find label for neighbours (0 if out of range)
                int aLabel = (x > 0 && y > 0) ? labelTable[labelBuffer[aPtr]] : 0;
                int bLabel = (y > 0) ? labelTable[labelBuffer[bPtr]] : 0;
                int cLabel = (x < width-1 && y > 0)	? labelTable[labelBuffer[cPtr]] : 0;
                int dLabel = (x > 0) ? labelTable[labelBuffer[dPtr]] : 0;
                
                // Look for label with least value
                int min = INT32_MAX;
                if (aLabel != 0 && aLabel < min) min = aLabel;
                if (bLabel != 0 && bLabel < min) min = bLabel;
                if (cLabel != 0 && cLabel < min) min = cLabel;
                if (dLabel != 0 && dLabel < min) min = dLabel;
                
                // If no neighbours in foreground
                if (min == INT32_MAX)
                {
                    labelBuffer[srcPtr] = label;
                    labelTable[label] = label;
                    
                    // Initialise min/max x,y for label
                    yMinTable[label] = y;
                    yMaxTable[label] = y;
                    xMinTable[label] = x;
                    xMaxTable[label] = x;
                    massTable[label] = 1;
                    
                    label ++;
                }
                
                // Neighbour found
                else
                {
                    // Label pixel with lowest label from neighbours
                    labelBuffer[srcPtr] = min;
                    
                    // Update min/max x,y for label
                    yMaxTable[min] = y;
                    massTable[min]++;
                    if (x < xMinTable[min]) xMinTable[min] = x;
                    if (x > xMaxTable[min]) xMaxTable[min] = x;
                    
                    if (aLabel != 0) labelTable[aLabel] = min;
                    if (bLabel != 0) labelTable[bLabel] = min;
                    if (cLabel != 0) labelTable[cLabel] = min;
                    if (dLabel != 0) labelTable[dLabel] = min;
                }
            }
            
            srcPtr ++;
            aPtr ++;
            bPtr ++;
            cPtr ++;
            dPtr ++;
        }
    }
    
    // Iterate through labels pushing min/max x,y values towards minimum label
    NSMutableArray *blobList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=label-1 ; i>0 ; i--)
    {
        if (labelTable[i] != i)
        {
            if (xMaxTable[i] > xMaxTable[labelTable[i]]) xMaxTable[labelTable[i]] = xMaxTable[i];
            if (xMinTable[i] < xMinTable[labelTable[i]]) xMinTable[labelTable[i]] = xMinTable[i];
            if (yMaxTable[i] > yMaxTable[labelTable[i]]) yMaxTable[labelTable[i]] = yMaxTable[i];
            if (yMinTable[i] < yMinTable[labelTable[i]]) yMinTable[labelTable[i]] = yMinTable[i];
            massTable[labelTable[i]] += massTable[i];
            
            int l = i;
            while (l != labelTable[l]) l = labelTable[l];
            labelTable[i] = l;
        }
        else
        {
            // Ignore blobs that butt against corners
            if (i == labelBuffer[0]) continue;									// Top Left
            if (i == labelBuffer[width]) continue;								// Top Right
            if (i == labelBuffer[(width*height) - width + 1]) continue;	// Bottom Left
            if (i == labelBuffer[(width*height) - 1]) continue;			// Bottom Right
            
            if (massTable[i] >= minBlobMass && (massTable[i] <= maxBlobMass || maxBlobMass == -1))
            {
                SCBlob *blob = [[SCBlob alloc] initWithXMax:xMaxTable[i] 
                                                       xMin:xMinTable[i] 
                                                       yMax:yMaxTable[i] 
                                                       yMin:yMinTable[i] 
                                                       mass:massTable[i]];
                [blobList addObject:blob];
            }
        }
    }
    
    CGContextRef ctx = CGBitmapContextCreate(srcData, 
                                             CGImageGetWidth(binarizedImage.CGImage), 
                                             CGImageGetHeight(binarizedImage.CGImage), 
                                             8,
                                             CGImageGetBytesPerRow(binarizedImage.CGImage), 
                                             CGImageGetColorSpace(binarizedImage.CGImage),
                                             kCGImageAlphaNone); 
    
    
    CGContextTranslateCTM(ctx, 0.0, height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CGContextBeginPath(ctx);
    
    // calculate mean & standard deviation of blob's height values
    float bMean = 0, bSquareSum = 0;
    for (int i = 0; i < blobList.count; i++) {
        SCBlob *iBlob = (SCBlob *)[blobList objectAtIndex:i];
        int blobHeight = iBlob.yMax - iBlob.yMin;
        bMean += blobHeight;
        bSquareSum += blobHeight * blobHeight;
        if (i == blobList.count - 1) {
            bMean /= blobList.count;
            bSquareSum /= blobList.count;
        }
    }
    
    float bStarndardDeviation = sqrtf(bSquareSum - (bMean * bMean));
    // define a maximum value for height of a valid blob
    float bMax = MAX(bMean + 3 * bStarndardDeviation, 0);

#if TRUE
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    for (SCBlob *blob in blobList) {
        
        CGFloat rWidth = blob.xMax - blob.xMin;
        CGFloat rHeight = blob.yMax - blob.yMin;
        CGRect blobRect = CGRectMake(blob.xMin, blob.yMin, rWidth + 1, rHeight + 1);
        
        // remove blobs whose height value is considered as out-of-valid-range
        if (rHeight > bMax) {
            CGContextFillRect(ctx, blobRect);
        }
    }
#else
    CGContextBeginPath(ctx);
    for (SCBlob *blob in blobList) {
        
        CGFloat rWidth = blob.xMax - blob.xMin;
        CGFloat rHeight = blob.yMax - blob.yMin;
        CGRect blobRect = CGRectMake(blob.xMin, blob.yMin, rWidth + 1, rHeight + 1);
        
        CGContextAddRect(ctx, blobRect);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
#endif
        
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGContextRelease(ctx); 
    
    return rawImage;    
}

@end

@implementation SCBlob
@synthesize xMax, xMin, yMax, yMin, mass;

- (id)initWithXMax:(int)_xMax xMin:(int)_xMin yMax:(int)_yMax yMin:(int)_yMin mass:(int)_mass
{
    self = [super init];
    if (self) {
        self.xMax = _xMax;
        self.xMin = _xMin;
        self.yMax = _yMax;
        self.yMin = _yMin;
        self.mass = _mass;
    }
    return self;
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"X: %i -> %i, Y: %i -> %i, mass: %i", self.xMin, self.xMax, self.yMin, self.yMax, self.mass];
}

@end

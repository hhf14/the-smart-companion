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
    CGContextRef context = CGBitmapContextCreate(nil, anImage.size.width, anImage.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
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

#if TRUE
+ (UIImage *)detectBlobsWithImage:(UIImage *)inputImage
{
    // Convert to binary image
    UIImage *binarizedImage = [SCGraphics binarizeImageUsingOtsuMethod:inputImage];
    
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(binarizedImage.CGImage)); 
    UInt8 *srcData = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    
    int width = CGImageGetWidth(binarizedImage.CGImage);
    int height = CGImageGetHeight(binarizedImage.CGImage);
    
    // This is the neighbouring pixel pattern. For position X, A, B, C & D are checked
    // A B C
    // D X
    
    int srcPtr = 0;
    int aPtr = -width - 1;
    int bPtr = -width;
    int cPtr = -width + 1;
    int dPtr = -1;
    
    int label = 1;
    
#if FALSE
    int *labelBuffer = (int *)malloc(width * height * sizeof(int));
#else
    int labelBuffer[width * height];
#endif
    int matchVal = 255, minBlobMass = 0, maxBlobMass = -1;

    // The maximum number of blobs is given by an image filled with equally spaced single pixel
    // blobs. For images with less blobs, memory will be wasted, but this approach is simpler and
    // probably quicker than dynamically resizing arrays
    int tableSize = width * height / 4;
    
#if FALSE
    int *labelTable = (int *)malloc(tableSize * sizeof(int));
    int *xMinTable = (int *)malloc(tableSize * sizeof(int));
    int *xMaxTable = (int *)malloc(tableSize * sizeof(int));
    int *yMinTable = (int *)malloc(tableSize * sizeof(int));
    int *yMaxTable = (int *)malloc(tableSize * sizeof(int));
    int *massTable = (int *)malloc(tableSize * sizeof(int));
#else
    int labelTable[tableSize];
    int xMinTable[tableSize];
    int xMaxTable[tableSize];
    int yMinTable[tableSize];
    int yMaxTable[tableSize];
    int massTable[tableSize];
#endif
    
#if FALSE
    memset(labelBuffer, 0, width * height * sizeof(int));
    memset(labelTable, 0, tableSize * sizeof(int));
    memset(xMinTable, 0, tableSize * sizeof(int));
    memset(xMaxTable, 0, tableSize * sizeof(int));
    memset(yMinTable, 0, tableSize * sizeof(int));
    memset(yMaxTable, 0, tableSize * sizeof(int));
    memset(massTable, 0, tableSize * sizeof(int));   
#else
    int length = width * height;
    for (int i = 0; i < length; i++) {
        labelBuffer[i] = 0;
    }    
//    memset(labelBuffer, 0, sizeof(labelBuffer));
    memset(labelTable, 0, sizeof(labelTable));
    memset(xMinTable, 0, sizeof(xMinTable));
    memset(yMinTable, 0, sizeof(yMinTable));
    memset(yMaxTable, 0, sizeof(yMaxTable));
    memset(xMaxTable, 0, sizeof(xMaxTable));
#endif
    
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
//            
//            NSLog(@"%d", labelTable[i]);
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
                SCBlob *blob = [[SCBlob alloc] initWithXMax:xMaxTable[i] xMin:xMinTable[i] yMax:yMaxTable[i] yMin:yMinTable[i] mass:massTable[i]];
                [blobList addObject:blob];
            }
        }
    }
    
    UIColor *color1 = [[UIColor alloc] initWithRed:((float)103/255) 
                                             green:((float)121/255) 
                                              blue:((float)255/255) 
                                             alpha:((float)255/255)];
    UIColor *color2 = [[UIColor alloc] initWithRed:((float)249/255) 
                                             green:((float)255/255) 
                                              blue:((float)139/255) 
                                             alpha:((float)255/255)];
    UIColor *color3 = [[UIColor alloc] initWithRed:((float)140/255) 
                                             green:((float)255/255) 
                                              blue:((float)127/255) 
                                             alpha:((float)255/255)];
    UIColor *color4 = [[UIColor alloc] initWithRed:((float)167/255) 
                                             green:((float)254/255) 
                                              blue:((float)255/255) 
                                             alpha:((float)255/255)];
    UIColor *color5 = [[UIColor alloc] initWithRed:((float)255/255) 
                                             green:((float)111/255) 
                                              blue:((float)71/255) 
                                             alpha:((float)255/255)];
    NSArray *colorArray = [[NSArray alloc] initWithObjects:color1, color2, color3, color4, color5, nil];

    // If dst buffer provided, fill with coloured blobs
    int *dstData = (int *)malloc(width * height * 4 * sizeof(int));
    if (dstData != nil)
    {
        for (int i=label-1 ; i>0 ; i--)
        {
            if (labelTable[i] != i)
            {
                int l = i;
                while (l != labelTable[l]) l = labelTable[l];
                labelTable[i] = l;
            }
        }
        
        // Renumber lables into sequential numbers, starting with 0
        int newLabel = 0;
        for (int i=1 ; i<label ; i++)
        {
            if (labelTable[i] == i) labelTable[i] = newLabel++;
            else labelTable[i] = labelTable[labelTable[i]];
        }
        
        srcPtr = 0;
        int dstPtr = 0;
        while (srcPtr < width * height)
        {
            if (srcData[srcPtr] == matchVal)
            {
                int c = labelTable[labelBuffer[srcPtr]] % [colorArray count];
                float red = 0, green = 0, blue = 0, alpha = 0;
                [((UIColor *)[colorArray objectAtIndex:c]) getRed:&red green:&green blue:&blue alpha:&alpha];
                dstData[dstPtr]	= (int)(red * 255);
                dstData[dstPtr+1] = (int)(green * 255);
                dstData[dstPtr+2] = (int)(blue * 255);
                dstData[dstPtr+3] = (int)(alpha * 255);
            }
            else
            {
                dstData[dstPtr]	= 0;
                dstData[dstPtr+1] = 0;
                dstData[dstPtr+2] = 0;
                dstData[dstPtr+3] = 0;
            }
            
            srcPtr ++;
            dstPtr += 4;
        }
    }
        
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(dstData, 
                                             CGImageGetWidth(binarizedImage.CGImage), 
                                             CGImageGetHeight(binarizedImage.CGImage), 
                                             8,
                                             4 * CGImageGetBytesPerRow(binarizedImage.CGImage), 
                                             colorSpace, 
                                             kCGImageAlphaPremultipliedLast); 
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx); 
    
    return rawImage;    
}
#else
+ (UIImage *)detectBlobsWithImage:(UIImage *)inputImage
{
    // Convert to binary image
    UIImage *binarizedImage = [SCGraphics binarizeImageUsingOtsuMethod:inputImage];
    
    // Obtain image data
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(binarizedImage.CGImage)); 
    UInt8 *srcData = (UInt8 *) CFDataGetBytePtr(imageDataRef); 
    
    int width = CGImageGetWidth(binarizedImage.CGImage);
    int height = CGImageGetHeight(binarizedImage.CGImage);
    int length = width * height;
    
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:(width * height)];
    NSMutableDictionary *equivalences = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int i = 0; i < length; i++) {
        // Assign 0 label for all pixels
        [labels addObject:[NSNumber numberWithInt:0]];
    }
        
    // Iterate through pixels looking for connected regions. Assigning labels
    int label = 1;
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            
            // Check for black pixels only
            if (srcData[y * width + x] == 255) {
                // Get labels of its four neighbors
                int mIndex = y * width + x;
                int uIndex = ((y - 1) * width + x);
                int dIndex = ((y + 1) * width + x);
                int lIndex = (y * width + x - 1);
                int rIndex = (y * width + x + 1);
                
                int uNeighbor = y > 0 ? [[labels objectAtIndex:uIndex] intValue] : 0;
                int dNeighbor = y < height - 1 ? [[labels objectAtIndex:dIndex] intValue] : 0;
                int lNeighbor = x > 0 ? [[labels objectAtIndex:lIndex] intValue] : 0;
                int rNeighbor = x < width - 1 ? [[labels objectAtIndex:rIndex] intValue] : 0;
                
                int nUnlabeleds = 0;
                NSArray *neighbors = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:uNeighbor], [NSNumber numberWithInt:dNeighbor], [NSNumber numberWithInt:lNeighbor], [NSNumber numberWithInt:rNeighbor], nil];
                for (NSNumber *neighbor in neighbors) {
                    if ([neighbor intValue] == 0) {
                        nUnlabeleds++;
                    }
                }
                
                if (nUnlabeleds == 4) { // If all four neighbors are 0, assign a new label to the pixel
                    [labels replaceObjectAtIndex:mIndex withObject:[NSNumber numberWithInt:label++]];
                } else { 
                    
                    // 1. If only one neighbor has been labeled (!= 0), assign its label to the pixel                    
                    // 2. If more than one of the neighbors have been labeled (!= 0), assign one of the labels to the pixel and make a note of the equivalences.
                    
                    for (NSNumber *neighbor in neighbors) {
                        if ([neighbor intValue] > 0) {
                            [labels replaceObjectAtIndex:mIndex withObject:neighbor];
                            break;
                        }
                    }
                    
                    if (nUnlabeleds < 3) {
                        // Mark all equivalences
                        for (int i = 0; i < neighbors.count - 1; i++) {
                            for (int j = i + 1; j < neighbors.count; j++) {
                                int label1 = [((NSNumber *)[neighbors objectAtIndex:i]) intValue];
                                int label2 = [((NSNumber *)[neighbors objectAtIndex:j]) intValue];                                
                                if (label1 == label2) {
                                    if ([[equivalences allKeys] containsObject:[neighbors objectAtIndex:i]]) {
                                        NSMutableSet *myEquivalences = [equivalences objectForKey:[neighbors objectAtIndex:i]];
                                        [myEquivalences addObject:[neighbors objectAtIndex:j]];
                                        [equivalences setObject:myEquivalences forKey:[neighbors objectAtIndex:i]];
                                    } else {
                                        NSMutableSet *myEquivalences = [[NSMutableSet alloc] initWithObjects:[neighbors objectAtIndex:j], nil];
                                        [equivalences setObject:myEquivalences forKey:[neighbors objectAtIndex:i]];
                                    }
                                    if ([[equivalences allKeys] containsObject:[neighbors objectAtIndex:j]]) {
                                        NSMutableSet *myEquivalences = [equivalences objectForKey:[neighbors objectAtIndex:j]];
                                        [myEquivalences addObject:[neighbors objectAtIndex:i]];
                                        [equivalences setObject:myEquivalences forKey:[neighbors objectAtIndex:j]];
                                    } else {
                                        NSMutableSet *myEquivalences = [[NSMutableSet alloc] initWithObjects:[neighbors objectAtIndex:i], nil];
                                        [equivalences setObject:myEquivalences forKey:[neighbors objectAtIndex:j]];
                                    }
                                }
                            }
                        }
                    } 
                } 
            }
        }
    }
    
//    for (NSNumber *aKey in equivalences.allKeys) {
//        NSMutableString *toString = [NSMutableString stringWithString:[NSString stringWithFormat:@"%i: ", aKey.intValue]];
//        for (NSNumber *anItem in [equivalences objectForKey:aKey]) {
//            [toString appendFormat:@"%i, ", [anItem intValue]];
//        }
//        NSLog(@"%@", toString);
//    }
    
    // Normalize equivelences
    
    // 
    
    UIColor *color1 = [[UIColor alloc] initWithRed:((float)103/255) 
                                             green:((float)121/255) 
                                              blue:((float)255/255) 
                                             alpha:((float)255/255)];
    UIColor *color2 = [[UIColor alloc] initWithRed:((float)249/255) 
                                             green:((float)255/255) 
                                              blue:((float)139/255) 
                                             alpha:((float)255/255)];
    UIColor *color3 = [[UIColor alloc] initWithRed:((float)140/255) 
                                             green:((float)255/255) 
                                              blue:((float)127/255) 
                                             alpha:((float)255/255)];
    UIColor *color4 = [[UIColor alloc] initWithRed:((float)167/255) 
                                             green:((float)254/255) 
                                              blue:((float)255/255) 
                                             alpha:((float)255/255)];
    UIColor *color5 = [[UIColor alloc] initWithRed:((float)255/255) 
                                             green:((float)111/255) 
                                              blue:((float)71/255) 
                                             alpha:((float)255/255)];
    NSArray *colorArray = [[NSArray alloc] initWithObjects:color1, color2, color3, color4, color5, nil];
    
    // If dst buffer provided, fill with coloured blobs
    int *dstData = (int *)malloc(width * height * 4 * sizeof(int));
    if (dstData != nil)
    {        
        int srcPtr = 0;
        int dstPtr = 0;
        while (srcPtr < width * height)
        {
            if (srcData[srcPtr] == 255)
            {
                int c = [[labels objectAtIndex:srcPtr] intValue] % [colorArray count];
                float red = 0, green = 0, blue = 0, alpha = 0;
                [((UIColor *)[colorArray objectAtIndex:c]) getRed:&red green:&green blue:&blue alpha:&alpha];
                dstData[dstPtr]	= (int)(red * 255);
                dstData[dstPtr+1] = (int)(green * 255);
                dstData[dstPtr+2] = (int)(blue * 255);
                dstData[dstPtr+3] = (int)(alpha * 255);
            }
            else
            {
                dstData[dstPtr]	= 0;
                dstData[dstPtr+1] = 0;
                dstData[dstPtr+2] = 0;
                dstData[dstPtr+3] = 0;
            }
            
            srcPtr ++;
            dstPtr += 4;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(dstData, 
                                             CGImageGetWidth(binarizedImage.CGImage), 
                                             CGImageGetHeight(binarizedImage.CGImage), 
                                             8,
                                             4 * CGImageGetBytesPerRow(binarizedImage.CGImage), 
                                             colorSpace, 
                                             kCGImageAlphaPremultipliedLast); 
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); 
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef]; 
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx); 
    
    return rawImage;    
}
#endif
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

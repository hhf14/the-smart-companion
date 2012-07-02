//
//  SCServerCommunication.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCServerCommunication.h"
#import "NSData+Base64.h"
#import "SCUtility.h"

static NSString *kSCExtractTextRequest = @"http://%@/cgi-bin/DetectModule.exe?module=%@&lang=%@";
	
@interface SCServerCommunication()

+ (NSString *)generateSOAPMessageWithLangString:(NSString *)langString stringBasedImage:(NSString *)imageString;

@end

@implementation SCServerCommunication

+ (NSString *)detectWithImage:(UIImage *)anImage module:(NSString *)moduleName lang:(NSString *)langCode error:(NSError **)error
{    
    NSString *urlString = @"http://duongtuandat.myftp.biz/TheSmartCompanion/OCRService.asmx";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                          timeoutInterval:10];
    DLog(@"REQUEST: %@", urlString);
    
    NSData *imageData = UIImagePNGRepresentation(anImage);
    DLog(@"DATA_LENGTH: %i", [imageData length]);
    NSString *stringBasedImage = [imageData base64EncodingWithLineLength:0];
    DLog(@"IMAGE_LENGTH: %i", [stringBasedImage length]);
    
    NSString *postString = [SCServerCommunication generateSOAPMessageWithLangString:langCode stringBasedImage:stringBasedImage];
    DLog(@"postString: %@", postString);
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    [requestObj setHTTPMethod:@"POST"];
    [requestObj addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [requestObj addValue:[NSString  stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [requestObj setHTTPBody:postData];
    
    NSData *data = nil;
    NSURLResponse *response = nil;
    data = [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:error];
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"[%i] RESPONSE: %@", ((NSHTTPURLResponse *)response).statusCode, stringData);
    
    NSRange openingResultTag = [stringData rangeOfString:@"<DetectByTesseractResult>"];
    NSRange closingResultTag = [stringData rangeOfString:@"</DetectByTesseractResult>"];    

    NSInteger httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
    NSString *serverMessage = NSLocalizedString(@"UnkownErrorMsg", nil);
    switch (httpStatusCode) {
        case 200:
            if (openingResultTag.length > 0 && closingResultTag.length > 0) {

                NSInteger resultLocation = openingResultTag.location + openingResultTag.length;
                NSInteger resultLength   = closingResultTag.location - resultLocation;
                NSString *detectedText = [stringData substringWithRange:NSMakeRange(resultLocation, resultLength)];
                
                // Note: detectedText is now in a form of "-1 %@" or "0 %@", with -1 denoting an error occurred at server side, 0 denoting a normal response and %@ being the actual content returned from the server.
                NSArray *seperatedComs = [detectedText componentsSeparatedByString:@" "];
                if (seperatedComs.count > 0) {
                    NSString *serverSignal = [seperatedComs objectAtIndex:0];
                    // Trimming to extract the actual content
                    detectedText = [detectedText substringFromIndex:(serverSignal.length + 1)];
                    if ([serverSignal intValue] == -1) { // error occurred
                        serverMessage = detectedText;
                        break;
                    }
                }
                
                return detectedText;
            } 
            break;
        default:
            if ([NSHTTPURLResponse localizedStringForStatusCode:httpStatusCode]) {
                serverMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpStatusCode];
            }
            break;
    }
        
    NSString *errorMessage = [NSString stringWithFormat:@"%@:\n%@", NSLocalizedString(@"ServerErrorMsg", nil), serverMessage];
    if (*error == nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
        *error = [[NSError alloc] initWithDomain:@"unknown" code:100 userInfo:userInfo];
    }
    return stringData;
}

+ (NSString *)generateSOAPMessageWithLangString:(NSString *)langString stringBasedImage:(NSString *)imageString
{
    NSString *result = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
    "<soap12:Body>"
    "<DetectByTesseract xmlns=\"http://tempuri.org/\">"
    "<language>%@</language>"
    "<image>%@</image>"
    "</DetectByTesseract>"
    "</soap12:Body>"
    "</soap12:Envelope>";
    return [NSString stringWithFormat:result, langString, imageString];
}

@end

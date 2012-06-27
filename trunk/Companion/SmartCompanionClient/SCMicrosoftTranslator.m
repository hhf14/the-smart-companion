//
//  SCMicrosoftTranslator.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCMicrosoftTranslator.h"

#define kSCClientID @"highfive"
#define kSCClientSecret @"xDvO0G0CdM2C19xM4gxPT/LL5oteiuC/68NFL6CvIxo="

@implementation SCMicrosoftTranslator

+ (NSString *)detectLanguageWithText:(NSString *)textToDetect error:(NSError **)error
{
    //Keep appId parameter blank as we are sending access token in authorization header.
    NSString *urlString = [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Detect?text=%@", [SCUtility encodeURL:textToDetect]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                          timeoutInterval:10];
    
    SCAuthentication *authObj = [[SCAuthentication alloc] initWithClientID:kSCClientID clientSecret:kSCClientSecret];
    SCAccessToken *accessToken = [authObj getAccessToken];
    [requestObj setValue:[NSString stringWithFormat:@"Bearer %@", accessToken.access_token] forHTTPHeaderField:@"Authorization"];
    NSData *data = nil;
    NSURLResponse *response = nil;
    data = [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:error];
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /* stringData looks like:
     <string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">en</string>
     */
    
    NSString *detectedLanguage = [[stringData stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""] stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    
    return detectedLanguage;
}

+ (NSString *)translateWithText:(NSString *)textToTranslate inputLanguage:(NSString *)inputLanguage outputLanguage:(NSString *)outputLanguage error:(NSError **)error
{
    //Keep appId parameter blank as we are sending access token in authorization header.
    NSString *urlString = [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?text=%@&from=%@&to=%@", [SCUtility encodeURL:textToTranslate], inputLanguage, outputLanguage];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                          timeoutInterval:10];
    
    SCAuthentication *authObj = [[SCAuthentication alloc] initWithClientID:kSCClientID clientSecret:kSCClientSecret];
    SCAccessToken *accessToken = [authObj getAccessToken];
    [requestObj setValue:[NSString stringWithFormat:@"Bearer %@", accessToken.access_token] forHTTPHeaderField:@"Authorization"];
    NSData *data = nil;
    NSURLResponse *response = nil;
    data = [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:error];
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /* stringData looks like:
     <string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">text</string>
     */

    NSString *translatedText = [[stringData stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""] stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    
    return translatedText;
}

@end

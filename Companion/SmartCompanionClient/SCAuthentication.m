//
//  SCAuthentication.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCAuthentication.h"

#define kSCDatamarketAccessUri @"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"

@interface SCAuthentication()

// private methods declaration
- (SCAccessToken *)httpPostWithURI:(NSString *)uri requestDetails:(NSString *)requestDetails;

@end

@implementation SCAuthentication

@synthesize clientId;
@synthesize clientSecret;
@synthesize request;

#pragma mark -
#pragma mark Instance Methods

- (SCAccessToken *)getAccessToken {
    return [self httpPostWithURI:kSCDatamarketAccessUri requestDetails:self.request];
}

- (SCAccessToken *)httpPostWithURI:(NSString *)uri requestDetails:(NSString *)requestDetails {
    
    NSURL *url = [NSURL URLWithString:uri];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                          timeoutInterval:10];
    
    [requestObj setHTTPMethod:@"POST"];
    NSData *postData = [requestDetails dataUsingEncoding:NSUTF8StringEncoding];
    [requestObj setHTTPBody:postData];
    
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    data = [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:&error];
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /* stringData looks like:
     {"access_token":"http%3a%2f%2fschemas.xmlsoap.org%2fws%2f2005%2f05%2fidentity%2fclaims%2fnameidentifier=highfive&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&Audience=http%3a%2f%2fapi.microsofttranslator.com&ExpiresOn=1335347351&Issuer=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&HMACSHA256=tQTBk98Jy3kVBvOZ2HZvI%2fUwwCiTrcEDey09JalmPzY%3d","token_type":"http://schemas.xmlsoap.org/ws/2009/11/swt-token-profile-1.0","expires_in":"600","scope":"http://api.microsofttranslator.com"}
     */
    
    NSArray *splittedParts = [stringData componentsSeparatedByString:@","];    
    SCAccessToken *accessToken = [[SCAccessToken alloc] init];
    for (NSString *splittedPart in splittedParts) {
        NSArray *subParts = [splittedPart componentsSeparatedByString:@":"];      
        if ([subParts count] >= 2) {
            if ([(NSString *)[subParts objectAtIndex:0] rangeOfString:@"access_token"].length > 0) {
                
                accessToken.access_token = [[splittedPart stringByReplacingOccurrencesOfString:@"\"access_token\":" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{\""]];
                
            } else if ([(NSString *)[subParts objectAtIndex:0] rangeOfString:@"token_type"].length > 0) {
                
                accessToken.token_type = [[splittedPart stringByReplacingOccurrencesOfString:@"\"token_type\":" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                
            } else if ([(NSString *)[subParts objectAtIndex:0] rangeOfString:@"expires_in"].length > 0) {
                
                accessToken.expires_in = [[splittedPart stringByReplacingOccurrencesOfString:@"\"expires_in\":" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                
            } else if ([(NSString *)[subParts objectAtIndex:0] rangeOfString:@"scope"].length > 0) {
                
                accessToken.scope = [[splittedPart stringByReplacingOccurrencesOfString:@"\"scope\":" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"}"]];
                
            } 
        }
    }
        
    return accessToken;
}

#pragma mark -
#pragma mark Object Lifecycle

- (id)initWithClientID:(NSString *)aClientID clientSecret:(NSString *)aClientSecret {
    
    self = [super init];
    if (self) {
        self.clientId = aClientID;
        self.clientSecret = aClientSecret;
        
        //If clientid or client secret has special characters, encode before sending request
        self.request = [NSString stringWithFormat:@"grant_type=client_credentials&client_id=%@&client_secret=%@&scope=http://api.microsofttranslator.com", [SCUtility encodeURL:clientId], [SCUtility encodeURL:clientSecret]];
    }
    
    return self;
    
}

- (void)dealloc {
    self.clientId = nil;
    self.clientSecret = nil;
    self.request = nil;
}

@end

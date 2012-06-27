//
//  SCUtility.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCUtility.h"

@implementation SCUtility

#pragma mark -
#pragma mark Utility Functions

+ (NSString *)encodeURL:(NSString *)anURL
{
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                                  (__bridge CFStringRef)anURL, 
                                                                                  NULL, 
                                                                                  (CFStringRef)@"!*'\"();:@&=+$,/?%#[] ", 
                                                                                  kCFStringEncodingUTF8);
    return encodedString;
}

@end

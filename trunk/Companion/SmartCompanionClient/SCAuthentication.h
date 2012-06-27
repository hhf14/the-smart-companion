//
//  SCAuthentication.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCUtility.h"
#import "SCAccessToken.h"

@interface SCAuthentication : NSObject {
    
    NSString *clientId;
    NSString *clientSecret;
    NSString *request;
    
}

@property (nonatomic, retain) NSString *clientId;
@property (nonatomic, retain) NSString *clientSecret;
@property (nonatomic, retain) NSString *request;

- (id)initWithClientID:(NSString *)aClientID clientSecret:(NSString *)aClientSecret;
- (SCAccessToken *)getAccessToken;

@end

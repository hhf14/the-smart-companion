//
//  SCAccessToken.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCAccessToken.h"

@implementation SCAccessToken

@synthesize access_token;
@synthesize token_type;
@synthesize expires_in;
@synthesize scope;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    self.access_token = nil;
    self.token_type = nil;
    self.expires_in = nil;
    self.scope = nil;
}

@end

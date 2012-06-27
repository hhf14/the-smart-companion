//
//  SCAccessToken.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCAccessToken : NSObject {
    
    NSString *access_token;
    NSString *token_type;
    NSString *expires_in;
    NSString *scope;
    
}

@property (nonatomic, retain) NSString *access_token;
@property (nonatomic, retain) NSString *token_type;
@property (nonatomic, retain) NSString *expires_in;
@property (nonatomic, retain) NSString *scope;

@end

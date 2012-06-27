//
//  SCServerCommunication.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCServerCommunication : NSObject

+ (NSString *)detectWithImage:(UIImage *)anImage module:(NSString *)moduleName lang:(NSString *)langCode error:(NSError **)error;

@end

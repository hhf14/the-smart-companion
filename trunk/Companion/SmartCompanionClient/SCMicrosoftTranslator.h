//
//  SCMicrosoftTranslator.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCAccessToken.h"
#import "SCAuthentication.h"

@interface SCMicrosoftTranslator : NSObject

+ (NSString *)detectLanguageWithText:(NSString *)textToDetect error:(NSError **)error;
+ (NSString *)translateWithText:(NSString *)textToTranslate inputLanguage:(NSString *)inputLanguage outputLanguage:(NSString *)outputLanguage error:(NSError **)error;

@end

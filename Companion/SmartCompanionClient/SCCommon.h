//
//  SCCommon.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define kSCSourceLangKey @"Source Language"

#pragma mark -
#pragma mark Constants Definition

static const NSString *kSCServerName = @"duongtuandat.myftp.biz:8081";

@interface SCCommon : NSObject

@end

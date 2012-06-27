//
//  SCAppDelegate.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface SCAppDelegate : UIResponder <UIApplicationDelegate> {
    Facebook *facebook;
}

@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) UIWindow *window;

@end

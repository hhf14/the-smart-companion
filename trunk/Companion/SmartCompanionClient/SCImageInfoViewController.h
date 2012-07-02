//
//  SCImageInfoViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLanguageViewController.h"

@interface SCImageInfoViewController : UITableViewController <SCLanguageViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *tableContents;
@property (nonatomic, strong) NSMutableDictionary *footerContents;

@end

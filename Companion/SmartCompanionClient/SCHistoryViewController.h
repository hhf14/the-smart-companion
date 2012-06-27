//
//  SCHistoryViewController.h
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHistoryViewController : UITableViewController {
    NSMutableArray *historyData;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *historyData;

- (IBAction)handleSearchButton:(id)sender;

@end

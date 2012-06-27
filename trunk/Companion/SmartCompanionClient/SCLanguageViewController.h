//
//  SCLanguageViewController.h
//  SmartCompanionClient
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCLanguageViewController;

@protocol SCLanguageViewDelegate

- (void)languageViewController:(SCLanguageViewController *)controller didChooseLanguage:(NSString *)language;

@end

@interface SCLanguageViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
    
    NSDictionary *languageData;
    NSArray *languageList;
    NSMutableArray *searchResult;
    
    BOOL searching;
    BOOL letUserSelectRow;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) id <SCLanguageViewDelegate> delegate;

- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;

@end



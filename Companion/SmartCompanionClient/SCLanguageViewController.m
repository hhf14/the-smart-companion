//
//  SCLanguageViewController.m
//  SmartCompanionClient
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCLanguageViewController.h"

@implementation SCLanguageViewController

@synthesize searchBar,delegate;

#pragma mark - View LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //data for table view after search
    searchResult = [[NSMutableArray alloc] init];
    
    self.tableView.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //get data from MSLang.plist file
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"MSLang.plist"];
    languageData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    languageList = [NSArray arrayWithArray:[languageData allKeys]];
    languageList = [languageList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    searching = NO;
    letUserSelectRow = YES;    
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search bar delegate
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
    
    //Add the done button.
    if(self.navigationItem.rightBarButtonItem==nil){
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(doneSearching_Clicked:)];
    }
}
- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
        
        //Remove all objects first.
        [searchResult removeAllObjects];
        
        if([searchText length] > 0) {
            
            searching = YES;
            letUserSelectRow = YES;
            self.tableView.scrollEnabled = YES;
            [self searchTableView];
        }
        else {
            
            searching = NO;
            letUserSelectRow = NO;
            self.tableView.scrollEnabled = NO;
        }
        
        [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    [searchBar resignFirstResponder];
    
    //dang loi khi clear text
    //searchBar.text = @"";
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching)
        return [searchResult count];
    else {
        
        //Number of rows it should expect should be based on the section
        return [languageList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        NSLog(@"Cell = nil");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
            
    if(searching) {
        if ([searchResult count] > indexPath.row) {
            cell.textLabel.text = NSLocalizedString([searchResult objectAtIndex:indexPath.row], nil);
        }
    } else {
        if ([languageList count] > indexPath.row) {
            //First get the dictionary object
            cell.textLabel.text = NSLocalizedString([languageList objectAtIndex:indexPath.row], nil);
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//The variable “letUserSelectRow” is set to NO, so we can prohibit the user from selecting a row. Scrolling of the table view is also disabled which will help us when we add a overlay above the view.
- (NSIndexPath *)tableView :(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedLanguage = nil;
    
    if(searching)
        selectedLanguage = [searchResult objectAtIndex:indexPath.row];
    else {
        selectedLanguage = [languageList objectAtIndex:indexPath.row];
    }
    //NSLog(@"Language screen: selected %@\n",selectedLanguage);
    [self.delegate languageViewController:self didChooseLanguage:selectedLanguage];
}

#pragma mark - Instance method
- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    for (NSString *sTemp in languageList)
    {
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [searchResult addObject:sTemp];
    }    
    searchArray = nil;
}
- (void) doneSearching_Clicked:(id)sender {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    self.navigationItem.rightBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
}@end

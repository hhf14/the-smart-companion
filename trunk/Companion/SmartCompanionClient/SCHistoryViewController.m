//
//  SCHistoryViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCHistoryViewController.h"

@interface SCHistoryViewController ()

@end

@implementation SCHistoryViewController

@synthesize searchButton;
@synthesize searchBar;
@synthesize historyData;

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
    
    self.historyData = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment for 1 item", @"Comment", nil];
    NSDictionary *item2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment for 2 item", @"Comment", nil];
    NSDictionary *item3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment for 3 item", @"Comment", nil];
    NSDictionary *item4 = [NSDictionary dictionaryWithObjectsAndKeys:@"Comment for 4 item", @"Comment", nil];
    
    [self.historyData addObject:item1];
    [self.historyData addObject:item2];
    [self.historyData addObject:item3];
    [self.historyData addObject:item4];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return self.historyData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
//    NSDictionary *object = [self.historyData objectAtIndex:indexPath.row];
//    cell.textLabel.text = [object valueForKey:@"Comment"];
    
    UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 43, 43)];
    [thumbnail setBackgroundColor:[UIColor blackColor]];
    [cell addSubview:thumbnail];
    
    UILabel *dateTime = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 237, 20)];
    [dateTime setText:@"20:22:12 May 09, 2012"];
    [cell addSubview:dateTime];
    
    UILabel *comment = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, 237, 20)];
    [comment setText:@"Day la mot comment rat dai day!!!!"];
    [cell addSubview:comment];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (IBAction)handleSearchButton:(id)sender {
    /*
    if (![self.view.subviews containsObject:self.searchBar]) {
        [self.view addSubview:self.searchBar];
    } else {
        [self.searchBar removeFromSuperview];
    }
     */
}

@end

//
//  SCSettingsViewController.m
//  SmartCompanionClient
//
//  Created by Doan Van Cao on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SCSettingsViewController.h"

@interface SCSettingsViewController ()

@end

@implementation SCSettingsViewController

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
    settingsData = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"English", @"Default input language", 
                    @"Vietnamese", @"Default output language", 
                    @"YES", @"Auto Save", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [settingsData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [settingsData.allKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
	NSString *data = [settingsData objectForKey:[settingsData.allKeys objectAtIndex:[indexPath section]]];
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:simpleTableIdentifier];
	}
    
	cell.textLabel.text = data;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//	NSString *data = [settingsData objectForKey:[settingsData.allKeys objectAtIndex:[indexPath section]]];
//	NSUInteger row = [indexPath row];
//	NSString *rowValue = [listData objectAtIndex:row];
//    
//	NSString *message = [[NSString alloc] initWithFormat:rowValue];
//	UIAlertView *alert = [[UIAlertView alloc]
//						  initWithTitle:@"You selected"
//						  message:message delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil];
//	[alert show];
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

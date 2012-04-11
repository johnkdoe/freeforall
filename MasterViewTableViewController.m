//
//  MasterViewTableViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "MasterViewTableViewController.h"

#import "ScrollableImageDetailViewController.h"
#import "UIViewController+UISplitViewControllerUtilities.h"

@implementation MasterViewTableViewController

@synthesize objects = _objects;
@synthesize mapPopover = _mapPopover;

- (void)setObjects:(NSArray *)objects
{
	_objects = objects;
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	ScrollableImageDetailViewController* sidVC
	  = (ScrollableImageDetailViewController*)[self detailViewController];
	[sidVC resetSplitViewBarButtonTitle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _objects.count;
}

- (BOOL)		tableView:(UITableView *)tableView
	canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end

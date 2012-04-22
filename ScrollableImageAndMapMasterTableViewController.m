//
//  ScrollableImageAndMapMasterTableViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ScrollableImageAndMapMasterTableViewController.h"
#import "UIViewController+MasterDetailUtilities.h"

#import "MapViewController.h"
#import "ScrollableImageDetailViewController.h"

@interface ScrollableImageAndMapMasterTableViewController ()
	<MapViewControllerDelegate, UITableViewDelegate>

@end

@implementation ScrollableImageAndMapMasterTableViewController

@synthesize mapPopover = _mapPopover;
@synthesize objects = _objects;

- (void)setObjects:(NSArray *)objects
{
	_objects = objects;
	[self.tableView reloadData];
}

#pragma mark - UITableViewController life cycle // overrides

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

#pragma mark - ScrollableImageAndMapMasterTableViewController

- (void)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath
{
	mapVC.delegate = self;
}

#pragma mark - UITableViewDelegate protocol 

#pragma mark @optional


- (void)						   tableView:(UITableView*)tableView
	accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		MapViewController* mapVC
		  = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
		[self annotateMap:mapVC forRowAtIndexPath:indexPath];
		
		self.mapPopover = [[UIPopoverController alloc] initWithContentViewController:mapVC];
		[self.mapPopover setPopoverContentSize:CGSizeMake(700, 700)];
		[self.mapPopover presentPopoverFromRect:[tableView rectForRowAtIndexPath:indexPath]
										 inView:tableView
					   permittedArrowDirections:UIPopoverArrowDirectionLeft 
									   animated:YES];
	} else {		
		[self performSegueWithIdentifier:@"iPhoneMapView" sender:indexPath];
	}
}


#pragma mark - UITableViewDataSource 

#pragma mark @required	// see subclasses for full protocol implementors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

#pragma mark @optional

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

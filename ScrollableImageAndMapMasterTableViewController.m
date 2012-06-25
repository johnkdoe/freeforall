//
//  ScrollableImageAndMapMasterTableViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ScrollableImageAndMapMasterTableViewController.h"

#import "UISplitViewController+MasterDetailUtilities.h"
#import "xolawareReachability.h"

#import "FlipsideViewController.h"
#import "MapViewController.h"
#import "ScrollableImageDetailViewController.h"

@interface ScrollableImageAndMapMasterTableViewController ()
	<MapViewControllerDelegate, UITableViewDelegate>

@end

@implementation ScrollableImageAndMapMasterTableViewController

@synthesize mapPopover = _mapPopover;
@synthesize objects = _objects;
@synthesize retrievalDate = _retrievalDate;
@synthesize systemLocaleFormatter = _systemLocaleFormatter;

- (NSDateFormatter*)systemLocaleFormatter
{
	if (!_systemLocaleFormatter)
	{
		_systemLocaleFormatter = [[NSDateFormatter alloc] init];
		_systemLocaleFormatter.locale = [NSLocale systemLocale];
	}
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		_systemLocaleFormatter.dateStyle = NSDateFormatterShortStyle;
		if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
			_systemLocaleFormatter.timeStyle = NSDateFormatterShortStyle;
		else
			_systemLocaleFormatter.timeStyle = NSDateFormatterMediumStyle;
	}
	else
		_systemLocaleFormatter.dateStyle = NSDateFormatterMediumStyle,
		_systemLocaleFormatter.timeStyle = NSDateFormatterMediumStyle;
	return _systemLocaleFormatter;

}

- (void)setObjects:(NSArray *)newObjects
{
	int delta;
	if (_objects && newObjects && 0 < (delta = newObjects.count - _objects.count))
	{
		NSArray* newObjectsHead = [newObjects subarrayWithRange:NSMakeRange(0, _objects.count)];
		if ([newObjectsHead isEqualToArray:_objects])
		{
			NSMutableArray* newIndexPaths = [NSMutableArray arrayWithCapacity:delta];
			for (int i = _objects.count; i < newObjects.count ; ++i)
				[newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			[self.tableView beginUpdates];
			_objects = newObjects;
			[self.tableView insertRowsAtIndexPaths:newIndexPaths
								  withRowAnimation:UITableViewRowAnimationBottom];
			[self.tableView endUpdates];
			return;
		}
	}

	_objects = newObjects;
	[self.tableView reloadData];
}

#pragma mark - public implementation

- (void)setDateBasedTitleForOrientation:(UIInterfaceOrientation)orientation
{
	NSString* localeDate = [self.systemLocaleFormatter stringFromDate:self.retrievalDate];
	if (UIDeviceOrientationIsLandscape(orientation) && !self.splitViewController)
		localeDate = [NSLocalizedString(self.title, nil)
					  stringByAppendingFormat:@": %@", localeDate];
	self.navigationItem.title = localeDate;	
}

#pragma mark - UITableViewController life cycle // overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(self.title, nil);
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsLandscapePhone];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	ScrollableImageDetailViewController* sidVC
	  = (ScrollableImageDetailViewController*)(self.splitViewController.detailUIViewController);
	[sidVC resetSplitViewBarButtonTitle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - ScrollableImageAndMapMasterTableViewController

- (BOOL)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath
{
	mapVC.delegate = self;
	return YES;
}

#pragma mark - UITableViewDelegate protocol 
#pragma mark @optional

- (void)						   tableView:(UITableView*)tableView
	accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	if ([xolawareReachability connectedToNetwork])
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
	else
	{
		[xolawareReachability alertNetworkUnavailable];
	}
}

#pragma mark - UITableViewDataSource 

#pragma mark @required	// see subclasses for full protocol implementors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark @optional

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _objects.count;
}

- (BOOL)		tableView:(UITableView *)tableView
	canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - FlipsideViewControllerDelegate implementation

- (BOOL)scrollsToTop {
	return self.tableView.scrollsToTop;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop{
	self.tableView.scrollsToTop = scrollsToTop;
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController*)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self dismissModalViewControllerAnimated:YES];		
}

#pragma mark - SecondaryQueuePhotoReceiver implementation

// expected to run only on non-main queue
- (void)showPhotos:(NSArray*)photos {
	dispatch_async(dispatch_get_main_queue(), ^ { self.objects = photos; });
}

@end

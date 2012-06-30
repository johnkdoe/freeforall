//
//  ScrollableImageAndMapMasterTableViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "TableWithMapAccessoryViewController.h"

#import "UISplitViewController+MasterDetailUtilities.h"
#import "xolawareReachability.h"

#import "FlipsideViewController.h"
#import "MapViewController.h"
#import "SplitViewTitle.h"

@interface TableWithMapAccessoryViewController ()
	<MapViewControllerDelegate, UITableViewDelegate>

@end

@implementation TableWithMapAccessoryViewController

@synthesize mapPopover = _mapPopover;
@synthesize objects = _objects;
@synthesize retrievalDate = _retrievalDate;
@synthesize systemLocaleFormatter = _systemLocaleFormatter;

#pragma mark - syntheisize overrides

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

- (void)setObjects:(NSArray*)newObjects
{
	int delta;
	NSUInteger newCount = newObjects.count;
	if (_objects && newObjects && 0 < (delta = newCount - _objects.count))
	{
		NSArray* newObjectsHead = [newObjects subarrayWithRange:NSMakeRange(0, _objects.count)];
		if ([newObjectsHead isEqualToArray:_objects])
		{
			// update tableView
			NSMutableArray* newIndexPaths = [NSMutableArray arrayWithCapacity:delta];
			for (int i = _objects.count; i < newCount ; ++i)
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
	if (!self.isEditing)
		[self.tableView reloadData];
}

#pragma mark - public implementation

- (BOOL)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath
{
	mapVC.delegate = self;
	return YES;
}

- (void)setDateBasedTitleForOrientation:(UIInterfaceOrientation)orientation
{
	NSString* localeDate = [self.systemLocaleFormatter stringFromDate:self.retrievalDate];
	if (UIDeviceOrientationIsLandscape(orientation) && !self.splitViewController)
		localeDate = [NSLocalizedString(self.title, nil)
					  stringByAppendingFormat:@": %@", localeDate];
	self.navigationItem.title = localeDate;	
}

- (void)setNestedNavControllerHandlerInViewController:(UIViewController*)uiVC {
	if ([self.tabBarController conformsToProtocol:@protocol(NestedNavigationControllerHandler)]
		&& [uiVC respondsToSelector:@selector(setNestedNavControllerHandler:)])
		[(id)uiVC setNestedNavControllerHandler:(id)self.tabBarController];
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
	if ([self.splitViewController.detailUIViewController conformsToProtocol:@protocol(SplitViewTitle)])
		[(id)self.splitViewController.detailUIViewController resetSplitViewBarButtonTitle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    return tableView.isEditing;
}

-(void)		 tableView:(UITableView*)tableView
	moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath
		   toIndexPath:(NSIndexPath*)destinationIndexPath
{
	NSMutableArray* reorderedObjects = _objects.mutableCopy;
	NSObject* objectToMove = [reorderedObjects objectAtIndex:sourceIndexPath.row];
	[reorderedObjects removeObjectAtIndex:sourceIndexPath.row];
	[reorderedObjects insertObject:objectToMove atIndex:destinationIndexPath.row];
	_objects = reorderedObjects.copy;
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

- (void)	 tableView:(UITableView*)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
	 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSMutableArray* objectsMinusThis = _objects.mutableCopy;
		[objectsMinusThis removeObjectAtIndex:indexPath.row];
		[tableView beginUpdates];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:YES];
		_objects = objectsMinusThis;
		[tableView endUpdates];
	}
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

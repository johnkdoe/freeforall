//
//  ScrollableImageAndMapMasterTableViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "TableWithMapAccessoryViewController.h"

#import "UISplitViewController+MasterDetailUtilities.h"
#import "xolawareReachability.h"

#import "MapViewController.h"
#import "SplitViewTitle.h"

@interface TableWithMapAccessoryViewController ()
	<UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate,
	 MapViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) NSString* unlocalizedTitle;

@end

@implementation TableWithMapAccessoryViewController

@synthesize mapPopover = _mapPopover;
@synthesize objects = _objects;
@synthesize retrievalDate = _retrievalDate;
@synthesize systemLocaleFormatter = _systemLocaleFormatter;

@synthesize alertView = _alertView;

@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize unlocalizedTitle;

#pragma mark - syntheisize overrides

- (NSDateFormatter*)systemLocaleFormatter {
	if (!_systemLocaleFormatter)
	{
		_systemLocaleFormatter = [[NSDateFormatter alloc] init];
		_systemLocaleFormatter.locale = [NSLocale systemLocale];
	}
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		_systemLocaleFormatter.dateStyle = NSDateFormatterShortStyle;
		if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
			_systemLocaleFormatter.timeStyle = NSDateFormatterShortStyle;
		else
			_systemLocaleFormatter.timeStyle = NSDateFormatterMediumStyle;
	}
	else
		_systemLocaleFormatter.dateStyle = NSDateFormatterMediumStyle,
		_systemLocaleFormatter.timeStyle = NSDateFormatterMediumStyle;
	return _systemLocaleFormatter;

}

- (void)setObjects:(NSArray*)newObjects {
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

- (BOOL)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath {
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

- (void)viewDidLoad {
    [super viewDidLoad];
	self.unlocalizedTitle = self.title;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsLandscapePhone];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(self.unlocalizedTitle, nil);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.splitViewController.detailUIViewController conformsToProtocol:@protocol(SplitViewTitle)])
		[(id)self.splitViewController.detailUIViewController resetSplitViewBarButtonTitle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"tableViewInfo"])
	{
		// can't navigate away from this modal via tab, so no need to worry about nesting
		[segue.destinationViewController setFlipsideViewControllerDelegate:self];
		if ([segue respondsToSelector:@selector(popoverController)])
		{
			self.flipsidePopoverController = [(id)segue popoverController];
			self.flipsidePopoverController.delegate = self;
		}
		if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom])
			self.navigationItem.rightBarButtonItem.enabled = NO;		
	}

}

#pragma mark - UIAlertViewDelegate protocol implementation
#pragma @optional

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView == self.alertView)
		self.alertView = nil;
}

#pragma mark - UIPopoverControllerDelegate protocol implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.flipsidePopoverController = nil;
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
		if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom])
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
		self.alertView = [xolawareReachability alertNetworkUnavailable:self];
	}
}

#pragma mark - FlipsideViewControllerDelegate implementation

- (BOOL)scrollsToTop {
	return self.tableView.scrollsToTop;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop{
	self.tableView.scrollsToTop = scrollsToTop;
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController*)controller {
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
	{
//		[self dismissModalViewControllerAnimated:YES];
		[self dismissViewControllerAnimated:YES completion:nil];
    }
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;	// turn info button back on
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

#pragma mark - SecondaryQueuePhotoReceiver implementation

// expected to run only on non-main queue
- (void)showPhotos:(NSArray*)photos {
	dispatch_async(dispatch_get_main_queue(), ^ { self.objects = photos; });
}

@end
